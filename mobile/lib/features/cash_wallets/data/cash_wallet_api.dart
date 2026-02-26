import 'package:dio/dio.dart';

import '../models/cash_wallet.dart';

class CashWalletApi {
  CashWalletApi(this._dio);

  final Dio _dio;

  Future<List<CashWallet>> listWallets() async {
    final response = await _dio.get<List<dynamic>>('/api/v1/cash-wallets');
    final rows = response.data ?? <dynamic>[];
    return rows
        .whereType<Map<String, dynamic>>()
        .map(CashWallet.fromJson)
        .toList(growable: false);
  }

  Future<CashWallet> createWallet({
    required String name,
    required double balance,
    required String currency,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/cash-wallets',
      data: {
        'name': name,
        'balance': balance,
        'currency': currency.toUpperCase(),
      },
    );
    return CashWallet.fromJson(response.data ?? <String, dynamic>{});
  }

  Future<CashWallet> updateWallet({
    required String walletId,
    String? name,
    double? balance,
    String? currency,
  }) async {
    final payload = <String, dynamic>{};
    if (name != null) {
      payload['name'] = name;
    }
    if (balance != null) {
      payload['balance'] = balance;
    }
    if (currency != null) {
      payload['currency'] = currency.toUpperCase();
    }

    final response = await _dio.patch<Map<String, dynamic>>(
      '/api/v1/cash-wallets/$walletId',
      data: payload,
    );
    return CashWallet.fromJson(response.data ?? <String, dynamic>{});
  }

  Future<void> deleteWallet(String walletId) async {
    await _dio.delete<Map<String, dynamic>>('/api/v1/cash-wallets/$walletId');
  }
}
