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
    required String tier,
    required double creditLimit,
    required double currentDebt,
    int? statementDay,
    int? due_day,
    required String currency,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/credit-cards',
      data: {
        'name': name,
        'issuer': issuer,
        'tier': tier,
        'credit_limit': creditLimit,
        'current_debt': currentDebt,
        'statement_day': statementDay,
        'due_day': due_day,
        'currency': currency.toUpperCase(),
      },
    );
    return CreditCard.fromJson(response.data ?? <String, dynamic>{});
  }

  Future<CreditCard> updateCard(
    String cardId, {
    String? name,
    String? issuer,
    double? creditLimit,
    double? currentDebt,
    int? statementDay,
    int? dueDay,
    String? currency,
  }) async {
    final payload = <String, dynamic>{};
    if (name != null) payload['name'] = name;
    if (issuer != null) payload['issuer'] = issuer;
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
