import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class MonthlyOverviewChart extends StatelessWidget {
  const MonthlyOverviewChart({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return Container(
      height: 350,
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.glassBackground(context),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.glassBorder(context)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _LegendItem(
                    color: const Color(0xff818cf8),
                    label: 'Income',
                    hasGlow: true,
                  ),
                  const SizedBox(width: 16),
                  _LegendItem(
                    color: onSurface.withValues(alpha: 0.3),
                    label: 'Expense',
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: onSurface.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: onSurface.withValues(alpha: 0.1)),
                ),
                child: Text(
                  'FEB 2024',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.glassLabel(context),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  _BarGroup(label: 'W1', incomeHeight: 0.6, expenseHeight: 0.3),
                  _BarGroup(
                    label: 'W2',
                    incomeHeight: 0.8,
                    expenseHeight: 0.45,
                  ),
                  _BarGroup(
                    label: 'W3',
                    incomeHeight: 0.5,
                    expenseHeight: 0.75,
                  ),
                  _BarGroup(
                    label: 'W4',
                    incomeHeight: 0.85,
                    expenseHeight: 0.4,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    this.hasGlow = false,
  });

  final Color color;
  final String label;
  final bool hasGlow;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: hasGlow
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.6),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: AppColors.glassLabel(context)),
        ),
      ],
    );
  }
}

class _BarGroup extends StatelessWidget {
  const _BarGroup({
    required this.label,
    required this.incomeHeight,
    required this.expenseHeight,
  });

  final String label;
  final double incomeHeight;
  final double expenseHeight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              width: 12,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0x334f46e5),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            Container(
              width: 12,
              height: 100 * incomeHeight,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color(0xff4f46e5), Color(0xff818cf8)],
                ),
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xff4f46e5).withValues(alpha: 0.5),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: 12,
          height: 100 * expenseHeight,
          decoration: BoxDecoration(
            color: onSurface.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: onSurface.withValues(alpha: 0.05)),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: AppColors.glassLabel(context)),
        ),
      ],
    );
  }
}
