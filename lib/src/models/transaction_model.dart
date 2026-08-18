import 'package:equatable/equatable.dart';

import 'package:moe_flutter_core/moe_flutter_core.dart';
import 'package:moe_flutter_finance/src/models/account_category.dart';
import 'package:moe_flutter_finance/src/models/transaction_type.dart';

/// Model representing a financial transaction.
class TransactionModel extends Equatable {
  final String id;
  final String referenceNumber;
  final TransactionType type;
  final String category;
  final AccountCategory accountCategory;
  final double amount;
  final CurrencyCode currency;
  final String paymentMethod;
  final String? description;
  final DateTime occurredAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? notes;

  const TransactionModel({
    required this.id,
    required this.referenceNumber,
    required this.type,
    required this.category,
    required this.accountCategory,
    required this.amount,
    this.currency = CurrencyCode.IDR,
    required this.paymentMethod,
    this.description,
    required this.occurredAt,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.notes,
  }) : assert(amount > 0);

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      referenceNumber: json['reference_number'] as String,
      type: TransactionType.fromString(json['type'] as String),
      category: json['category'] as String,
      accountCategory: AccountCategory.values.firstWhere(
        (a) => a.code == json['account_category'],
        orElse: () => AccountCategory.operatingExpenses,
      ),
      amount: (json['amount'] as num).toDouble(),
      currency: CurrencyCode.values.firstWhere(
        (c) => c.code == json['currency'],
        orElse: () => CurrencyCode.IDR,
      ),
      paymentMethod: json['payment_method'] as String,
      description: json['description'] as String?,
      occurredAt: DateTime.parse(json['occurred_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      createdBy: json['created_by'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reference_number': referenceNumber,
      'type': type.stringValue,
      'category': category,
      'account_category': accountCategory.code,
      'amount': amount,
      'currency': currency.code,
      'payment_method': paymentMethod,
      if (description != null) 'description': description,
      'occurred_at': occurredAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (createdBy != null) 'created_by': createdBy,
      if (notes != null) 'notes': notes,
    };
  }

  /// Format amount with currency symbol.
  String get formattedAmount => '${currency.symbol}${Formatters.number(amount)}';

  @override
  List<Object?> get props => [
        id,
        referenceNumber,
        type,
        category,
        accountCategory,
        amount,
        currency,
        paymentMethod,
        description,
        occurredAt,
        createdAt,
        updatedAt,
        createdBy,
        notes,
      ];
}
