/// Payment method used for transaction.
enum PaymentMethod {
  cash('cash', 'Tunai'),
  bankTransfer('bank_transfer', 'Transfer Bank'),
  eWallet('ewallet', 'E-Wallet'),
  creditCard('credit_card', 'Kartu Kredit'),
  debitCard('debit_card', 'Kartu Debit'),
  check('check', 'Cek'),
  other('other', 'Lainnya');

  const PaymentMethod(this.code, this.displayName);
  final String code;
  final String displayName;

  factory PaymentMethod.fromValue(String value) {
    return values.firstWhere(
      (e) => e.code == value,
      orElse: () => other,
    );
  }
}

/// Account/Categories for finance tracking.
enum AccountCategory {
  operatingRevenue('operating_revenue', 'Pendapatan Operasional'),
  nonOperatingRevenue('non_operating_revenue', 'Pendapatan Non-Operasional'),
  costOfGoodsSold('cogs', 'HPP'),
  operatingExpenses('operating_expenses', 'Biaya Operasional'),
  capitalExpenditure('capex', 'Belanja Modal'),
  tax('tax', 'Pajak'),
  interest('interest', 'Bunga');

  const AccountCategory(this.code, this.displayName);
  final String code;
  final String displayName;
}
