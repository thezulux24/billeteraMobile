import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/widgets/glass_scaffold.dart';
import '../../../../shared/widgets/glass_donut_chart.dart';
import '../../../../shared/widgets/category_list_item.dart';
import '../../../../shared/widgets/premium_bottom_nav.dart';
import '../../../../core/theme/app_colors.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;

    return GlassScaffold(
      isPremium: true,
      child: Stack(
        children: [
          // Content
          Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.only(
                  top: 60,
                  left: 24,
                  right: 24,
                  bottom: 24,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _IconBtn(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onPressed: () => context.go('/home'),
                    ),
                    Text(
                      'Analytics',
                      style: GoogleFonts.manrope(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: onSurface,
                      ),
                    ),
                    _IconBtn(
                      icon: Icons.calendar_month_rounded,
                      onPressed: () {},
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
                    children: [
                      // Month Selector
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.glassBackground(context),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: AppColors.glassBorder(context),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.chevron_left_rounded,
                              color: Color(0xff94a3b8),
                              size: 18,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                'October 2023',
                                style: GoogleFonts.manrope(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: onSurface,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: Color(0xff94a3b8),
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Main Card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.glassBackground(context),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: AppColors.glassBorder(context),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Spending by Category',
                              style: GoogleFonts.manrope(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: onSurface,
                              ),
                            ),
                            const SizedBox(height: 24),
                            const GlassDonutChart(totalValue: '\$4,285'),
                            const SizedBox(height: 32),
                            // Category items
                            const CategoryListItem(
                              icon: Icons.shopping_bag_outlined,
                              color: Color(0xffec4899),
                              title: 'Shopping',
                              transactionCount: 32,
                              amount: '\$1,240',
                              percentage: '29%',
                            ),
                            const SizedBox(height: 12),
                            const CategoryListItem(
                              icon: Icons.restaurant_rounded,
                              color: Color(0xff3b82f6),
                              title: 'Food & Dining',
                              transactionCount: 45,
                              amount: '\$895',
                              percentage: '21%',
                            ),
                            const SizedBox(height: 12),
                            const CategoryListItem(
                              icon: Icons.directions_car_rounded,
                              color: Color(0xff14b8a6),
                              title: 'Transport',
                              transactionCount: 18,
                              amount: '\$642',
                              percentage: '15%',
                            ),
                            const SizedBox(height: 12),
                            const CategoryListItem(
                              icon: Icons.movie_outlined,
                              color: Color(0xffa855f7),
                              title: 'Entertainment',
                              transactionCount: 8,
                              amount: '\$428',
                              percentage: '10%',
                            ),
                            const SizedBox(height: 24),
                            // View Full Report
                            Divider(color: onSurface.withValues(alpha: 0.1)),
                            TextButton.icon(
                              onPressed: () {},
                              icon: Text(
                                'View Full Report',
                                style: GoogleFonts.manrope(
                                  fontSize: 12,
                                  color: const Color(0xff94a3b8),
                                ),
                              ),
                              label: const Icon(
                                Icons.arrow_forward_rounded,
                                size: 14,
                                color: Color(0xff94a3b8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Spending Insight
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(
                                0xffeab308,
                              ).withValues(alpha: isDark ? 0.05 : 0.1),
                              Colors.transparent,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: const Color(
                              0xffeab308,
                            ).withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xffeab308,
                                ).withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.lightbulb_outline_rounded,
                                color: Color(0xffeab308),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Spending Insight',
                                    style: GoogleFonts.manrope(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? const Color(0xfffef9c3)
                                          : const Color(0xffa16207),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Your spending in Shopping is 15% higher than last month. Consider setting a limit for next month.',
                                    style: GoogleFonts.manrope(
                                      fontSize: 12,
                                      color: isDark
                                          ? const Color(0xff94a3b8)
                                          : const Color(0xff4b5563),
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 120), // Bottom padding for Nav
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Bottom Nav
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: PremiumBottomNav(
              currentIndex: 1, // Analytics
              onTabSelected: (index) {
                if (index == 0) context.go('/home');
                if (index == 2) context.go('/wallet');
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

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, required this.onPressed});
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.glassBackground(context),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.glassBorder(context)),
        ),
        child: Icon(
          icon,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          size: 20,
        ),
      ),
    );
  }
}
