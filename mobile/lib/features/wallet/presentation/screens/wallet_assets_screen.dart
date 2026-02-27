import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/glass_scaffold.dart';
import '../../../../shared/widgets/asset_summary_card.dart';
import '../../../../shared/widgets/premium_bottom_nav.dart';

class WalletAssetsScreen extends StatelessWidget {
  const WalletAssetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Wallet',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            'Manage your digital assets',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xff94a3b8),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          _HeaderBtn(icon: Icons.search_rounded),
                          const SizedBox(width: 12),
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
                        const AssetSummaryCard(
                          totalNetWorth: '\$124,582.00',
                          trend: '+4.2%',
                        ),
                        const SizedBox(height: 32),

                        // My Accounts Section
                        _SectionHeader(title: 'My Accounts', action: 'See All'),
                        const SizedBox(height: 16),

                        // Highlighted Card (Conic border simulation)
                        Container(
                          padding: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: const SweepGradient(
                              colors: [
                                Color(0xff06b6d4),
                                Color(0xffec4899),
                                Color(0xff14b8a6),
                                Color(0xff06b6d4),
                              ],
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(23),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withValues(alpha: 0.08),
                                  Colors.white.withValues(alpha: 0.02),
                                ],
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xff06b6d4),
                                                Color(0xff14b8a6),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.account_balance_rounded,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        const Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Main Savings',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text(
                                              '**** 4829',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Color(0xff94a3b8),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const Icon(
                                      Icons.more_vert_rounded,
                                      color: Color(0xff94a3b8),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '\$42,390.45',
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    Opacity(
                                      opacity: 0.8,
                                      child: Image.network(
                                        'https://lh3.googleusercontent.com/aida-public/AB6AXuA5BPMNNGuqZfPzmmYXquJ8a2khHWMLwlOG2NResPbv7qmliz2AtCXEzQ0WL2YcvZ5ljAeH0W1_kcCdj1LFxsNs7jbB2OsRrNLAV9ul8g5k5EgiD0xeIXHHXHRdrL0xQUWoBM2fLBUBDi8Vs-hFOlxGaeohU35dL6ONLo87Z6peo3WyuzMqWaMrnbJF5kQL5N2_CSL35LHJVfi42Nl1f7CR1Lv1DfxBWqsan6OzXvF6zGsaZij7_oN6CGyqZVVC9VcloVeiamPlhAQ',
                                        height: 24,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(
                                                  Icons.credit_card,
                                                  color: Colors.white24,
                                                  size: 24,
                                                ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Other Wallets
                        _AssetCard(
                          icon: Icons.currency_bitcoin_rounded,
                          title: 'Crypto Portfolio',
                          subtitle: 'Active Wallet',
                          amount: '\$12,842.10',
                          trailingText: '0.428 BTC',
                          iconBg: Colors.white.withValues(alpha: 0.1),
                        ),
                        const SizedBox(height: 16),
                        _AssetCard(
                          icon: Icons.credit_card_rounded,
                          title: 'Apple Card',
                          subtitle: '**** 9102',
                          amount: '\$2,105.00',
                          trailingText: 'PLATINUM',
                          iconBg: Colors.white.withValues(alpha: 0.1),
                        ),

                        const SizedBox(height: 32),

                        // Recent Assets Section
                        _SectionHeader(title: 'Recent Assets'),
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            children: [
                              _RecentAssetItem(
                                icon: Icons.trending_up_rounded,
                                color: const Color(0xff3b82f6),
                                title: 'Stock Market',
                                subtitle: 'Portfolio Growth',
                                amount: '+\$1,240',
                                showDivider: true,
                              ),
                              _RecentAssetItem(
                                icon: Icons.home_work_rounded,
                                color: const Color(0xffa855f7),
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
              onAddPressed: () {},
            ),
          ),
        ],
      ),
    );
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
        color: Colors.white.withValues(alpha: 0.05),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Icon(icon, color: const Color(0xffcbd5e1), size: 22),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.action});
  final String title;
  final String? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Color(0xff64748b),
            letterSpacing: 1.5,
          ),
        ),
        if (action != null)
          Text(
            action!,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xff06b6d4),
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
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
                    child: Icon(icon, color: const Color(0xffcbd5e1), size: 24),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: amount.startsWith('+')
                      ? const Color(0xff4ade80)
                      : Colors.white,
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          const Divider(height: 1, color: Colors.white10, indent: 68),
      ],
    );
  }
}
