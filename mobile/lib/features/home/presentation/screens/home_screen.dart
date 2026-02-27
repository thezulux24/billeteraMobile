import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

import '../../../../shared/widgets/glass_scaffold.dart';
import '../../../../shared/widgets/metric_card.dart';
import '../../../../shared/widgets/wallet_card.dart';
import '../../../../shared/widgets/monthly_overview_chart.dart';
import '../../../../shared/widgets/insight_card.dart';
import '../../../../shared/widgets/premium_bottom_nav.dart';
import '../../../auth/providers/auth_notifier.dart';
import '../../../bank_accounts/providers/bank_account_notifier.dart';
import '../../../cash_wallets/providers/cash_wallet_notifier.dart';
import '../../../credit_cards/providers/credit_card_notifier.dart';
import '../../../../shared/widgets/add_transaction_bottom_sheet.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await Future.wait([
        ref.read(cashWalletNotifierProvider).load(),
        ref.read(bankAccountNotifierProvider).load(),
        ref.read(creditCardNotifierProvider).load(),
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = ref.watch(authNotifierProvider);
    final String? email = auth.session?.email;
    final rawName = (email != null && email.contains('@'))
        ? email.split('@').first
        : 'Alexandra';
    final displayName = rawName.isNotEmpty
        ? rawName[0].toUpperCase() + rawName.substring(1).toLowerCase()
        : 'Alexandra';

    final bankState = ref.watch(bankAccountNotifierProvider);
    final cashState = ref.watch(cashWalletNotifierProvider);
    final creditState = ref.watch(creditCardNotifierProvider);

    final totalAssets = bankState.totalBalance + cashState.totalBalance;
    final totalDebt = creditState.totalDebt;
    final netWorth = totalAssets - totalDebt;

    return GlassScaffold(
      isPremium: true,
      child: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: RefreshIndicator(
                onRefresh: _refreshAll,
                color: const Color(0xff4f46e5),
                backgroundColor: theme.brightness == Brightness.dark
                    ? const Color(0xff1b1933)
                    : Colors.white,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    const SizedBox(height: 24),
                    // Header Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.2,
                                  ),
                                  width: 2,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(22),
                                child: Image.network(
                                  'https://lh3.googleusercontent.com/aida-public/AB6AXuDd2LvR87zPtHuu4jJbu3qq7YZxkQmkCvgw1NkRAEyoV7ZKW2-KnQ3g1KcwUFyKyPPJTWYZuo77B9ik648jGbMu-r3sokra3VdrkB5-aY0-HyC1DawwPS5fItKt0YLy-aOHfK1pH2wtf2_ysGA7T1A-yDKq6MlmDROHP8amXsVGiFl3HzGx5HeEn9e_bN9qMVo1k0EC-hxsN4te5qcLdP7M1cSozmgJHVe_E_imNOzbTfzn_pQSzBJi85QN9HvJZ754AtLGn4jstr0',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'WELCOME BACK',
                                  style: GoogleFonts.manrope(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.glassLabel(context),
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                Text(
                                  displayName,
                                  style: GoogleFonts.manrope(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.glassBackground(context),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.glassBorder(context),
                            ),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                Icons.notifications_none_rounded,
                                color: theme.colorScheme.onSurface,
                                size: 22,
                              ),
                              Positioned(
                                top: 12,
                                right: 12,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: const Color(0xfff43f5e),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: theme.brightness == Brightness.dark
                                          ? const Color(0xff0f0c1d)
                                          : Colors.white,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Net Worth Summary
                    MetricCard(
                      totalBalance: netWorth,
                      totalAssets: totalAssets,
                      creditDebt: totalDebt,
                    ),
                    const SizedBox(height: 36),

                    // My Wallets
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'My Wallets',
                          style: GoogleFonts.manrope(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go('/wallet'),
                          child: Text(
                            'See All',
                            style: GoogleFonts.manrope(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xff818cf8),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 170,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        children: [
                          ...bankState.accounts.map(
                            (acc) => Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: WalletCard(
                                name: acc.name,
                                balance: acc.balance,
                                currency: acc.currency,
                                type: WalletCardType.savings,
                              ),
                            ),
                          ),
                          ...creditState.cards.map(
                            (card) => Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: WalletCard(
                                name: card.name,
                                balance: card.currentDebt,
                                currency: card.currency,
                                type: WalletCardType.credit,
                                tier: card.tier,
                                lastFourDigit: card.lastFourDigits,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Monthly Overview Chart
                    const MonthlyOverviewChart(),
                    const SizedBox(height: 36),

                    // Quick Insight Card
                    const InsightCard(),
                    const SizedBox(height: 120), // Spacing for BottomNav
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: PremiumBottomNav(
                currentIndex: 0,
                onAddPressed: _openAddTransactionSheet,
                onTabSelected: (index) {
                  if (index == 1) context.go('/analytics');
                  if (index == 2) context.go('/wallet');
                  if (index == 3) context.go('/profile');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshAll() async {
    await Future.wait([
      ref.read(cashWalletNotifierProvider).load(),
      ref.read(bankAccountNotifierProvider).load(),
      ref.read(creditCardNotifierProvider).load(),
    ]);
  }

  Future<void> _openAddTransactionSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return const AddTransactionBottomSheet();
      },
    );
  }
}
