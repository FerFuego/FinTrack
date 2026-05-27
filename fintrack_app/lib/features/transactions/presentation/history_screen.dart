import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../data/transaction_repository.dart';
import '../../../shared/models/transaction_model.dart';
import '../../../core/constants/app_theme.dart';
import '../../../features/groups/data/group_repository.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  final int groupId;
  const HistoryScreen({super.key, required this.groupId});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  List<TransactionModel> _transactions = [];
  int _currentPage = 1;
  bool _hasMore = true;
  bool _loading = false;
  bool _initialLoad = true;

  String? _filterType;
  String? _filterCurrency;

  int? _resolvedGroupId;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _loadPage(refresh: true);
    _scrollCtrl.addListener(_onScroll);
    _startPolling();
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (mounted && !_loading && _searchCtrl.text.isEmpty) {
        _loadPage(refresh: true, silent: true);
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
      if (!_loading && _hasMore) _loadPage();
    }
  }

  Future<void> _loadPage({bool refresh = false, bool silent = false}) async {
    if (_loading) return;
    if (refresh) {
      setState(() {
        _currentPage = 1;
        _hasMore = true;
        if (!silent) {
          _transactions = [];
          _initialLoad = true;
        }
      });
    }
    if (!silent) {
      setState(() => _loading = true);
    }

    try {
      if (_resolvedGroupId == null) {
        if (widget.groupId != 0) {
          _resolvedGroupId = widget.groupId;
        } else {
          final groups = await ref.read(groupRepositoryProvider).listGroups();
          if (groups.isNotEmpty) {
            _resolvedGroupId = groups.first.id;
          } else {
            setState(() { _loading = false; _initialLoad = false; });
            return;
          }
        }
      }

      final data = await ref.read(transactionRepositoryProvider).listTransactions(
        groupId: _resolvedGroupId!,
        page: _currentPage,
        type: _filterType,
        currency: _filterCurrency,
        search: _searchCtrl.text.isNotEmpty ? _searchCtrl.text : null,
      );
      final items = (data['data'] as List<dynamic>)
          .map((j) => TransactionModel.fromJson(j as Map<String, dynamic>))
          .toList();
      final lastPage = data['last_page'] as int? ?? 1;

      setState(() {
        if (refresh) {
          _transactions = items;
        } else {
          _transactions.addAll(items);
        }
        _hasMore = _currentPage < lastPage;
        _currentPage++;
        _loading = false;
        _initialLoad = false;
      });
    } catch (e) {
      setState(() { _loading = false; _initialLoad = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: _showFilters,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => _loadPage(refresh: true),
              decoration: InputDecoration(
                hintText: 'Buscar movimientos...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.textMuted),
                        onPressed: () { _searchCtrl.clear(); _loadPage(refresh: true); },
                      )
                    : null,
              ),
            ),
          ),

          // Filter chips
          if (_filterType != null || _filterCurrency != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Wrap(
                spacing: 8,
                children: [
                  if (_filterType != null)
                    Chip(
                      label: Text(_filterType == 'income' ? 'Ingresos' : 'Egresos'),
                      backgroundColor: _filterType == 'income' ? AppColors.incomeBackground : AppColors.expenseBackground,
                      labelStyle: TextStyle(
                        color: _filterType == 'income' ? AppColors.income : AppColors.expense,
                        fontSize: 12,
                      ),
                      deleteIcon: const Icon(Icons.close, size: 14),
                      onDeleted: () { setState(() => _filterType = null); _loadPage(refresh: true); },
                    ),
                  if (_filterCurrency != null)
                    Chip(
                      label: Text(_filterCurrency!),
                      backgroundColor: AppColors.surfaceVariant,
                      labelStyle: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
                      deleteIcon: const Icon(Icons.close, size: 14),
                      onDeleted: () { setState(() => _filterCurrency = null); _loadPage(refresh: true); },
                    ),
                ],
              ),
            ),

          const SizedBox(height: 8),
          Expanded(
            child: _initialLoad
                ? ListView.builder(
                    itemCount: 6,
                    itemBuilder: (_, i) => _ShimmerTile(),
                  )
                : _transactions.isEmpty
                    ? _buildEmpty()
                    : ListView.builder(
                        controller: _scrollCtrl,
                        itemCount: _transactions.length + (_hasMore ? 1 : 0),
                        itemBuilder: (_, i) {
                          if (i == _transactions.length) {
                            return const Padding(
                              padding: EdgeInsets.all(24),
                              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                            );
                          }
                          return _TransactionTile(tx: _transactions[i])
                              .animate()
                              .fadeIn(delay: (i * 40).ms)
                              .slideX(begin: 0.1);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filtros', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            const Text('Tipo', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _FilterChip(label: 'Todos', selected: _filterType == null, onTap: () { setState(() => _filterType = null); Navigator.pop(context); _loadPage(refresh: true); }),
                _FilterChip(label: 'Ingresos', selected: _filterType == 'income', onTap: () { setState(() => _filterType = 'income'); Navigator.pop(context); _loadPage(refresh: true); }),
                _FilterChip(label: 'Egresos', selected: _filterType == 'expense', onTap: () { setState(() => _filterType = 'expense'); Navigator.pop(context); _loadPage(refresh: true); }),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Moneda', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['ARS', 'USD', 'EUR'].map((c) =>
                _FilterChip(label: c, selected: _filterCurrency == c, onTap: () { setState(() => _filterCurrency = _filterCurrency == c ? null : c); Navigator.pop(context); _loadPage(refresh: true); }),
              ).toList(),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off_rounded, size: 64, color: AppColors.textMuted),
          const SizedBox(height: 16),
          const Text('Sin resultados', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
          const SizedBox(height: 8),
          const Text('Intentá con otros filtros', style: TextStyle(color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textSecondary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final TransactionModel tx;
  const _TransactionTile({required this.tx});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.00');
    final isIncome = tx.isIncome;
    final color = isIncome ? AppColors.income : AppColors.expense;
    final dateStr = DateFormat('dd/MM/yyyy').format(tx.date);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            child: Icon(
              isIncome ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.description, style: const TextStyle(
                  color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14,
                ), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(children: [
                  Text(tx.user?.name.split(' ').first ?? '', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  const Text(' · ', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  Text(dateStr, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                ]),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isIncome ? '+' : '-'}${tx.currency.symbol} ${fmt.format(tx.amount)}',
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                tx.type.label,
                style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ShimmerTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceVariant,
      highlightColor: AppColors.border,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        height: 72,
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
