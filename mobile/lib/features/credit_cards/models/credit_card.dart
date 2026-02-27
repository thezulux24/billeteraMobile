enum CreditCardTier { classic, gold, platinum, black }

enum CardProvider { visa, mastercard, amex, other }

class CreditCard {
  const CreditCard({
    required this.id,
    required this.name,
    required this.issuer,
    required this.lastFourDigits,
    required this.provider,
    required this.tier,
    required this.creditLimit,
    required this.currentDebt,
    required this.currency,
    required this.statementDay,
    required this.dueDay,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String issuer;
  final String lastFourDigits;
  final CardProvider provider;
  final CreditCardTier tier;
  final double creditLimit;
  final double currentDebt;
  final String currency;
  final int statementDay;
  final int dueDay;
  final DateTime createdAt;
  final DateTime updatedAt;

  double get availableCredit => creditLimit - currentDebt;

  factory CreditCard.fromJson(Map<String, dynamic> json) {
    return CreditCard(
      id: json['id'] as String,
      name: json['name'] as String,
      issuer: json['issuer'] as String,
      lastFourDigits: json['last_four'] as String? ?? '****',
      provider: _parseProvider(json['card_provider'] as String?),
      tier: _parseTier(json['tier'] as String?),
      creditLimit: (json['credit_limit'] as num).toDouble(),
      currentDebt: (json['current_debt'] as num).toDouble(),
      currency: json['currency'] as String,
      statementDay: (json['statement_day'] as int? ?? 1),
      dueDay: (json['due_day'] as int? ?? 1),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  static CreditCardTier _parseTier(String? tier) {
    switch (tier?.toLowerCase()) {
      case 'gold':
        return CreditCardTier.gold;
      case 'platinum':
        return CreditCardTier.platinum;
      case 'black':
        return CreditCardTier.black;
      default:
        return CreditCardTier.classic;
    }
  }

  static CardProvider _parseProvider(String? provider) {
    switch (provider?.toLowerCase()) {
      case 'visa':
        return CardProvider.visa;
      case 'mastercard':
        return CardProvider.mastercard;
      case 'amex':
        return CardProvider.amex;
      default:
        return CardProvider.other;
    }
  }
}
