import 'package:dio/dio.dart';
import '../models/credit_card.dart';

class CreditCardApi {
  CreditCardApi(this._dio);

  final Dio _dio;

  Future<List<CreditCard>> listCards() async {
    final response = await _dio.get<List<dynamic>>('/api/v1/credit-cards');
    final rows = response.data ?? <dynamic>[];
    return rows
        .whereType<Map<String, dynamic>>()
        .map(CreditCard.fromJson)
        .toList(growable: false);
  }

  Future<CreditCard> createCard({
    required String name,
    String? issuer,
    String? lastFour,
    String? cardProvider,
    required String tier,
    required double creditLimit,
    required double currentDebt,
    int? statementDay,
    int? dueDay,
    required String currency,
  }) async {
    final payload = <String, dynamic>{
      'name': name,
      'tier': tier.toLowerCase(),
      'credit_limit': creditLimit,
      'current_debt': currentDebt,
      'currency': currency.toUpperCase(),
    };
    if (issuer != null && issuer.isNotEmpty) payload['issuer'] = issuer;
    if (lastFour != null && lastFour.isNotEmpty)
      payload['last_four'] = lastFour;
    if (cardProvider != null)
      payload['card_provider'] = cardProvider.toLowerCase();
    if (statementDay != null) payload['statement_day'] = statementDay;
    if (dueDay != null) payload['due_day'] = dueDay;

    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/credit-cards',
      data: payload,
    );
    return CreditCard.fromJson(response.data ?? <String, dynamic>{});
  }

  Future<CreditCard> updateCard(
    String cardId, {
    String? name,
    String? issuer,
    String? lastFour,
    String? cardProvider,
    String? tier,
    double? creditLimit,
    double? currentDebt,
    int? statementDay,
    int? dueDay,
    String? currency,
  }) async {
    final payload = <String, dynamic>{};
    if (name != null) payload['name'] = name;
    if (issuer != null) payload['issuer'] = issuer;
    if (lastFour != null) payload['last_four'] = lastFour;
    if (cardProvider != null)
      payload['card_provider'] = cardProvider.toLowerCase();
    if (tier != null) payload['tier'] = tier.toLowerCase();
    if (creditLimit != null) payload['credit_limit'] = creditLimit;
    if (currentDebt != null) payload['current_debt'] = currentDebt;
    if (statementDay != null) payload['statement_day'] = statementDay;
    if (dueDay != null) payload['due_day'] = dueDay;
    if (currency != null) payload['currency'] = currency.toUpperCase();

    final response = await _dio.patch<Map<String, dynamic>>(
      '/api/v1/credit-cards/$cardId',
      data: payload,
    );
    return CreditCard.fromJson(response.data ?? <String, dynamic>{});
  }

  Future<void> deleteCard(String cardId) async {
    await _dio.delete<Map<String, dynamic>>('/api/v1/credit-cards/$cardId');
  }
}
