import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:moe_flutter_core/moe_flutter_core.dart';
import 'package:moe_flutter_finance/src/config/finance_config.dart';
import 'package:moe_flutter_finance/src/models/transaction_model.dart';
import 'package:moe_flutter_finance/src/models/transaction_type.dart';
import 'package:moe_flutter_finance/src/services/finance_repository.dart';

/// State for transactions.
sealed class TransactionsState {
  const TransactionsState();
}

final class TransactionsInitial extends TransactionsState {}

final class TransactionsLoading extends TransactionsState {}

final class TransactionsLoaded extends TransactionsState {
  final List<TransactionModel> transactions;
  const TransactionsLoaded(this.transactions);
}

final class TransactionsError extends TransactionsState {
  final AppFailure failure;
  const TransactionsError(this.failure);
}

/// Notifier for transactions.
class TransactionsNotifier extends StateNotifier<TransactionsState> {
  final FinanceRepository _repository;

  TransactionsNotifier(this._repository) : super(const TransactionsInitial());

  Future<void> loadTransactions({
    DateTime? startDate,
    DateTime? endDate,
    TransactionType? type,
  }) async {
    state = const TransactionsLoading();

    final result = await _repository.listTransactions(
      startDate: startDate,
      endDate: endDate,
      type: type,
    );

    switch (result) {
      case Ok(:final data):
        state = TransactionsLoaded(data);
      case Err(:final failure):
        state = TransactionsError(failure);
    }
  }

  Future<AppResult<TransactionModel>> createTransaction({
    required TransactionType type,
    required String category,
    required AccountCategory accountCategory,
    required double amount,
    required String paymentMethod,
    String? description,
    DateTime? occurredAt,
    String? notes,
  }) async {
    final result = await _repository.createTransaction(
      type: type,
      category: category,
      accountCategory: accountCategory,
      amount: amount,
      paymentMethod: paymentMethod,
      description: description,
      occurredAt: occurredAt,
      notes: notes,
    );

    if (result is Ok && state is TransactionsLoaded) {
      final loaded = state as TransactionsLoaded;
      // Insert at beginning (newest first)
      final updated = [result.data, ...loaded.transactions];
      state = TransactionsLoaded(updated);
    }

    return result;
  }

  Future<void> deleteTransaction(String id) async {
    final result = await _repository.deleteTransaction(id);

    if (result is Ok && state is TransactionsLoaded) {
      final loaded = state as TransactionsLoaded;
      final filtered = loaded.transactions.where((t) => t.id != id).toList();
      state = TransactionsLoaded(filtered);
    }
  }
}

/// State for financial summary.
sealed class SummaryState {
  const SummaryState();
}

final class SummaryInitial extends SummaryState {}

final class SummaryLoading extends SummaryState {}

final class SummaryLoaded extends SummaryState {
  final Map<String, double> summary;
  const SummaryLoaded(this.summary);
}

final class SummaryError extends SummaryState {
  final AppFailure failure;
  const SummaryError(this.failure);
}

/// Notifier for financial summary.
class SummaryNotifier extends StateNotifier<SummaryState> {
  final FinanceRepository _repository;

  SummaryNotifier(this._repository) : super(const SummaryInitial());

  Future<void> calculateSummary({
    required DateTime startDate,
    required DateTime endDate,
    TransactionType? onlyType,
  }) async {
    state = const SummaryLoading();

    final result = await _repository.calculateSummary(
      startDate: startDate,
      endDate: endDate,
      onlyType: onlyType,
    );

    switch (result) {
      case Ok(:final data):
        state = SummaryLoaded(data);
      case Err(:final failure):
        state = SummaryError(failure);
    }
  }

  double get totalIncome => state is SummaryLoaded
      ? (state as SummaryLoaded).summary['totalIncome'] ?? 0
      : 0;

  double get totalExpense => state is SummaryLoaded
      ? (state as SummaryLoaded).summary['totalExpense'] ?? 0
      : 0;

  double get netProfit => state is SummaryLoaded
      ? (state as SummaryLoaded).summary['netProfit'] ?? 0
      : 0;

  int get transactionCount => state is SummaryLoaded
      ? (state as SummaryLoaded).summary['transactionCount']?.toInt() ?? 0
      : 0;
}

/// Provider for FinanceRepository.
final financeRepositoryProvider = Provider<FinanceRepository>((ref) {
  throw UnimplementedError('MoeFinance.setup() must be called before use.');
});

/// Provider for TransactionsNotifier.
final transactionsProvider = StateNotifierProviderFactory<TransactionsNotifier>(
  (ref) => TransactionsNotifier(ref.watch(financeRepositoryProvider)),
);

/// Provider for SummaryNotifier.
final summaryProvider = StateNotifierProviderFactory<SummaryNotifier>(
  (ref) => SummaryNotifier(ref.watch(financeRepositoryProvider)),
);
