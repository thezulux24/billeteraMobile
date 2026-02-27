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
        ? (isDark
              ? AppColors.stitchDarkBackground
              : AppColors.lightBackgroundTop)
        : (isDark ? Colors.black : Colors.white);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: appBar,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: backgroundColor,
          gradient: isPremium
              ? null
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
        // Top Left Indigo mesh
        _decorativeOrb(
          top: -100,
          left: -100,
          size: 500,
          color: const Color(0xff4F46E5),
          alpha: 0.15,
          blurRadius: 150,
        ),
        // Top Center Blue mesh
        _decorativeOrb(
          top: -50,
          left: 100,
          size: 400,
          color: const Color(0xff2513ec),
          alpha: 0.1,
          blurRadius: 120,
        ),
        // Bottom Right Pink/Purple mesh
        _decorativeOrb(
          bottom: -100,
          right: -100,
          size: 450,
          color: const Color(0xffec4899),
          alpha: 0.12,
          blurRadius: 140,
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
