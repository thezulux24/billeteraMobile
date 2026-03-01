import 'category.dart';

class PredefinedCategories {
  static const List<Category> income = [
    Category(
      id: 'inc_salary',
      name: 'Salary',
      kind: CategoryKind.income,
      color: '#4ade80',
      icon: 'payments',
    ),
    Category(
      id: 'inc_freelance',
      name: 'Freelance',
      kind: CategoryKind.income,
      color: '#22d3ee',
      icon: 'laptop_mac',
    ),
    Category(
      id: 'inc_investments',
      name: 'Investments',
      kind: CategoryKind.income,
      color: '#a855f7',
      icon: 'trending_up',
    ),
  ];

  static const List<Category> expense = [
    Category(
      id: 'exp_food',
      name: 'Food & Dining',
      kind: CategoryKind.expense,
      color: '#f87171',
      icon: 'restaurant',
    ),
    Category(
      id: 'exp_transport',
      name: 'Transport',
      kind: CategoryKind.expense,
      color: '#fb923c',
      icon: 'directions_car',
    ),
    Category(
      id: 'exp_shopping',
      name: 'Shopping',
      kind: CategoryKind.expense,
      color: '#ec4899',
      icon: 'shopping_bag',
    ),
    Category(
      id: 'exp_utilities',
      name: 'Utilities',
      kind: CategoryKind.expense,
      color: '#3b82f6',
      icon: 'bolt',
    ),
    Category(
      id: 'exp_entertainment',
      name: 'Entertainment',
      kind: CategoryKind.expense,
      color: '#fbbf24',
      icon: 'movie',
    ),
    Category(
      id: 'exp_health',
      name: 'Health',
      kind: CategoryKind.expense,
      color: '#f43f5e',
      icon: 'medical_services',
    ),
  ];

  static const List<Category> transfer = [
    Category(
      id: 'tr_wallet',
      name: 'Wallet Transfer',
      kind: CategoryKind.transfer,
      color: '#94a3b8',
      icon: 'sync_alt',
    ),
  ];

  static const List<Category> creditPayment = [
    Category(
      id: 'cp_card_payment',
      name: 'Credit Card Payment',
      kind: CategoryKind.creditPayment,
      color: '#818cf8',
      icon: 'credit_score',
    ),
  ];

  static List<Category> all = [
    ...income,
    ...expense,
    ...transfer,
    ...creditPayment,
  ];
}
