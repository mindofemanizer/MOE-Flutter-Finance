# MOE-Flutter-Finance

Finance package for MOE Flutter ecosystem — income, expenses, accounting.

## Installation

```yaml
dependencies:
  moe_flutter_finance:
    git:
      url: https://github.com/mindofemanizer/MOE-Flutter-Finance.git
      ref: master
```

## Usage

### Setup

```dart
import 'package:moe_flutter_foundation/moe_flutter_foundation.dart';
import 'package:moe_flutter_finance/moe_flutter_finance.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  await MoeFoundation.setup(
    envConfig: EnvConfig.fromEnvironment(),
    sharedPreferences: prefs,
  );

  MoeFinance.setup(
    config: MoeFinanceConfig(
      apiUrl: 'https://api.kioskit.com/api/finance',
      defaultCurrency: CurrencyCode.IDR,
      enableMultiCurrency: false,
    ),
  );

  runApp(MoeFoundationProviderScope(child: MyApp()));
}
```

### Create Transactions

```dart
// Record income (penjualan produk)
await ref.read(transactionsProvider.notifier).createTransaction(
  type: TransactionType.income,
  category: 'product_sales',
  accountCategory: AccountCategory.operatingRevenue,
  amount: 150000,
  paymentMethod: PaymentMethod.bankTransfer.code,
  description: 'Penjualan produk A',
  notes: 'Cashback 5%',
);

// Record expense (biaya operasional)
await ref.read(transactionsProvider.notifier).createTransaction(
  type: TransactionType.expense,
  category: 'utilities',
  accountCategory: AccountCategory.operatingExpenses,
  amount: 5000,
  paymentMethod: PaymentMethod.eWallet.code,
  description: 'Tagihan listrik Agustus',
);
```

### List Transactions

```dart
final state = ref.watch(transactionsProvider);

// Filter by date range
await ref.read(transactionsProvider.notifier).loadTransactions(
  startDate: DateTime(2026, 8, 1),
  endDate: DateTime(2026, 8, 31),
  type: TransactionType.income, // or .expense
);

switch (state) {
  case TransactionsLoaded(:final transactions):
    ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (ctx, i) => Card(
        child: ListTile(
          title: Text(transactions[i].description ?? transactions[i].referenceNumber),
          subtitle: Text(transactions[i].createdAt.toLocal().toString()),
          trailing: Text(
            transactions[i].formattedAmount,
            style: TextStyle(
              color: transactions[i].type == TransactionType.income 
                  ? Colors.green 
                  : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  default:
    // loading/error
}
```

### Financial Summary

```dart
final summaryState = ref.watch(summaryProvider);

// Calculate summary for August 2026
await ref.read(summaryProvider.notifier).calculateSummary(
  startDate: DateTime(2026, 8, 1),
  endDate: DateTime(2026, 8, 31),
);

// Or filter only income
await ref.read(summaryProvider.notifier).calculateSummary(
  startDate: DateTime(2026, 8, 1),
  endDate: DateTime(2026, 8, 31),
  onlyType: TransactionType.income,
);

switch (summaryState) {
  case SummaryLoaded(:final summary):
    print('Total Pendapatan: Rp ${Formatters.currency(summary['totalIncome'] ?? 0)}');
    print('Total Pengeluaran: Rp ${Formatters.currency(summary['totalExpense'] ?? 0)}');
    print('Laba Bersih: Rp ${Formatters.currency(summary['netProfit'] ?? 0)}');
    print('Jumlah Transaksi: ${summary['transactionCount']}');
    
    // Net profit calculation
    if ((summary['netProfit'] ?? 0) > 0) {
      print('💰 Profit!');
    } else {
      print('⚠️  Rugi atau break even');
    }
  default:
    // loading/error
}
```

### Get Balance Sheet

```dart
final result = await ref.read(financeRepositoryProvider).getBalanceSheet();

if (result is Ok) {
  final balance = result.data;
  print('Assets: Rp ${Formatters.currency(balance['assets'] ?? 0)}');
  print('Liabilities: Rp ${Formatters.currency(balance['liabilities'] ?? 0)}');
  print('Equity: Rp ${Formatters.currency(balance['equity'] ?? 0)}');
  
  // Check accounting equation: Assets = Liabilities + Equity
  final check = (balance['assets'] ?? 0) == 
                (balance['liabilities'] ?? 0) + (balance['equity'] ?? 0);
  print(check ? '✅ Akuntansi seimbang' : '⚠️ Ketidakseimbangan akuntansi');
}
```

## What's Included

| Module | Description |
|--------|-------------|
| `TransactionModel` | Complete financial transaction record |
| `TransactionType` | Income vs Expense classification |
| `AccountCategory` | Revenue/COGS/OpEx/CapEx/Tax/Interest buckets |
| `PaymentMethod` | Cash/Bank/E-Wallet/Card options |
| `FinanceRepository` | Transactions CRUD, summaries, balance sheet |
| `TransactionsNotifier` | Create/filter/delete transactions |
| `SummaryNotifier` | Auto-calculate income/expense/net profit |

## Accounting Categories

**Revenue:**
- `operating_revenue` — Pendapatan Operasional (primary business income)
- `non_operating_revenue` — Pendapatan Non-Operasional (other income)

**Costs & Expenses:**
- `cogs` — Harga Pokok Penjualan (HPP)
- `operating_expenses` — Biaya Operasional (rent, utilities, salaries)
- `capex` — Belanja Modal (equipment, furniture)
- `tax` — Pajak
- `interest` — Bunga

Net Profit Formula: **Income - Expense = Net Profit**
