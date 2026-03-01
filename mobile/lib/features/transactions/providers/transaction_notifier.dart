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
    await loadWithFilters(limit: limit, offset: offset);
  }

  Future<void> loadWithFilters({
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
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final fetched = await _transactionApi.listTransactions(
        limit: limit,
        offset: offset,
        kind: kind,
        categoryId: categoryId,
        cashWalletId: cashWalletId,
        bankAccountId: bankAccountId,
        creditCardId: creditCardId,
        occurredFrom: occurredFrom,
        occurredTo: occurredTo,
      );
      if (offset == 0) {
        _transactions = fetched;
      } else {
        _transactions = [..._transactions, ...fetched];
      }
    } on DioException catch (error) {
      _error = _extractError(error);
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

  Future<bool> updateTransaction({
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
    _submitting = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _transactionApi.updateTransaction(
        transactionId: transactionId,
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
      _transactions = _transactions
          .map((transaction) => transaction.id == transactionId ? updated : transaction)
          .toList(growable: false);
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

  Future<bool> deleteTransaction(String transactionId) async {
    _submitting = true;
    _error = null;
    notifyListeners();

    try {
      await _transactionApi.deleteTransaction(transactionId);
      _transactions = _transactions
          .where((transaction) => transaction.id != transactionId)
          .toList(growable: false);
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
      final details = data['details'];
      if (details is List && details.isNotEmpty && details.first is Map) {
        final first = details.first as Map;
        final msg = first['msg'];
        if (msg is String && msg.isNotEmpty) {
          final loc = first['loc'];
          if (loc is List && loc.length >= 2) {
            final field = loc.last;
            return '$msg (field: $field)';
          }
          return msg;
        }
      }

      final message = data['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
      if (details is Map<String, dynamic>) {
        final detailsMessage = details['message'];
        if (detailsMessage is String && detailsMessage.isNotEmpty) {
          return detailsMessage;
        }
      }
    }
    if (error.response == null) {
      final uri = error.requestOptions.uri;
      return 'No se pudo conectar al backend (${uri.scheme}://${uri.host}:${uri.port}).';
    }
    return 'No se pudo guardar la transaccion.';
  }
}
