import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/shared/widgets/glass_scaffold.dart';
import 'package:mobile/shared/widgets/asset_summary_card.dart';
import 'package:mobile/shared/widgets/premium_bottom_nav.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/shared/widgets/add_account_bottom_sheet.dart';
import 'package:mobile/shared/widgets/add_transaction_bottom_sheet.dart';
import 'package:mobile/features/bank_accounts/providers/bank_account_notifier.dart';
import 'package:mobile/features/cash_wallets/providers/cash_wallet_notifier.dart';
import 'package:mobile/features/credit_cards/providers/credit_card_notifier.dart';
import 'package:mobile/features/credit_cards/models/credit_card.dart';

class WalletAssetsScreen extends ConsumerWidget {
  const WalletAssetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final bankState = ref.watch(bankAccountNotifierProvider);
    final cashState = ref.watch(cashWalletNotifierProvider);
    final creditState = ref.watch(creditCardNotifierProvider);

    final totalNetWorth =
        bankState.totalBalance + cashState.totalBalance - creditState.totalDebt;

    return GlassScaffold(
      isPremium: true,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Content
          Positioned.fill(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.only(
                    top: 60,
                    left: 24,
                    right: 24,
                    bottom: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Wallet',
                            style: GoogleFonts.manrope(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: onSurface,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const Text(
                            'Manage your digital assets',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xff94a3b8),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: const [
                          _HeaderBtn(icon: Icons.search_rounded),
                          SizedBox(width: 12),
                          _HeaderBtn(icon: Icons.notifications_none_rounded),
                        ],
                      ),
                    ],
                  ),
                ),

                // Scrollable area
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        AssetSummaryCard(
                          totalNetWorth:
                              '\$${totalNetWorth.toStringAsFixed(2)}',
                          trend: '+0.0%', // TODO: Calculate real trend
                        ),
                        const SizedBox(height: 32),

                        // My Accounts Section
                        _SectionHeader(
                          title: 'My Accounts',
                          action: 'Add',
                          onActionPressed: () => _openAddAccountSheet(context),
                        ),
                        const SizedBox(height: 16),

