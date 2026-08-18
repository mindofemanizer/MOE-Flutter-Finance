import 'package:flutter/material.dart';

/// Transaction type (income or expense).
sealed class TransactionType {
  const TransactionType();
  
  String get stringValue;
  
  factory TransactionType.fromString(String value) {
    switch (value) {
      case 'income':
        return income;
      case 'expense':
        return expense;
      default:
        throw Exception('Unknown transaction type: $value');
    }
  }

  static const income = _TransactionTypeIncome();
  static const expense = _TransactionTypeExpense();
}

class _TransactionTypeIncome extends TransactionType {
  const _TransactionTypeIncome();
  @override
  String get stringValue => 'income';
  String get displayName => 'Pemasukan';
  ColorValue get color => const ColorValue(0xFF4CAF50); // Green
}

class _TransactionTypeExpense extends TransactionType {
  const _TransactionTypeExpense();
  @override
  String get stringValue => 'expense';
  String get displayName => 'Pengeluaran';
  ColorValue get color => const ColorValue(0xFFF44336); // Red
}

class ColorValue extends Color {
  const ColorValue(super.value);
}
