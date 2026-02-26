import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/network/api_client.dart';
import '../data/bank_account_api.dart';
import '../models/bank_account.dart';

final bankAccountNotifierProvider = ChangeNotifierProvider<BankAccountNotifier>(
  (ref) {
    return BankAccountNotifier(
      bankAccountApi: ref.read(bankAccountApiProvider),
    );
  },
);

class BankAccountNotifier extends ChangeNotifier {
  BankAccountNotifier({required BankAccountApi bankAccountApi})
    : _bankAccountApi = bankAccountApi;

  final BankAccountApi _bankAccountApi;

  List<BankAccount> _accounts = <BankAccount>[];
  bool _loading = false;
  bool _submitting = false;
  String? _error;

  List<BankAccount> get accounts => _accounts;
  bool get isLoading => _loading;
  bool get isSubmitting => _submitting;
  String? get error => _error;

  double get totalBalance =>
      _accounts.fold(0, (sum, account) => sum + account.balance);

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _accounts = await _bankAccountApi.listAccounts();
    } on DioException catch (error) {
      _error = _extractError(error);
    } catch (error) {
      _error = error.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> createAccount({
    required String name,
    String? bankName,
    required double balance,
    required String currency,
  }) async {
    _submitting = true;
    _error = null;
    notifyListeners();

    try {
      final created = await _bankAccountApi.createAccount(
        name: name,
        bankName: bankName,
        balance: balance,
        currency: currency,
      );
      _accounts = [created, ..._accounts];
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

  Future<bool> deleteAccount(String accountId) async {
    _submitting = true;
    _error = null;
    notifyListeners();

    try {
      await _bankAccountApi.deleteAccount(accountId);
      _accounts = _accounts
          .where((account) => account.id != accountId)
          .toList();
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
