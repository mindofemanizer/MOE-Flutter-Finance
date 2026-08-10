# Changelog

## 1.0.0 — 2026-08-10

### Added
- Initial release
- `TransactionType` — income (Pemasukan) vs expense (Pengeluaran)
- `AccountCategory` — operating revenue, COGS, operating expenses, capex, tax, interest
- `PaymentMethod` — cash, bank transfer, e-wallet, credit/debit cards, check
- `TransactionModel` — full financial transaction data
- `FinanceRepository` — transactions CRUD, summary calculations, balance sheet
- `TransactionsNotifier` — create/list/delete transactions with date filtering
- `SummaryNotifier` — total income/expense/net profit for date range
- `MoeFinanceConfig` — configurable API URL + multi-currency support

### Features
- Income/expense classification
- Date range filtering (start_date, end_date)
- Automatic summary calculation (net profit = income - expense)
- Balance sheet retrieval
- Multi-currency support
- Payment method tracking
- Reference number generation
- Notes and descriptions
