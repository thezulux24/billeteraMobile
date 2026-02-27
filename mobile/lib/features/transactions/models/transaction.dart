enum TransactionKind { income, expense, transfer, creditCharge, creditPayment }

class Transaction {
  const Transaction({
    required this.id,
    required this.kind,
    required this.amount,
    required this.currency,
    this.description,
    required this.occurredAt,
    this.categoryId,
    this.cashWalletId,
    this.bankAccountId,
    this.creditCardId,
    this.targetCashWalletId,
    this.targetBankAccountId,
  });

  final String id;
  final TransactionKind kind;
  final double amount;
  final String currency;
  final String? description;
  final DateTime occurredAt;
  final String? categoryId;
  final String? cashWalletId;
  final String? bankAccountId;
  final String? creditCardId;
  final String? targetCashWalletId;
  final String? targetBankAccountId;

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      kind: _parseKind(json['kind'] as String),
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      description: json['description'] as String?,
      occurredAt: DateTime.parse(json['occurred_at'] as String),
      categoryId: json['category_id'] as String?,
      cashWalletId: json['cash_wallet_id'] as String?,
      bankAccountId: json['bank_account_id'] as String?,
      creditCardId: json['credit_card_id'] as String?,
      targetCashWalletId: json['target_cash_wallet_id'] as String?,
      targetBankAccountId: json['target_bank_account_id'] as String?,
    );
  }

  static TransactionKind _parseKind(String kind) {
    switch (kind.toLowerCase()) {
      case 'income':
        return TransactionKind.income;
      case 'expense':
        return TransactionKind.expense;
      case 'transfer':
        return TransactionKind.transfer;
      case 'credit_charge':
        return TransactionKind.creditCharge;
      case 'credit_payment':
        return TransactionKind.creditPayment;
      default:
        return TransactionKind.expense;
    }
  }
}
