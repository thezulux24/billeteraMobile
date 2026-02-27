import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/shared/widgets/glass_scaffold.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/features/transactions/providers/transaction_notifier.dart';
import 'package:mobile/features/categories/providers/category_notifier.dart';
import 'package:mobile/features/transactions/models/transaction.dart';
import 'package:intl/intl.dart';

class AccountDetailsScreen extends ConsumerWidget {
  final String assetId;
  final String assetName;
  final String? assetSubtitle;
  final String assetAmount;
  final Color accentColor;

  const AccountDetailsScreen({
    super.key,
    required this.assetId,
    required this.assetName,
    this.assetSubtitle,
    required this.assetAmount,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final isDark = theme.brightness == Brightness.dark;

    final transactionState = ref.watch(transactionNotifierProvider);
    final categoryState = ref.watch(categoryNotifierProvider);

    final transactions = transactionState.transactions
        .where(
          (t) =>
              t.bankAccountId == assetId ||
              t.creditCardId == assetId ||
              t.cashWalletId == assetId,
        )
        .toList();

    return GlassScaffold(
      isPremium: true,
      child: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Liquid Header
              SliverAppBar(
                expandedHeight: 240,
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: onSurface,
                  ),
                  onPressed: () => context.pop(),
                ),
                actions: [
                  IconButton(
                    icon: Icon(Icons.more_horiz_rounded, color: onSurface),
                    onPressed: () {},
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Accent Gradient
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              accentColor.withOpacity(0.2),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      // Glass Orb Animation (Placeholder)
                      Positioned(
                        top: 40,
                        right: -20,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                accentColor.withOpacity(0.15),
                                accentColor.withOpacity(0.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Amount Display
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 40),
                            Text(
                              assetName,
                              style: GoogleFonts.manrope(
                                fontSize: 16,
                                color: onSurface.withOpacity(0.7),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              assetAmount,
                              style: GoogleFonts.manrope(
                                fontSize: 40,
                                color: onSurface,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -1,
                              ),
                            ),
                            if (assetSubtitle != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                assetSubtitle!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: onSurface.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Transaction List
              SliverFillRemaining(
                hasScrollBody: false,
                fillOverscroll: true,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.black.withOpacity(0.3)
                        : Colors.white.withOpacity(0.3),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(40),
                    ),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.05),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recent Transactions',
                            style: GoogleFonts.manrope(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: onSurface,
                            ),
                          ),
                          Icon(
                            Icons.tune_rounded,
                            size: 20,
                            color: onSurface.withOpacity(0.5),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      if (transactions.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.receipt_long_rounded,
                                  size: 48,
                                  color: onSurface.withOpacity(0.2),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No transactions yet',
                                  style: TextStyle(
                                    color: onSurface.withOpacity(0.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ...transactions.map((t) {
                          final category = categoryState.categories
                              .where((c) => c.id == t.categoryId)
                              .firstOrNull;
                          return _TransactionItem(
                            transaction: t,
                            onSurface: onSurface,
                            categoryName: category?.name ?? 'Uncategorized',
                          );
                        }),
                      const SizedBox(height: 100), // Space for fab
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final Transaction transaction;
  final Color onSurface;
  final String categoryName;

  const _TransactionItem({
    required this.transaction,
    required this.onSurface,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.kind == TransactionKind.expense;
    final amountSign = isExpense ? '-' : '+';
    final amountColor = isExpense
        ? const Color(0xffef4444)
        : const Color(0xff10b981);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: onSurface.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _getCategoryIcon(categoryName),
              color: onSurface,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description ?? categoryName,
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w600,
                    color: onSurface,
                  ),
                ),
                Text(
                  DateFormat('MMM dd, hh:mm a').format(transaction.occurredAt),
                  style: TextStyle(
                    fontSize: 11,
                    color: onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$amountSign\$${transaction.amount.toStringAsFixed(2)}',
            style: GoogleFonts.manrope(
              fontWeight: FontWeight.bold,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    // Basic mapping for now
    switch (category.toLowerCase()) {
      case 'food':
      case 'grocery':
      case 'dining':
        return Icons.restaurant_rounded;
      case 'transport':
      case 'uber':
      case 'tax':
        return Icons.directions_car_rounded;
      case 'shopping':
        return Icons.shopping_bag_rounded;
      case 'salary':
      case 'income':
        return Icons.payments_rounded;
      default:
        return Icons.category_rounded;
    }
  }
}
