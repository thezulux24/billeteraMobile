import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class GlassScaffold extends StatelessWidget {
  const GlassScaffold({
    super.key,
    required this.child,
    this.appBar,
    this.showOrbs = true,
  });

  final Widget child;
  final PreferredSizeWidget? appBar;
  final bool showOrbs;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: appBar,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
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
      _decorativeOrb(
        top: -70,
        left: -50,
        size: 220,
        color: topColor,
      ),
      _decorativeOrb(
        top: 120,
        right: -90,
        size: 260,
        color: rightColor,
      ),
      _decorativeOrb(
        bottom: -120,
        left: 40,
        size: 240,
        color: bottomColor,
      ),
    ];
  }

  Widget _decorativeOrb({
    double? top,
    double? left,
    double? right,
    double? bottom,
    required double size,
    required Color color,
  }) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [color, color.withValues(alpha: 0)],
            ),
          ),
        ),
      ),
    );
  }
}
