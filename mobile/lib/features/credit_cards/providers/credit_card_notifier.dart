import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/network/api_client.dart';
import '../data/credit_card_api.dart';
import '../models/credit_card.dart';

final creditCardNotifierProvider = ChangeNotifierProvider<CreditCardNotifier>((
  ref,
) {
  return CreditCardNotifier(creditCardApi: ref.read(creditCardApiProvider));
});

class CreditCardNotifier extends ChangeNotifier {
  CreditCardNotifier({required CreditCardApi creditCardApi})
    : _creditCardApi = creditCardApi;

  final CreditCardApi _creditCardApi;

  List<CreditCard> _cards = <CreditCard>[];
  bool _loading = false;
  bool _submitting = false;
  String? _error;

  List<CreditCard> get cards => _cards;
  bool get isLoading => _loading;
  bool get isSubmitting => _submitting;
  String? get error => _error;

  double get totalDebt => _cards.fold(0, (sum, card) => sum + card.currentDebt);
  double get totalLimit =>
      _cards.fold(0, (sum, card) => sum + card.creditLimit);

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _cards = await _creditCardApi.listCards();
    } on DioException catch (error) {
      _error = error.message;
    } catch (error) {
      _error = error.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> createCard({
    required String name,
    String? issuer,
    required String tier,
    required double creditLimit,
    required double currentDebt,
    int? statementDay,
    int? dueDay,
    required String currency,
  }) async {
    _submitting = true;
    _error = null;
    notifyListeners();

    try {
      final created = await _creditCardApi.createCard(
        name: name,
        issuer: issuer,
        tier: tier,
        creditLimit: creditLimit,
        currentDebt: currentDebt,
        statementDay: statementDay,
        due_day: dueDay,
        currency: currency,
      );
      _cards = [created, ..._cards];
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

  Future<bool> deleteCard(String cardId) async {
    _submitting = true;
    _error = null;
    notifyListeners();

    try {
      await _creditCardApi.deleteCard(cardId);
      _cards = _cards.where((card) => card.id != cardId).toList();
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
