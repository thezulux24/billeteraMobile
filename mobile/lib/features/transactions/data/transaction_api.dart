import 'package:dio/dio.dart';
import '../models/transaction.dart';

class TransactionApi {
  TransactionApi(this._dio);

  final Dio _dio;

  Future<List<Transaction>> listTransactions({
    int limit = 50,
    int offset = 0,
    TransactionKind? kind,
    String? categoryId,
    String? cashWalletId,
    String? bankAccountId,
    String? creditCardId,
    DateTime? occurredFrom,
    DateTime? occurredTo,
  }) async {
    final queryParameters = <String, dynamic>{
      'limit': limit,
      'offset': offset,
      if (kind case final kindValue?) 'kind': _kindToApiValue(kindValue),
      'category_id': ?categoryId,
      'cash_wallet_id': ?cashWalletId,
      'bank_account_id': ?bankAccountId,
      'credit_card_id': ?creditCardId,
      if (occurredFrom case final occurredFromValue?)
        'occurred_from': occurredFromValue.toIso8601String(),
      if (occurredTo case final occurredToValue?)
        'occurred_to': occurredToValue.toIso8601String(),
    };

    final response = await _dio.get<List<dynamic>>(
      '/api/v1/transactions',
      queryParameters: queryParameters,
    );
    final rows = response.data ?? <dynamic>[];
    return rows
        .whereType<Map<String, dynamic>>()
        .map(Transaction.fromJson)
        .toList(growable: false);
  }

  Future<Transaction> createTransaction({
    required TransactionKind kind,
    required double amount,
    required String currency,
    String? description,
    DateTime? occurredAt,
    String? categoryId,
    String? cashWalletId,
    String? bankAccountId,
    String? creditCardId,
    String? targetCashWalletId,
    String? targetBankAccountId,
  }) async {
    final occurredAtIso = occurredAt?.toIso8601String();
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/transactions',
      data: {
        'kind': _kindToApiValue(kind),
        'amount': amount,
        'currency': currency.toUpperCase(),
        'description': ?description,
        'occurred_at': ?occurredAtIso,
        'category_id': ?categoryId,
        'cash_wallet_id': ?cashWalletId,
        'bank_account_id': ?bankAccountId,
        'credit_card_id': ?creditCardId,
        'target_cash_wallet_id': ?targetCashWalletId,
        'target_bank_account_id': ?targetBankAccountId,
      },
    );
    return Transaction.fromJson(response.data ?? <String, dynamic>{});
  }

  Future<Transaction> updateTransaction({
    required String transactionId,
    TransactionKind? kind,
    double? amount,
    String? currency,
    String? description,
    DateTime? occurredAt,
    String? categoryId,
    String? cashWalletId,
    String? bankAccountId,
    String? creditCardId,
    String? targetCashWalletId,
    String? targetBankAccountId,
  }) async {
    final payload = <String, dynamic>{
      if (kind case final kindValue?) 'kind': _kindToApiValue(kindValue),
      'amount': ?amount,
      if (currency case final currencyValue?) 'currency': currencyValue.toUpperCase(),
      'description': ?description,
      if (occurredAt case final occurredAtValue?)
        'occurred_at': occurredAtValue.toIso8601String(),
      'category_id': ?categoryId,
      'cash_wallet_id': ?cashWalletId,
      'bank_account_id': ?bankAccountId,
      'credit_card_id': ?creditCardId,
      'target_cash_wallet_id': ?targetCashWalletId,
      'target_bank_account_id': ?targetBankAccountId,
    };

    final response = await _dio.patch<Map<String, dynamic>>(
      '/api/v1/transactions/$transactionId',
      data: payload,
    );
    return Transaction.fromJson(response.data ?? <String, dynamic>{});
  }

  Future<void> deleteTransaction(String transactionId) async {
    await _dio.delete<Map<String, dynamic>>('/api/v1/transactions/$transactionId');
  }

  String _kindToApiValue(TransactionKind kind) {
    switch (kind) {
      case TransactionKind.income:
        return 'income';
      case TransactionKind.expense:
        return 'expense';
      case TransactionKind.transfer:
        return 'transfer';
      case TransactionKind.creditCharge:
        return 'credit_charge';
      case TransactionKind.creditPayment:
        return 'credit_payment';
    }
  }
}
