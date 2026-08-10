import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:moe_flutter_core/moe_flutter_core.dart';
import 'package:moe_flutter_finance/src/config/finance_config.dart';
import 'package:moe_flutter_finance/src/models/transaction_model.dart';
import 'package:moe_flutter_finance/src/models/transaction_type.dart';
import 'package:moe_flutter_finance/src/models/account_category.dart';

/// Repository for finance operations.
class FinanceRepository {
  final Dio _dio;
  final MoeFinanceConfig _config;

  FinanceRepository(this._dio, this._config);

  // ── Transactions ───────────────────────────────────────────

  /// List transactions with filtering.
  Future<AppResult<List<TransactionModel>>> listTransactions({
    DateTime? startDate,
    DateTime? endDate,
    TransactionType? type,
    String? accountCategory,
    String? category,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final params = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (startDate != null) 'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
        if (type != null) 'type': type.stringValue,
        if (accountCategory != null) 'account_category': accountCategory,
        if (category != null) 'category': category,
      };
      final response = await _dio.get('/transactions', queryParameters: params);
      final data = response.data as Map<String, dynamic>;
      final transactions = (data['data'] as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map((t) => TransactionModel.fromJson(t))
          .toList();
      return Ok(transactions);
    } on DioException catch (e) {
      return Err(mapDioErrorToFailure(e));
    } catch (e) {
      return Err(AppFailure(
        type: FailureType.unknown,
        message: e.toString(),
      ));
    }
  }

  /// Get single transaction by ID.
  Future<AppResult<TransactionModel>> getTransaction(String id) async {
    try {
      final response = await _dio.get('/transactions/$id');
      return Ok(TransactionModel.fromJson(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Err(mapDioErrorToFailure(e));
    } catch (e) {
      return Err(AppFailure(
        type: FailureType.unknown,
        message: e.toString(),
      ));
    }
  }

  /// Create new transaction (income or expense).
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
    try {
      final response = await _dio.post('/transactions', data: {
        'type': type.stringValue,
        'category': category,
        'account_category': accountCategory.code,
        'amount': amount,
        'payment_method': paymentMethod,
        if (description != null) 'description': description,
        if (occurredAt != null) 'occurred_at': occurredAt.toIso8601String(),
        if (notes != null) 'notes': notes,
      });
      return Ok(TransactionModel.fromJson(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Err(mapDioErrorToFailure(e));
    } catch (e) {
      return Err(AppFailure(
        type: FailureType.unknown,
        message: e.toString(),
      ));
    }
  }

  /// Update transaction.
  Future<AppResult<void>> updateTransaction(String id, {
    String? category,
    String? paymentMethod,
    double? amount,
    String? description,
    String? notes,
  }) async {
    try {
      await _dio.patch('/transactions/$id', data: {
        if (category != null) 'category': category,
        if (paymentMethod != null) 'payment_method': paymentMethod,
        if (amount != null) 'amount': amount,
        if (description != null) 'description': description,
        if (notes != null) 'notes': notes,
      });
      return const Ok(null);
    } on DioException catch (e) {
      return Err(mapDioErrorToFailure(e));
    } catch (e) {
      return Err(AppFailure(
        type: FailureType.unknown,
        message: e.toString(),
      ));
    }
  }

  /// Delete transaction.
  Future<AppResult<void>> deleteTransaction(String id) async {
    try {
      await _dio.delete('/transactions/$id');
      return const Ok(null);
    } on DioException catch (e) {
      return Err(mapDioErrorToFailure(e));
    } catch (e) {
      return Err(AppFailure(
        type: FailureType.unknown,
        message: e.toString(),
      ));
    }
  }

  // ── Financial Summary ──────────────────────────────────────

  /// Calculate financial summary for date range.
  Future<AppResult<Map<String, double>>> calculateSummary({
    required DateTime startDate,
    required DateTime endDate,
    TransactionType? onlyType,
  }) async {
    try {
      final params = <String, dynamic>{
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        if (onlyType != null) 'type': onlyType.stringValue,
      };
      final response = await _dio.get('/summary', queryParameters: params);
      final data = response.data as Map<String, dynamic>;
      return Ok({
        'totalIncome': (data['total_income'] as num).toDouble(),
        'totalExpense': (data['total_expense'] as num).toDouble(),
        'netProfit': (data['net_profit'] as num).toDouble(),
        'transactionCount': (data['transaction_count'] as num).toInt(),
      });
    } on DioException catch (e) {
      return Err(mapDioErrorToFailure(e));
    } catch (e) {
      return Err(AppFailure(
        type: FailureType.unknown,
        message: e.toString(),
      ));
    }
  }

  /// Get balance sheet summary.
  Future<AppResult<Map<String, double>>> getBalanceSheet() async {
    try {
      final response = await _dio.get('/balance-sheet');
      final data = response.data as Map<String, dynamic>;
      return Ok({
        'assets': (data['assets'] as num).toDouble(),
        'liabilities': (data['liabilities'] as num).toDouble(),
        'equity': (data['equity'] as num).toDouble(),
      });
    } on DioException catch (e) {
      return Err(mapDioErrorToFailure(e));
    } catch (e) {
      return Err(AppFailure(
        type: FailureType.unknown,
        message: e.toString(),
      ));
    }
  }
}
