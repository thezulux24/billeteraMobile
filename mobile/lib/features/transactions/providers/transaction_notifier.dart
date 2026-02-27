import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/network/api_client.dart';
import '../data/transaction_api.dart';
import '../models/transaction.dart';

final transactionNotifierProvider = ChangeNotifierProvider<TransactionNotifier>(
  (ref) {
    return TransactionNotifier(
      transactionApi: ref.read(transactionApiProvider),
    );
  },
);

class TransactionNotifier extends ChangeNotifier {
  TransactionNotifier({required TransactionApi transactionApi})
    : _transactionApi = transactionApi;

  final TransactionApi _transactionApi;

  List<Transaction> _transactions = <Transaction>[];
  bool _loading = false;
  bool _submitting = false;
  String? _error;

  List<Transaction> get transactions => _transactions;
  bool get isLoading => _loading;
  bool get isSubmitting => _submitting;
  String? get error => _error;

  Future<void> load({int limit = 50, int offset = 0}) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final fetched = await _transactionApi.listTransactions(
        limit: limit,
        offset: offset,
      );
      if (offset == 0) {
        _transactions = fetched;
      } else {
        _transactions = [..._transactions, ...fetched];
      }
    } on DioException catch (error) {
      _error = error.message;
    } catch (error) {
      _error = error.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> createTransaction({
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
    _submitting = true;
    _error = null;
    notifyListeners();

    try {
      final created = await _transactionApi.createTransaction(
        kind: kind,
        amount: amount,
        currency: currency,
        description: description,
        occurredAt: occurredAt,
        categoryId: categoryId,
        cashWalletId: cashWalletId,
        bankAccountId: bankAccountId,
        creditCardId: creditCardId,
        targetCashWalletId: targetCashWalletId,
        targetBankAccountId: targetBankAccountId,
      );
      _transactions = [created, ..._transactions];
      return true;
    } on DioException catch (error) {
      _error = error.message;
      return false;
    } catch (error) {
      _error = error.toString();
      return false;
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }
}