                        // List all assets
                        if (bankState.accounts.isEmpty &&
                            cashState.wallets.isEmpty &&
                            creditState.cards.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              child: Text(
                                'No accounts yet. Add one to get started!',
                                style: TextStyle(
                                  color: onSurface.withOpacity(0.5),
                                ),
                              ),
                            ),
                          ),

                        ...bankState.accounts.map(
                          (acc) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: InkWell(
                              onTap: () => context.push(
                                '/account-details',
                                extra: {
                                  'assetId': acc.id,
                                  'assetName': acc.name,
                                  'subtitle': acc.bankName ?? 'Bank Account',
                                  'amount':
                                      '\$${acc.balance.toStringAsFixed(2)}',
                                  'accentColor': const Color(0xff06b6d4),
                                },
                              ),
                              child: _AssetCard(
                                icon: Icons.account_balance_rounded,
                                title: acc.name,
                                subtitle: acc.bankName ?? 'Bank Account',
                                amount: '\$${acc.balance.toStringAsFixed(2)}',
                                trailingText: acc.currency,
                                iconBg: const Color(
                                  0xff06b6d4,
                                ).withOpacity(0.2),
                              ),
                            ),
                          ),
                        ),

                        ...cashState.wallets.map(
                          (wallet) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: InkWell(
                              onTap: () => context.push(
                                '/account-details',
                                extra: {
                                  'assetId': wallet.id,
                                  'assetName': wallet.name,
                                  'subtitle': 'Cash Wallet',
                                  'amount':
                                      '\$${wallet.balance.toStringAsFixed(2)}',
                                  'accentColor': const Color(0xff10b981),
                                },
                              ),
                              child: _AssetCard(
                                icon: Icons.payments_rounded,
                                title: wallet.name,
                                subtitle: 'Cash Wallet',
                                amount:
                                    '\$${wallet.balance.toStringAsFixed(2)}',
                                trailingText: wallet.currency,
                                iconBg: const Color(
                                  0xff10b981,
                                ).withOpacity(0.2),
                              ),
                            ),
                          ),
                        ),

                        ...creditState.cards.map(
                          (card) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: InkWell(
                              onTap: () => context.push(
                                '/account-details',
                                extra: {
                                  'assetId': card.id,
                                  'assetName': card.name,
                                  'subtitle':
                                      '${card.issuer} • **** ${card.id.substring(card.id.length - 4)}',
                                  'amount':
                                      '\$${card.currentDebt.toStringAsFixed(2)}',
                                  'accentColor': _getCardColor(card.tier),
                                },
                              ),
                              child: _AssetCard(
                                icon: Icons.credit_card_rounded,
                                title: card.name,
                                subtitle:
                                    '${card.issuer} • **** ${card.id.substring(card.id.length - 4)}',
                                amount:
                                    '\$${card.currentDebt.toStringAsFixed(2)}',
                                trailingText: card.tier.name.toUpperCase(),
                                iconBg: _getCardColor(
                                  card.tier,
                                ).withOpacity(0.2),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Recent Assets Section
                        const _SectionHeader(title: 'Recent Assets'),
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.glassBackground(context),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: AppColors.glassBorder(context),
                            ),
                          ),
                          child: Column(
                            children: [
                              const _RecentAssetItem(
                                icon: Icons.trending_up_rounded,
                                color: Color(0xff3b82f6),
                                title: 'Stock Market',
                                subtitle: 'Portfolio Growth',
                                amount: '+\$1,240',
                                showDivider: true,
                              ),
                              const _RecentAssetItem(
                                icon: Icons.home_work_rounded,
                                color: Color(0xffa855f7),
                                title: 'Real Estate',
                                subtitle: 'Monthly Rent',
                                amount: '\$67,205',
                                showDivider: false,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Nav
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: PremiumBottomNav(
              currentIndex: 2, // Wallet
              onTabSelected: (index) {
                if (index == 0) context.go('/home');
                if (index == 1) context.go('/analytics');
                if (index == 3) context.go('/profile');
              },
              onAddPressed: () => _openAddTransactionSheet(context),
            ),
          ),
        ],
      ),
    );
  }

  void _openAddAccountSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddAccountBottomSheet(),
    );
  }

  void _openAddTransactionSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddTransactionBottomSheet(),
    );
  }

  Color _getCardColor(CreditCardTier tier) {
    switch (tier) {
      case CreditCardTier.classic:
        return const Color(0xff94a3b8);
      case CreditCardTier.gold:
        return const Color(0xfffbbf24);
      case CreditCardTier.platinum:
        return const Color(0xffe2e8f0);
      case CreditCardTier.black:
        return const Color(0xff1e293b);
    }
  }
}

class _HeaderBtn extends StatelessWidget {
  const _HeaderBtn({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.glassBackground(context),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.glassBorder(context)),
      ),
      child: Icon(
        icon,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        size: 22,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.action,
    this.onActionPressed,
  });
  final String title;
  final String? action;
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title.toUpperCase(),
          style: GoogleFonts.manrope(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: const Color(0xff64748b),
            letterSpacing: 1.5,
          ),
        ),
        if (action != null)
          TextButton(
            onPressed: onActionPressed,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              action!,
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: const Color(0xff06b6d4),
              ),
            ),
          ),
      ],
    );
  }
}

class _AssetCard extends StatelessWidget {
  const _AssetCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.trailingText,
    required this.iconBg,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String amount;
  final String trailingText;
  final Color iconBg;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.glassBackground(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.glassBorder(context)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: onSurface.withValues(alpha: 0.7),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.manrope(
                          fontWeight: FontWeight.bold,
                          color: onSurface,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xff94a3b8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Icon(Icons.more_vert_rounded, color: Color(0xff94a3b8)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  amount,
                  style: GoogleFonts.manrope(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                trailingText,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xff94a3b8),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecentAssetItem extends StatelessWidget {
  const _RecentAssetItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.showDivider,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String amount;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.manrope(
                          fontWeight: FontWeight.bold,
                          color: onSurface,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xff94a3b8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                amount,
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.bold,
                  color: amount.startsWith('+')
                      ? const Color(0xff4ade80)
                      : onSurface,
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            color: onSurface.withValues(alpha: 0.1),
            indent: 68,
          ),
      ],
    );
  }
}
