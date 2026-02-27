import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class PremiumBottomNav extends StatelessWidget {
  const PremiumBottomNav({
    super.key,
    required this.onAddPressed,
    this.currentIndex = 0,
    required this.onTabSelected,
  });

  final VoidCallback onAddPressed;
  final int currentIndex;
  final Function(int) onTabSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 100,
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xff1b1933).withValues(alpha: 0.8)
              : Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.glassBorder(context)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
              blurRadius: 32,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _NavButton(
              icon: Icons.home,
              label: 'Home',
              isActive: currentIndex == 0,
              onTap: () => onTabSelected(0),
            ),
            _NavButton(
              icon: Icons.pie_chart_outline,
              label: 'Analytics',
              isActive: currentIndex == 1,
              onTap: () => onTabSelected(1),
            ),
            _CenterAddButton(onPressed: onAddPressed),
            _NavButton(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Wallet',
              isActive: currentIndex == 2,
              onTap: () => onTabSelected(2),
            ),
            _NavButton(
              icon: Icons.settings_outlined,
              label: 'Settings',
              isActive: currentIndex == 3,
              onTap: () => onTabSelected(3),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.label,
    this.isActive = false,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? const Color(0xff818cf8) : const Color(0xff94a3b8);
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 26,
            shadows: isActive
                ? [Shadow(color: color.withValues(alpha: 0.5), blurRadius: 8)]
                : null,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _CenterAddButton extends StatelessWidget {
  const _CenterAddButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -15),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xff4f46e5), Color(0xff7c3aed)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xff4f46e5).withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: const Color(0xff1b1933).withValues(alpha: 0.5),
            width: 5,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: const Icon(Icons.add, color: Colors.white, size: 30),
          ),
        ),
      ),
    );
  }
}
