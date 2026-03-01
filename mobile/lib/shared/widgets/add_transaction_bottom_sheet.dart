import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'glass_text_field.dart';
import 'glass_button.dart';
import '../../core/theme/app_colors.dart';
import '../../features/categories/models/predefined_categories.dart';
import '../../features/categories/models/category.dart';
import '../../features/categories/providers/category_notifier.dart';
import '../../features/transactions/providers/transaction_notifier.dart';
import '../../features/bank_accounts/providers/bank_account_notifier.dart';
import '../../features/cash_wallets/providers/cash_wallet_notifier.dart';
import '../../features/credit_cards/providers/credit_card_notifier.dart';
import '../../features/transactions/models/transaction.dart';
import 'add_category_bottom_sheet.dart';

class AddTransactionBottomSheet extends ConsumerStatefulWidget {
  const AddTransactionBottomSheet({super.key});

  @override
  ConsumerState<AddTransactionBottomSheet> createState() =>
      _AddTransactionBottomSheetState();
}

class _AddTransactionBottomSheetState
    extends ConsumerState<AddTransactionBottomSheet> {
  static const String _typeIncome = 'Income';
  static const String _typeExpense = 'Expense';
  static const String _typeTransfer = 'Transfer';
  static const String _typeCardPay = 'Card Pay';

  final _formKey = GlobalKey<FormState>();
  static final RegExp _uuidPattern = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
  );

  String _transactionType = _typeExpense;
  Category? _selectedCategory;
  dynamic _selectedAsset; // BankAccount, CashWallet, or CreditCard
  dynamic _selectedTargetAsset; // Transfer destination (BankAccount/CashWallet)
  dynamic _selectedCreditCardForPayment; // CreditCard for card payments
  bool _saving = false;

  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedCategory = PredefinedCategories.expense.first;
    Future.microtask(() async {
      await ref.read(categoryNotifierProvider).load();
      if (!mounted) return;
      setState(() {
        _selectedCategory = _defaultCategoryForType(
          _transactionType,
          ref.read(categoryNotifierProvider).categories,
        );
      });
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              decoration: BoxDecoration(
                gradient: isDark
                    ? const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xCC1A1530), // deep indigo translucent
                          Color(0xEE0F0E1C), // near-black
                        ],
                      )
                    : const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xE6EDE9FE), Color(0xF0EEF2FF)],
                      ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(36),
                ),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : Colors.white.withValues(alpha: 0.7),
                  width: 1.2,
                ),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        children: [
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.25)
                                    : Colors.black.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          Text(
                            'New Transaction',
                            style: GoogleFonts.manrope(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: onSurface,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Type Selector
                          _buildSegmentedSelector(
                            options: const [
                              _typeIncome,
                              _typeExpense,
                              _typeTransfer,
                              _typeCardPay,
                            ],
                            selected: _transactionType,
                            onChanged: (val) {
                              setState(() {
                                _transactionType = val;
                                _selectedCategory = _defaultCategoryForType(
                                  val,
                                  ref.read(categoryNotifierProvider).categories,
                                );
                                _selectedAsset =
                                    _isAssetAllowedForSource(_selectedAsset)
                                    ? _selectedAsset
                                    : null;
                                if (val != _typeTransfer) {
                                  _selectedTargetAsset = null;
                                }
                                if (val != _typeCardPay) {
                                  _selectedCreditCardForPayment = null;
                                }
                              });
                            },
                          ),
                          const SizedBox(height: 32),

                          // Amount Field (Large)
                          Text(
                            'Amount',
                            style: GoogleFonts.manrope(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.manrope(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: _transactionType == _typeIncome
                                  ? AppColors.stitchPurple
                                  : onSurface,
                            ),
                            decoration: const InputDecoration(
                              hintText: '0.00',
                              border: InputBorder.none,
                              prefixText: '\$',
                              prefixStyle: TextStyle(
                                fontSize: 24,
                                color: Color(0xff94a3b8),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Category Selector
                          Text(
                            'Category',
                            style: GoogleFonts.manrope(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildCategoryGrid(),
                          const SizedBox(height: 24),

                          GlassTextField(
                            controller: _descriptionController,
                            label: 'Description (optional)',
                            isPremium: true,
                            prefixIcon: Icons.notes_rounded,
                          ),

                          const SizedBox(height: 24),

                          // Asset Selector
                          Text(
                            _transactionType == _typeCardPay
                                ? 'Pay From'
                                : 'Account / Wallet',
                            style: GoogleFonts.manrope(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildAssetSelector(),
                          if (_transactionType == _typeTransfer) ...[
                            const SizedBox(height: 24),
                            Text(
                              'Destination Account / Wallet',
                              style: GoogleFonts.manrope(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildAssetSelector(isTarget: true),
                          ] else if (_transactionType == _typeCardPay) ...[
                            const SizedBox(height: 24),
                            Text(
                              'Credit Card',
                              style: GoogleFonts.manrope(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildAssetSelector(creditCardOnly: true),
                          ],
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                    SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        child: GlassButton(
                          label: 'Save Transaction',
                          isPremium: true,
                          loading: _saving,
                          onPressed: _saveTransaction,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSegmentedSelector({
    required List<String> options,
    required String selected,
    required ValueChanged<String> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalW = constraints.maxWidth;
        final padding = 4.0;
        final itemW = (totalW - padding * 2) / options.length;
        final selectedIndex = options.indexOf(selected);

        return Container(
          height: 52,
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.08),
            ),
          ),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutExpo,
                left: selectedIndex * itemW,
                top: 0,
                bottom: 0,
                width: itemW,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.stitchIndigo,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.stitchIndigo.withValues(
                              alpha: 0.45,
                            ),
                            blurRadius: 14,
                            spreadRadius: -2,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                children: options.map((opt) {
                  final isSelected = opt == selected;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onChanged(opt),
                      behavior: HitTestBehavior.opaque,
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOut,
                          style: GoogleFonts.manrope(
                            fontSize: 13.5,
                            fontWeight: isSelected
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : (isDark
                                      ? Colors.white.withValues(alpha: 0.45)
                                      : Colors.black.withValues(alpha: 0.45)),
                          ),
                          child: Text(opt),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryGrid() {
    final userCategories = ref.watch(categoryNotifierProvider).categories;
    final currentKind = _currentCategoryKind(_transactionType);

    final filteredUserCategories = userCategories
        .where((c) => c.kind == currentKind)
        .toList();
    final allCategories = filteredUserCategories.isNotEmpty
        ? filteredUserCategories
        : _fallbackCategoriesForKind(currentKind);

    final onSurface = Theme.of(context).colorScheme.onSurface;

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: allCategories.length + 1, // +1 for Add button
        separatorBuilder: (_, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          if (index == allCategories.length) {
            return _buildAddCategoryButton();
          }

          final cat = allCategories[index];
          final isSelected = _selectedCategory?.id == cat.id;
          final catColor = cat.color != null
              ? Color(int.parse(cat.color!.replaceFirst('#', '0xff')))
              : AppColors.stitchIndigo;

          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat),
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? catColor
                        : catColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? catColor
                          : catColor.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    _getIconData(cat.icon),
                    color: isSelected ? Colors.white : catColor,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  cat.name,
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    color: isSelected
                        ? catColor
                        : onSurface.withValues(alpha: 0.6),
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddCategoryButton() {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return GestureDetector(
      onTap: () => _showAddCategorySheet(),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: onSurface.withValues(alpha: 0.05),
              shape: BoxShape.circle,
              border: Border.all(
                color: onSurface.withValues(alpha: 0.1),
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            child: Icon(
              Icons.add_rounded,
              color: onSurface.withValues(alpha: 0.6),
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'New',
            style: GoogleFonts.manrope(
              fontSize: 11,
              color: onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddCategorySheet() async {
    final currentKind = _currentCategoryKind(_transactionType);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddCategoryBottomSheet(kind: currentKind),
    );
    if (!mounted) return;
    setState(() {
      _selectedCategory = _defaultCategoryForType(
        _transactionType,
        ref.read(categoryNotifierProvider).categories,
      );
    });
  }

  Widget _buildAssetSelector({
    bool isTarget = false,
    bool creditCardOnly = false,
  }) {
    final bankAccounts = ref.watch(bankAccountNotifierProvider).accounts;
    final cashWallets = ref.watch(cashWalletNotifierProvider).wallets;
    final creditCards = ref.watch(creditCardNotifierProvider).cards;

    final allAssets = creditCardOnly
        ? [...creditCards]
        : isTarget
        ? [...bankAccounts, ...cashWallets]
              .where((asset) => (asset as dynamic).id != _selectedAsset?.id)
              .toList()
        : _sourceAssets(
            bankAccounts: bankAccounts,
            cashWallets: cashWallets,
            creditCards: creditCards,
          );

    if (allAssets.isEmpty) {
      return Text(
        creditCardOnly
            ? 'No credit cards found. Create one first.'
            : isTarget
            ? 'Choose a different destination account.'
            : 'No compatible accounts found. Create one first.',
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      );
    }

    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: allAssets.length,
        separatorBuilder: (_, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final asset = allAssets[index] as dynamic;
          final selectedAsset = creditCardOnly
              ? _selectedCreditCardForPayment
              : isTarget
              ? _selectedTargetAsset
              : _selectedAsset;
          final isSelected = selectedAsset?.id == asset.id;
          final name = asset.name as String;
          final icon = _assetIcon(asset);

          return GestureDetector(
            onTap: () => setState(() {
              if (creditCardOnly) {
                _selectedCreditCardForPayment = asset;
                return;
              }
              if (isTarget) {
                _selectedTargetAsset = asset;
                return;
              }
              _selectedAsset = asset;
              if (_transactionType == _typeTransfer &&
                  _selectedTargetAsset?.id == asset.id) {
                _selectedTargetAsset = null;
              }
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.stitchIndigo
                    : AppColors.glassBackground(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? AppColors.stitchIndigo
                      : AppColors.glassBorder(context),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 18,
                    color: isSelected
                        ? Colors.white
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    name,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected
                          ? Colors.white
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<dynamic> _sourceAssets({
    required List<dynamic> bankAccounts,
    required List<dynamic> cashWallets,
    required List<dynamic> creditCards,
  }) {
    if (_transactionType == _typeExpense) {
      return [...bankAccounts, ...cashWallets, ...creditCards];
    }
    return [...bankAccounts, ...cashWallets];
  }

  bool _isAssetAllowedForSource(dynamic asset) {
    if (asset == null) return false;
    if (_transactionType == _typeExpense) return true;
    return !_isCreditCard(asset);
  }

  bool _isBankAccount(dynamic asset) =>
      asset.runtimeType.toString().contains('BankAccount');
  bool _isCashWallet(dynamic asset) =>
      asset.runtimeType.toString().contains('CashWallet');
  bool _isCreditCard(dynamic asset) =>
      asset.runtimeType.toString().contains('CreditCard');

  IconData _assetIcon(dynamic asset) {
    if (_isBankAccount(asset)) {
      return Icons.account_balance_rounded;
    }
    if (_isCashWallet(asset)) {
      return Icons.payments_rounded;
    }
    if (_isCreditCard(asset)) {
      return Icons.credit_card_rounded;
    }
    return Icons.account_balance_wallet_rounded;
  }

  bool _isUuid(String? value) {
    if (value == null) return false;
    return _uuidPattern.hasMatch(value);
  }

  CategoryKind _currentCategoryKind(String transactionType) {
    if (transactionType == _typeIncome) return CategoryKind.income;
    if (transactionType == _typeTransfer) return CategoryKind.transfer;
    if (transactionType == _typeCardPay) return CategoryKind.creditPayment;
    return CategoryKind.expense;
  }

  List<Category> _fallbackCategoriesForKind(CategoryKind kind) {
    if (kind == CategoryKind.income) return PredefinedCategories.income;
    if (kind == CategoryKind.transfer) return PredefinedCategories.transfer;
    if (kind == CategoryKind.creditPayment) {
      return PredefinedCategories.creditPayment;
    }
    return PredefinedCategories.expense;
  }

  Category _defaultCategoryForType(
    String transactionType,
    List<Category> categories,
  ) {
    final kind = _currentCategoryKind(transactionType);
    final matches = categories.where((c) => c.kind == kind).toList();
    if (matches.isNotEmpty) {
      matches.sort((a, b) {
        if (a.isSystem == b.isSystem) return a.name.compareTo(b.name);
        return a.isSystem ? -1 : 1;
      });
      return matches.first;
    }
    return _fallbackCategoriesForKind(kind).first;
  }

  void _mapAssetToPayload(
    dynamic asset, {
    required void Function(String value) setBankAccountId,
    required void Function(String value) setCashWalletId,
    required void Function(String value) setCreditCardId,
  }) {
    if (_isBankAccount(asset)) {
      setBankAccountId(asset.id as String);
      return;
    }
    if (_isCashWallet(asset)) {
      setCashWalletId(asset.id as String);
      return;
    }
    if (_isCreditCard(asset)) {
      setCreditCardId(asset.id as String);
    }
  }

  Future<void> _saveTransaction() async {
    if (_saving) return;
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAsset == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a source account.')),
      );
      return;
    }

    final dynamic selectedAsset = _selectedAsset;
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount.')),
      );
      return;
    }

    late final TransactionKind kind;
    switch (_transactionType) {
      case _typeIncome:
        kind = TransactionKind.income;
        break;
      case _typeExpense:
        kind = _isCreditCard(selectedAsset)
            ? TransactionKind.creditCharge
            : TransactionKind.expense;
        break;
      case _typeTransfer:
        kind = TransactionKind.transfer;
        break;
      case _typeCardPay:
        kind = TransactionKind.creditPayment;
        break;
      default:
        kind = TransactionKind.expense;
        break;
    }

    if (kind == TransactionKind.income && _isCreditCard(selectedAsset)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Income can only be assigned to bank or cash accounts.',
          ),
        ),
      );
      return;
    }

    if (kind == TransactionKind.transfer && _selectedTargetAsset == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a destination account.')),
      );
      return;
    }

    if (kind == TransactionKind.creditPayment &&
        _selectedCreditCardForPayment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a credit card to pay.')),
      );
      return;
    }

    String? bankAccountId;
    String? cashWalletId;
    String? creditCardId;
    String? targetBankAccountId;
    String? targetCashWalletId;

    _mapAssetToPayload(
      selectedAsset,
      setBankAccountId: (value) => bankAccountId = value,
      setCashWalletId: (value) => cashWalletId = value,
      setCreditCardId: (value) => creditCardId = value,
    );

    if (kind == TransactionKind.transfer && _selectedTargetAsset != null) {
      _mapAssetToPayload(
        _selectedTargetAsset,
        setBankAccountId: (value) => targetBankAccountId = value,
        setCashWalletId: (value) => targetCashWalletId = value,
        setCreditCardId: (_) {},
      );
    }

    if (kind == TransactionKind.creditPayment) {
      if (_isCreditCard(selectedAsset)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Card payment source must be cash or bank account.'),
          ),
        );
        return;
      }
      creditCardId = _selectedCreditCardForPayment.id as String;
    }

    final resolvedCategoryId = _isUuid(_selectedCategory?.id)
        ? _selectedCategory!.id
        : _defaultCategoryForType(
            _transactionType,
            ref.read(categoryNotifierProvider).categories,
          ).id;
    final categoryId = _isUuid(resolvedCategoryId) ? resolvedCategoryId : null;

    setState(() => _saving = true);
    final success = await ref
        .read(transactionNotifierProvider)
        .createTransaction(
          kind: kind,
          amount: amount,
          currency: 'USD',
          description: _descriptionController.text.trim(),
          categoryId: categoryId,
          bankAccountId: bankAccountId,
          cashWalletId: cashWalletId,
          creditCardId: creditCardId,
          targetBankAccountId: targetBankAccountId,
          targetCashWalletId: targetCashWalletId,
        );
    if (mounted) {
      setState(() => _saving = false);
    }

    if (success && mounted) {
      await Future.wait([
        ref.read(cashWalletNotifierProvider).load(),
        ref.read(bankAccountNotifierProvider).load(),
        ref.read(creditCardNotifierProvider).load(),
      ]);
      if (!mounted) return;
      Navigator.pop(context);
    } else if (mounted) {
      final message =
          ref.read(transactionNotifierProvider).error ??
          'Failed to save transaction.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  IconData _getIconData(String? iconName) {
    switch (iconName) {
      case 'payments':
        return Icons.payments_rounded;
      case 'laptop_mac':
        return Icons.laptop_mac_rounded;
      case 'trending_up':
        return Icons.trending_up_rounded;
      case 'restaurant':
        return Icons.restaurant_rounded;
      case 'directions_car':
        return Icons.directions_car_rounded;
      case 'shopping_bag':
        return Icons.shopping_bag_rounded;
      case 'bolt':
        return Icons.bolt_rounded;
      case 'movie':
        return Icons.movie_rounded;
      case 'medical_services':
        return Icons.medical_services_rounded;
      case 'sync_alt':
        return Icons.sync_alt_rounded;
      case 'credit_score':
        return Icons.credit_score_rounded;
      default:
        return Icons.category_rounded;
    }
  }
}
