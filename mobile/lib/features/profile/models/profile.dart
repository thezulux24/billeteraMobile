class Profile {
  const Profile({
    required this.id,
    required this.baseCurrency,
    required this.aiEnabled,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String baseCurrency;
  final bool aiEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      baseCurrency: json['base_currency'] as String,
      aiEnabled: json['ai_enabled'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
