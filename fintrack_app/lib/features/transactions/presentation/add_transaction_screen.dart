import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../data/transaction_repository.dart';
import '../../../shared/models/transaction_model.dart';
import '../../../core/constants/app_theme.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  final int groupId;
  const AddTransactionScreen({super.key, required this.groupId});

  @override
  ConsumerState<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  TransactionType _type = TransactionType.expense;
  Currency _currency = Currency.ARS;
  DateTime _date = DateTime.now();
  String? _category;
  bool _loading = false;

  final _categories = ['Alimentación', 'Transporte', 'Salud', 'Entretenimiento', 'Servicios', 'Educación', 'Otro'];

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      await ref.read(transactionRepositoryProvider).createTransaction(
        groupId: widget.groupId,
        amount: double.parse(_amountCtrl.text.replaceAll(',', '.')),
        currency: _currency.name,
        description: _descCtrl.text.trim(),
        type: _type.apiValue,
        date: DateFormat('yyyy-MM-dd').format(_date),
        category: _category,
        notes: _notesCtrl.text.isNotEmpty ? _notesCtrl.text : null,
      );

      if (mounted) {
        HapticFeedback.lightImpact();
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Movimiento agregado'),
            backgroundColor: AppColors.income,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.expense,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            surface: AppColors.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = _type == TransactionType.income;
    final accentColor = isIncome ? AppColors.income : AppColors.expense;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo movimiento'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type toggle
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: TransactionType.values.map((t) {
                    final isSelected = _type == t;
                    final isInc = t == TransactionType.income;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _type = t),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: isSelected ? (isInc ? AppColors.income : AppColors.expense) : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isInc ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                                color: isSelected ? Colors.white : AppColors.textMuted,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                t.label,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : AppColors.textMuted,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 24),

              // Amount + Currency
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _amountCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        labelText: 'Importe',
                        prefixText: _currency.symbol + ' ',
                        prefixStyle: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Ingresá el importe';
                        if (double.tryParse(v.replaceAll(',', '.')) == null) return 'Número inválido';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<Currency>(
                      value: _currency,
                      dropdownColor: AppColors.surface,
                      decoration: const InputDecoration(labelText: 'Moneda'),
                      items: Currency.values.map((c) => DropdownMenuItem(
                        value: c,
                        child: Text('${c.flag} ${c.name}'),
                      )).toList(),
                      onChanged: (c) => setState(() => _currency = c!),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.2),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descCtrl,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  prefixIcon: Icon(Icons.edit_outlined, color: AppColors.textMuted),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Ingresá una descripción';
                  return null;
                },
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
              const SizedBox(height: 16),

              // Category
              DropdownButtonFormField<String>(
                value: _category,
                dropdownColor: AppColors.surface,
                decoration: const InputDecoration(
                  labelText: 'Categoría (opcional)',
                  prefixIcon: Icon(Icons.category_outlined, color: AppColors.textMuted),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Sin categoría')),
                  ..._categories.map((c) => DropdownMenuItem(value: c, child: Text(c))),
                ],
                onChanged: (c) => setState(() => _category = c),
              ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.2),
              const SizedBox(height: 16),

              // Date picker
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, color: AppColors.textMuted, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        DateFormat('dd/MM/yyyy').format(_date),
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_drop_down, color: AppColors.textMuted),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: _notesCtrl,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Notas (opcional)',
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 40),
                    child: Icon(Icons.notes_outlined, color: AppColors.textMuted),
                  ),
                  alignLabelWithHint: true,
                ),
              ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.2),
              const SizedBox(height: 32),

              // Submit
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  shadowColor: accentColor.withOpacity(0.4),
                  elevation: 8,
                ),
                child: _loading
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(isIncome ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded),
                          const SizedBox(width: 8),
                          Text('Guardar ${_type.label}'),
                        ],
                      ),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
