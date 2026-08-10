import 'package:flutter_test/flutter_test.dart';
import 'package:moe_flutter_finance/moe_flutter_finance.dart';

void main() {
  group('TransactionType', () {
    test('has correct values', () {
      expect(TransactionType.income.stringValue, equals('income'));
      expect(TransactionType.expense.stringValue, equals('expense'));
      expect(TransactionType.income.displayName, equals('Pemasukan'));
      expect(TransactionType.expense.displayName, equals('Pengeluaran'));
    });

    test('fromString parses correctly', () {
      expect(TransactionType.fromString('income'), equals(TransactionType.income));
      expect(TransactionType.fromString('expense'), equals(TransactionType.expense));
    });
  });

  group('AccountCategory', () {
    test('has correct codes and display names', () {
      expect(AccountCategory.operatingRevenue.code, equals('operating_revenue'));
      expect(AccountCategory.operatingRevenue.displayName, equals('Pendapatan Operasional'));
      
      expect(AccountCategory.costOfGoodsSold.code, equals('cogs'));
      expect(AccountCategory.costOfGoodsSold.displayName, equals('HPP'));
    });
  });

  group('TransactionModel', () {
    test('formattedAmount returns currency formatted string', () {
      const transaction = TransactionModel(
        id: 't1',
        referenceNumber: 'REF-001',
        type: TransactionType.income,
        category: 'sales',
        accountCategory: AccountCategory.operatingRevenue,
        amount: 50000,
        currency: CurrencyCode.IDR,
        paymentMethod: PaymentMethod.cash.code,
        occurredAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(transaction.formattedAmount, contains('Rp 50.000'));
    });

    test('fromJson parses all fields', () {
      final json = {
        'id': 'trans1',
        'reference_number': 'REF-2026-001',
        'type': 'income',
        'category': 'product_sales',
        'account_category': 'operating_revenue',
        'amount': 150000,
        'currency': 'IDR',
        'payment_method': 'bank_transfer',
        'description': 'Penjualan produk A',
        'occurred_at': '2026-08-10T10:00:00.000Z',
        'created_at': '2026-08-10T12:00:00.000Z',
        'updated_at': '2026-08-10T12:00:00.000Z',
        'created_by': 'user1',
        'notes': 'Cashback 5%',
      };

      final transaction = TransactionModel.fromJson(json);

      expect(transaction.id, equals('trans1'));
      expect(transaction.referenceNumber, equals('REF-2026-001'));
      expect(transaction.type, equals(TransactionType.income));
      expect(transaction.category, equals('product_sales'));
      expect(transaction.accountCategory, equals(AccountCategory.operatingRevenue));
      expect(transaction.amount, equals(150000));
      expect(transaction.currency, equals(CurrencyCode.IDR));
      expect(transaction.paymentMethod, equals(PaymentMethod.bankTransfer.code));
      expect(transaction.description, equals('Penjualan produk A'));
      expect(transaction.createdBy, equals('user1'));
      expect(transaction.notes, equals('Cashback 5%'));
    });

    test('toJson round-trips correctly', () {
      const transaction = TransactionModel(
        id: 't1',
        referenceNumber: 'REF-001',
        type: TransactionType.expense,
        category: 'utilities',
        accountCategory: AccountCategory.operatingExpenses,
        amount: 5000,
        currency: CurrencyCode.IDR,
        paymentMethod: PaymentMethod.eWallet.code,
        description: 'Tagihan listrik',
        occurredAt: DateTime(2026, 8, 10),
        createdAt: DateTime(2026, 8, 10),
        updatedAt: DateTime(2026, 8, 10),
        notes: 'Biaya bulan Agustus',
      );

      final json = transaction.toJson();

      expect(json['type'], equals('expense'));
      expect(json['amount'], equals(5000));
      expect(json['payment_method'], equals(PaymentMethod.eWallet.code));
      expect(json['notes'], equals('Biaya bulan Agustus'));
    });

    test('assertion fails on zero or negative amount', () {
      expect(
        () => TransactionModel(
          id: 't1',
          referenceNumber: 'REF-001',
          type: TransactionType.income,
          category: 'sales',
          accountCategory: AccountCategory.operatingRevenue,
          amount: 0,
          paymentMethod: 'cash',
          occurredAt: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        throwsA(isAssertionError),
      );
    });
  });

  group('PaymentMethod', () {
    test('has correct codes and display names', () {
      expect(PaymentMethod.cash.code, equals('cash'));
      expect(PaymentMethod.cash.displayName, equals('Tunai'));
      
      expect(PaymentMethod.bankTransfer.code, equals('bank_transfer'));
      expect(PaymentMethod.bankTransfer.displayName, equals('Transfer Bank'));
    });

    test('fromValue returns default for unknown', () {
      expect(PaymentMethod.fromValue('invalid'), equals(PaymentMethod.other));
      expect(PaymentMethod.fromValue('ewallet'), equals(PaymentMethod.eWallet));
    });
  });

  group('MoeFinanceConfig', () {
    test('has correct defaults', () {
      const config = MoeFinanceConfig(
        apiUrl: 'https://api.example.com',
      );

      expect(config.apiUrl, equals('https://api.example.com'));
      expect(config.defaultCurrency, equals(CurrencyCode.IDR));
      expect(config.enableMultiCurrency, isTrue);
    });
  });
}
