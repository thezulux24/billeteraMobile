enum CategoryKind { income, expense, transfer, creditPayment }

class Category {
  const Category({
    required this.id,
    required this.name,
    required this.kind,
    this.color,
    this.icon,
    this.isSystem = false,
  });

  final String id;
  final String name;
  final CategoryKind kind;
  final String? color;
  final String? icon;
  final bool isSystem;

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      kind: _parseKind(json['kind'] as String),
      color: json['color'] as String?,
      icon: json['icon'] as String?,
      isSystem: json['is_system'] as bool? ?? false,
    );
  }

  static CategoryKind _parseKind(String kind) {
    switch (kind.toLowerCase()) {
      case 'income':
        return CategoryKind.income;
      case 'expense':
        return CategoryKind.expense;
      case 'transfer':
        return CategoryKind.transfer;
      case 'credit_payment':
        return CategoryKind.creditPayment;
      default:
        return CategoryKind.expense;
    }
  }
}
