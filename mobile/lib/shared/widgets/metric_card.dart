import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.totalBalance,
    this.trendPercentage = 2.4,
    required this.totalAssets,
    required this.creditDebt,
  });

  final double totalBalance;
  final double trendPercentage;
  final double totalAssets;
  final double creditDebt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.glassBackground(context),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.glassBorder(context)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Background decorative elements
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: onSurface.withValues(alpha: 0.03),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Net Balance',
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.glassLabel(context),
                          ),
                        ),
                        const SizedBox(height: 8),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '\$${totalBalance.toStringAsFixed(0)}',
                                style: GoogleFonts.manrope(
                                  fontSize: 44,
                                  fontWeight: FontWeight.bold,
                                  color: onSurface,
                                  letterSpacing: -1,
                                ),
                              ),
                              TextSpan(
                                text: '.00',
                                style: GoogleFonts.manrope(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w400,
                                  color: onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xff10b981).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: const Color(0xff10b981).withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.trending_up,
                            size: 16,
                            color: Color(0xff10b981),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$trendPercentage%',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff10b981),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Divider
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        onSurface.withValues(alpha: 0.15),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _MetricItem(
                        label: 'Total Assets',
                        value: '\$${totalAssets.toStringAsFixed(0)}',
                        trend: '+5.1%',
                        trendColor: const Color(0xff10b981),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            onSurface.withValues(alpha: 0.1),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: _MetricItem(
                        label: 'Credit Debt',
                        value: '\$${creditDebt.toStringAsFixed(0)}',
                        trend: '-1.2%',
                        trendColor: const Color(0xfff43f5e),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  const _MetricItem({
    required this.label,
    required this.value,
    required this.trend,
    required this.trendColor,
    this.textAlign = TextAlign.left,
  });

  final String label;
  final String value;
  final String trend;
  final Color trendColor;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return Column(
      crossAxisAlignment: textAlign == TextAlign.left
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 12,
            color: AppColors.glassLabel(context),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: textAlign == TextAlign.left
              ? MainAxisAlignment.start
              : MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: onSurface,
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                trend,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: trendColor,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
