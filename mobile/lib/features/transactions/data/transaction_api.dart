import 'package:dio/dio.dart';
import '../models/transaction.dart';

class TransactionApi {
  TransactionApi(this._dio);

  final Dio _dio;

  Future<List<Transaction>> listTransactions({
    int limit = 50,
    int offset = 0,
  }) async {
    final response = await _dio.get<List<dynamic>>(
      '/api/v1/transactions',
      queryParameters: {'limit': limit, 'offset': offset},
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
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/transactions',
      data: {
        'kind': kind.name,
        'amount': amount,
        'currency': currency.toUpperCase(),
        'description': description,
        'occurred_at': occurredAt?.toIso8601String(),
        'category_id': categoryId,
        'cash_wallet_id': cashWalletId,
        'bank_account_id': bankAccountId,
        'credit_card_id': creditCardId,
        'target_cash_wallet_id': targetCashWalletId,
        'target_bank_account_id': targetBankAccountId,
      },
    );
    return Transaction.fromJson(response.data ?? <String, dynamic>{});
  }
}
