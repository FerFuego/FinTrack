import 'user_model.dart';

enum TransactionType { income, expense }

enum Currency { ARS, USD, EUR }

extension TransactionTypeExt on TransactionType {
  String get label => this == TransactionType.income ? 'Ingreso' : 'Egreso';
  String get apiValue => this == TransactionType.income ? 'income' : 'expense';
}

extension CurrencyExt on Currency {
  String get symbol {
    switch (this) {
      case Currency.ARS:
        return '\$';
      case Currency.USD:
        return 'USD';
      case Currency.EUR:
        return '€';
    }
  }

  String get flag {
    switch (this) {
      case Currency.ARS:
        return '🇦🇷';
      case Currency.USD:
        return '🇺🇸';
      case Currency.EUR:
        return '🇪🇺';
    }
  }
}

class TransactionModel {
  final int id;
  final int groupId;
  final int userId;
  final double amount;
  final Currency currency;
  final String description;
  final TransactionType type;
  final DateTime date;
  final String? category;
  final String? notes;
  final UserModel? user;
  final String? createdAt;

  const TransactionModel({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.amount,
    required this.currency,
    required this.description,
    required this.type,
    required this.date,
    this.category,
    this.notes,
    this.user,
    this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    final currencyStr = json['currency'] as String? ?? 'ARS';
    final typeStr = json['type'] as String? ?? 'expense';

    return TransactionModel(
      id: json['id'] as int,
      groupId: json['group_id'] as int,
      userId: json['user_id'] as int,
      amount: double.parse(json['amount'].toString()),
      currency: Currency.values.firstWhere(
        (c) => c.name == currencyStr,
        orElse: () => Currency.ARS,
      ),
      description: json['description'] as String,
      type: typeStr == 'income' ? TransactionType.income : TransactionType.expense,
      date: DateTime.parse(json['date'] as String),
      category: json['category'] as String?,
      notes: json['notes'] as String?,
      user: json['user'] != null
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      createdAt: json['created_at'] as String?,
    );
  }

  bool get isIncome => type == TransactionType.income;
  bool get isExpense => type == TransactionType.expense;

  String get formattedAmount {
    final symbol = currency.symbol;
    final formatted = amount.toStringAsFixed(2);
    return isIncome ? '+$symbol $formatted' : '-$symbol $formatted';
  }
}
