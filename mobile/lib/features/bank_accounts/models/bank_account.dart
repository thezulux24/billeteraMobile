class BankAccount {
  const BankAccount({
    required this.id,
    required this.name,
    required this.bankName,
    required this.balance,
    required this.currency,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String? bankName;
  final double balance;
  final String currency;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      id: json['id'] as String,
      name: json['name'] as String,
      bankName: json['bank_name'] as String?,
      balance: (json['balance'] as num).toDouble(),
      currency: json['currency'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
