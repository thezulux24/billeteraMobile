import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/network/api_client.dart';
import '../data/cash_wallet_api.dart';
import '../models/cash_wallet.dart';

final cashWalletNotifierProvider = ChangeNotifierProvider<CashWalletNotifier>((
  ref,
) {
  return CashWalletNotifier(cashWalletApi: ref.read(cashWalletApiProvider));
});

class CashWalletNotifier extends ChangeNotifier {
  CashWalletNotifier({required CashWalletApi cashWalletApi})
    : _cashWalletApi = cashWalletApi;

  final CashWalletApi _cashWalletApi;

  List<CashWallet> _wallets = <CashWallet>[];
  bool _loading = false;
  bool _submitting = false;
  String? _error;

  List<CashWallet> get wallets => _wallets;
  bool get isLoading => _loading;
  bool get isSubmitting => _submitting;
  String? get error => _error;

  double get totalBalance =>
      _wallets.fold(0, (sum, wallet) => sum + wallet.balance);

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _wallets = await _cashWalletApi.listWallets();
    } on DioException catch (error) {
      _error = _extractError(error);
    } catch (error) {
      _error = error.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> createWallet({
    required String name,
    required double balance,
    required String currency,
  }) async {
    _submitting = true;
    _error = null;
    notifyListeners();

    try {
      final created = await _cashWalletApi.createWallet(
        name: name,
        balance: balance,
        currency: currency,
      );
      _wallets = [created, ..._wallets];
      return true;
    } on DioException catch (error) {
      _error = _extractError(error);
      return false;
    } catch (error) {
      _error = error.toString();
      return false;
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }

  Future<bool> deleteWallet(String walletId) async {
    _submitting = true;
    _error = null;
    notifyListeners();

    try {
      await _cashWalletApi.deleteWallet(walletId);
      _wallets = _wallets.where((wallet) => wallet.id != walletId).toList();
      return true;
    } on DioException catch (error) {
      _error = _extractError(error);
      return false;
    } catch (error) {
      _error = error.toString();
      return false;
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }

  String _extractError(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }
    if (error.response == null) {
      final uri = error.requestOptions.uri;
      return 'No se pudo conectar al backend (${uri.scheme}://${uri.host}:${uri.port}).';
    }
    return 'No se pudo completar la operacion.';
  }
}
