import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../../features/groups/data/group_repository.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../shared/models/group_model.dart';
import '../../../shared/models/transaction_model.dart';
import '../../../core/constants/app_theme.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  final int? groupId;
  const DashboardScreen({super.key, this.groupId});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> with WidgetsBindingObserver {
  GroupModel? _selectedGroup;
  Map<String, dynamic>? _summary;
  List<TransactionModel> _recent = [];
  bool _loading = true;
  bool _noGroups = false;
  String _selectedCurrency = 'ARS';

  String? _lastLocation;
  Timer? _pollingTimer;

  double _toDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? 0.0;
    return 0.0;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
    _startPolling();
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (mounted && !_loading) {
        _load(silent: true);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pollingTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      _load();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload when navigating back to dashboard (e.g. after creating a group)
    // Use addPostFrameCallback to avoid setState-during-build conflicts with flutter_animate
    final location = GoRouterState.of(context).matchedLocation;
    if (_lastLocation != null &&
        _lastLocation != location &&
        location.startsWith('/dashboard')) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _load();
      });
    }
    _lastLocation = location;
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent) {
      setState(() => _loading = true);
    }
    try {
      final groups = await ref.read(groupRepositoryProvider).listGroups();
      if (groups.isEmpty) {
        setState(() { _loading = false; _noGroups = true; _selectedGroup = null; });
        return;
      }
      final group = widget.groupId != null
          ? groups.firstWhere((g) => g.id == widget.groupId, orElse: () => groups.first)
          : groups.first;

      if (!silent) {
        setState(() { _noGroups = false; _selectedGroup = group; });
      } else {
        _noGroups = false;
        _selectedGroup = group;
      }

      final summaryData = await ref.read(groupRepositoryProvider).getGroupSummary(
        group.id,
        currency: _selectedCurrency,
      );

      final txData = summaryData['recent_transactions'] as List<dynamic>? ?? [];
      setState(() {
        _summary = summaryData['summary'] as Map<String, dynamic>?;
        _recent = txData.map((j) => TransactionModel.fromJson(j as Map<String, dynamic>)).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        onRefresh: _load,
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0A0E1A), Color(0xFF141928)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hola, ${user?.name.split(' ').first ?? 'Usuario'} 👋',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Tu balance',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: _load,
                          icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Balance card
                    _buildBalanceCard(),
                  ],
                ),
              ),
            ),

            // Currency selector
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Row(
                  children: ['ARS', 'USD', 'EUR'].map((c) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedCurrency = c);
                        _load();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: _selectedCurrency == c ? AppColors.primary : AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _selectedCurrency == c ? AppColors.primary : AppColors.border,
                          ),
                        ),
                        child: Text(
                          c,
                          style: TextStyle(
                            color: _selectedCurrency == c ? Colors.white : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  )).toList(),
                ),
              ),
            ),

            // Summary cards
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Row(
                  children: [
                    Expanded(child: _buildMiniCard(
                      label: 'Ingresos',
                      amount: _toDouble(_summary?['total_income']),
                      isIncome: true,
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: _buildMiniCard(
                      label: 'Egresos',
                      amount: _toDouble(_summary?['total_expense']),
                      isIncome: false,
                    )),
                  ],
                ),
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
            ),

            // Recent transactions header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Últimos movimientos',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_selectedGroup != null)
                      TextButton(
                        onPressed: () => context.go('/history?groupId=${_selectedGroup!.id}'),
                        child: const Text('Ver todo', style: TextStyle(color: AppColors.primary)),
                      ),
                  ],
                ),
              ),
            ),

            // Transactions list
            if (_loading)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _ShimmerTile(),
                  childCount: 4,
                ),
              )
            else if (_noGroups || _recent.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _buildEmptyState(),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _TransactionTile(transaction: _recent[i])
                      .animate()
                      .fadeIn(delay: (i * 80).ms)
                      .slideX(begin: 0.2),
                  childCount: _recent.length,
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      floatingActionButton: _selectedGroup != null
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/add-transaction?groupId=${_selectedGroup!.id}').then((_) => _load()),
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text('Agregar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ).animate().scale(delay: 500.ms)
          : null,
    );
  }

  Widget _buildBalanceCard() {
    if (_loading) {
      return Shimmer.fromColors(
        baseColor: AppColors.surfaceVariant,
        highlightColor: AppColors.border,
        child: Container(height: 160, decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
        )),
      );
    }

    final balance = _toDouble(_summary?['balance']);
    final isPositive = balance >= 0;
    final fmt = NumberFormat('#,##0.00');

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_selectedGroup != null)
            Row(
              children: [
                Text(_selectedGroup!.emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(
                  _selectedGroup!.name,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          const SizedBox(height: 16),
          Text(
            '${_selectedCurrency == 'ARS' ? '\$' : _selectedCurrency} ${fmt.format(balance.abs())}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                color: Colors.white70,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                isPositive ? 'Balance positivo' : 'Balance negativo',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1);
  }

  Widget _buildMiniCard({required String label, required double amount, required bool isIncome}) {
    final fmt = NumberFormat('#,##0.00');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isIncome ? AppColors.income.withOpacity(0.3) : AppColors.expense.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isIncome ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                color: isIncome ? AppColors.income : AppColors.expense,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(
                color: isIncome ? AppColors.income : AppColors.expense,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              )),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            fmt.format(amount),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    // No groups at all → guide user to create one
    if (_noGroups) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('💰', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 20),
              const Text('¡Empezá creando un grupo!', style: TextStyle(
                color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold,
              )),
              const SizedBox(height: 8),
              const Text(
                'Creá o uníte a un grupo para\nregistrar tus movimientos.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => context.go('/groups'),
                icon: const Icon(Icons.group_add_rounded),
                label: const Text('Ir a Grupos'),
              ),
            ],
          ),
        ),
      );
    }

    // Has group but no transactions yet
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
        children: [
          const Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.textMuted),
          const SizedBox(height: 16),
          const Text('Sin movimientos aún', style: TextStyle(
            color: AppColors.textSecondary, fontSize: 16, fontWeight: FontWeight.w600,
          )),
          const SizedBox(height: 8),
          const Text(
            'Tocá el botón + para agregar\ntu primer movimiento',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.00');
    final isIncome = transaction.isIncome;
    final color = isIncome ? AppColors.income : AppColors.expense;
    final dateStr = DateFormat('dd/MM/yyyy').format(transaction.date);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            child: Icon(
              isIncome ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      transaction.user?.name ?? '',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                    ),
                    const Text(' · ', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    Text(dateStr, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : '-'}${transaction.currency.symbol} ${fmt.format(transaction.amount)}',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
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
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
        height: 72,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
