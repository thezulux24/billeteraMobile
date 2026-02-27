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
  final _formKey = GlobalKey<FormState>();
  String _transactionType = 'Expense'; // Income, Expense, Transfer
  Category? _selectedCategory;
  dynamic _selectedAsset; // BankAccount, CashWallet, or CreditCard

  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedCategory = PredefinedCategories.expense.first;
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
                        colors: [Color(0xE6F5F3FF), Color(0xF0ECEEFF)],
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
                            options: ['Income', 'Expense', 'Transfer'],
                            selected: _transactionType,
                            onChanged: (val) {
                              setState(() {
                                _transactionType = val;
                                if (val == 'Income')
                                  _selectedCategory =
                                      PredefinedCategories.income.first;
                                if (val == 'Expense')
                                  _selectedCategory =
                                      PredefinedCategories.expense.first;
                                if (val == 'Transfer')
                                  _selectedCategory =
                                      PredefinedCategories.transfer.first;
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
                              color: _transactionType == 'Income'
                                  ? const Color(0xff4ade80)
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
                            'Account / Wallet',
                            style: GoogleFonts.manrope(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildAssetSelector(),
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
    List<Category> systemCategories = [];

    final currentKind = _transactionType == 'Income'
        ? CategoryKind.income
        : _transactionType == 'Transfer'
        ? CategoryKind.transfer
        : CategoryKind.expense;

    if (_transactionType == 'Income')
      systemCategories = PredefinedCategories.income;
    if (_transactionType == 'Expense')
      systemCategories = PredefinedCategories.expense;
    if (_transactionType == 'Transfer')
      systemCategories = PredefinedCategories.transfer;

    final filteredUserCategories = userCategories
        .where((c) => c.kind == currentKind)
        .toList();
    final allCategories = [...systemCategories, ...filteredUserCategories];

    final onSurface = Theme.of(context).colorScheme.onSurface;

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: allCategories.length + 1, // +1 for Add button
        separatorBuilder: (_, __) => const SizedBox(width: 16),
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
                    color: isSelected ? catColor : catColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? catColor : catColor.withOpacity(0.3),
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
                    color: isSelected ? catColor : onSurface.withOpacity(0.6),
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
              color: onSurface.withOpacity(0.05),
              shape: BoxShape.circle,
              border: Border.all(
                color: onSurface.withOpacity(0.1),
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            child: Icon(
              Icons.add_rounded,
              color: onSurface.withOpacity(0.6),
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'New',
            style: GoogleFonts.manrope(
              fontSize: 11,
              color: onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddCategorySheet() {
    final currentKind = _transactionType == 'Income'
        ? CategoryKind.income
        : _transactionType == 'Transfer'
        ? CategoryKind.transfer
        : CategoryKind.expense;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddCategoryBottomSheet(kind: currentKind),
    );
  }

  Widget _buildAssetSelector() {
    final bankAccounts = ref.watch(bankAccountNotifierProvider).accounts;
    final cashWallets = ref.watch(cashWalletNotifierProvider).wallets;
    final creditCards = ref.watch(creditCardNotifierProvider).cards;

    final allAssets = [...bankAccounts, ...cashWallets, ...creditCards];

    if (allAssets.isEmpty) {
      return Text(
        'No accounts found. Create one first.',
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      );
    }

    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: allAssets.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final asset = allAssets[index] as dynamic;
          final isSelected = _selectedAsset?.id == asset.id;
          String name = '';
          IconData icon = Icons.account_balance_wallet_rounded;

          if (asset.runtimeType.toString().contains('BankAccount')) {
            name = asset.name;
            icon = Icons.account_balance_rounded;
          } else if (asset.runtimeType.toString().contains('CashWallet')) {
            name = asset.name;
            icon = Icons.payments_rounded;
          } else if (asset.runtimeType.toString().contains('CreditCard')) {
            name = asset.name;
            icon = Icons.credit_card_rounded;
          }

          return GestureDetector(
            onTap: () => setState(() => _selectedAsset = asset),
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

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAsset == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an account.')),
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

    final kind = _transactionType == 'Income'
        ? TransactionKind.income
        : (_transactionType == 'Expense'
              ? TransactionKind.expense
              : TransactionKind.transfer);

    String? bankAccountId;
    String? cashWalletId;
    String? creditCardId;

    final String assetType = selectedAsset.runtimeType.toString();
    if (assetType.contains('BankAccount')) {
      bankAccountId = selectedAsset.id;
    } else if (assetType.contains('CashWallet')) {
      cashWalletId = selectedAsset.id;
    } else if (assetType.contains('CreditCard')) {
      creditCardId = selectedAsset.id;
    }

    final success = await ref
        .read(transactionNotifierProvider)
        .createTransaction(
          kind: kind,
          amount: amount,
          currency: 'USD',
          description: _descriptionController.text,
          categoryId: _selectedCategory?.id,
          bankAccountId: bankAccountId,
          cashWalletId: cashWalletId,
          creditCardId: creditCardId,
        );

    if (success && mounted) {
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save transaction.')),
      );
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
      default:
        return Icons.category_rounded;
    }
  }
}
