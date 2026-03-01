import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class GlassScaffold extends StatelessWidget {
  const GlassScaffold({
    super.key,
    required this.child,
    this.appBar,
    this.showOrbs = true,
    this.isPremium = false,
  });

  final Widget child;
  final PreferredSizeWidget? appBar;
  final bool showOrbs;
  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = isPremium
        ? (isDark ? const Color(0xFF0C1026) : const Color(0xFFF4F6FF))
        : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC));

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: appBar,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: backgroundColor,
          gradient: isPremium
              ? (isDark
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF0B0F23),
                          Color(0xFF141B3A),
                          Color(0xFF1D2450),
                        ],
                        stops: [0.0, 0.45, 1.0],
                      )
                    : const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFF8FAFF),
                          Color(0xFFEEF2FF),
                          Color(0xFFE9EEFF),
                        ],
                        stops: [0.0, 0.5, 1.0],
                      ))
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? const [
                          AppColors.darkBackgroundTop,
                          AppColors.darkBackgroundBottom,
                        ]
                      : const [
                          AppColors.lightBackgroundTop,
                          AppColors.lightBackgroundBottom,
                        ],
                ),
        ),
        child: Stack(
          children: [
            if (showOrbs) ..._buildOrbs(isDark),
            SafeArea(child: child),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildOrbs(bool isDark) {
    if (isPremium) {
      return [
        // Large indigo accent
        _decorativeOrb(
          top: -150,
          left: -140,
          size: 560,
          color: const Color(0xFF4F46E5),
          alpha: isDark ? 0.16 : 0.12,
          blurRadius: 170,
        ),
        // Soft purple center glow
        _decorativeOrb(
          top: 30,
          right: -100,
          size: 420,
          color: const Color(0xFF7C3AED),
          alpha: isDark ? 0.12 : 0.08,
          blurRadius: 130,
        ),
        // Bottom blue highlight
        _decorativeOrb(
          bottom: -150,
          right: -120,
          size: 500,
          color: const Color(0xFF2563EB),
          alpha: isDark ? 0.12 : 0.09,
          blurRadius: 160,
        ),
      ];
    }

    final topColor = isDark
        ? AppColors.orbBlue.withValues(alpha: 0.18)
        : AppColors.orbBlue.withValues(alpha: 0.26);
    final rightColor = isDark
        ? AppColors.orbGold.withValues(alpha: 0.12)
        : AppColors.orbGold.withValues(alpha: 0.18);
    final bottomColor = isDark
        ? AppColors.orbCyan.withValues(alpha: 0.14)
        : AppColors.orbPink.withValues(alpha: 0.14);

    return [
      _decorativeOrb(top: -70, left: -50, size: 220, color: topColor),
      _decorativeOrb(top: 120, right: -90, size: 260, color: rightColor),
      _decorativeOrb(bottom: -120, left: 40, size: 240, color: bottomColor),
    ];
  }

  Widget _decorativeOrb({
    double? top,
    double? left,
    double? right,
    double? bottom,
    required double size,
    required Color color,
    double? alpha,
    double? blurRadius,
  }) {
    final orbColor = alpha != null ? color.withValues(alpha: alpha) : color;
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: IgnorePointer(
        child: blurRadius != null
            ? Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: orbColor,
                  boxShadow: [
                    BoxShadow(
                      color: orbColor,
                      blurRadius: blurRadius,
                      spreadRadius: blurRadius / 2,
                    ),
                  ],
                ),
              )
            : Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [orbColor, orbColor.withValues(alpha: 0)],
                  ),
                ),
              ),
      ),
    );
  }
}
