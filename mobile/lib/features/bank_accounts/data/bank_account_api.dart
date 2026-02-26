import 'package:dio/dio.dart';

import '../models/bank_account.dart';

class BankAccountApi {
  BankAccountApi(this._dio);

  final Dio _dio;

  Future<List<BankAccount>> listAccounts() async {
    final response = await _dio.get<List<dynamic>>('/api/v1/bank-accounts');
    final rows = response.data ?? <dynamic>[];
    return rows
        .whereType<Map<String, dynamic>>()
        .map(BankAccount.fromJson)
        .toList(growable: false);
  }

  Future<BankAccount> createAccount({
    required String name,
    String? bankName,
    required double balance,
    required String currency,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/bank-accounts',
      data: {
        'name': name,
        'bank_name': bankName,
        'balance': balance,
        'currency': currency.toUpperCase(),
      },
    );
    return BankAccount.fromJson(response.data ?? <String, dynamic>{});
  }

  Future<BankAccount> updateAccount({
    required String accountId,
    String? name,
    String? bankName,
    double? balance,
    String? currency,
  }) async {
    final payload = <String, dynamic>{};
    if (name != null) {
      payload['name'] = name;
    }
    if (bankName != null) {
      payload['bank_name'] = bankName;
    }
    if (balance != null) {
      payload['balance'] = balance;
    }
    if (currency != null) {
      payload['currency'] = currency.toUpperCase();
    }

    final response = await _dio.patch<Map<String, dynamic>>(
      '/api/v1/bank-accounts/$accountId',
      data: payload,
    );
    return BankAccount.fromJson(response.data ?? <String, dynamic>{});
  }

  Future<void> deleteAccount(String accountId) async {
    await _dio.delete<Map<String, dynamic>>('/api/v1/bank-accounts/$accountId');
  }
}
