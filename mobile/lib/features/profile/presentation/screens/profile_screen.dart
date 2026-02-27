import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../shared/widgets/glass_scaffold.dart';
import '../../../../shared/widgets/premium_bottom_nav.dart';
import '../../../auth/providers/auth_notifier.dart';
import '../../../../core/theme/app_colors.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final isDark = theme.brightness == Brightness.dark;

    final auth = ref.watch(authNotifierProvider);
    final userEmail = auth.session?.email ?? 'Alex Sterling';
    final userName = userEmail.split('@').first;
    final capitalizedName = userName[0].toUpperCase() + userName.substring(1);

    return GlassScaffold(
      isPremium: true,
      child: Stack(
        children: [
          // Background content
          Column(
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
                    _IconBtn(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onPressed: () => context.go('/home'),
                    ),
                    Text(
                      'Profile',
                      style: GoogleFonts.manrope(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: onSurface,
                      ),
                    ),
                    _IconBtn(icon: Icons.edit_outlined, onPressed: () {}),
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
                      const SizedBox(height: 20),
                      // Avatar Section
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.glassBackground(context),
                              border: Border.all(
                                color: AppColors.glassBorder(context),
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: Image.network(
                                'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?ixlib=rb-1.2.1&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xff14b8a6),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xff0f0e17)
                                    : Colors.white,
                                width: 4,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.verified_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        capitalizedName,
                        style: GoogleFonts.manrope(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: onSurface,
                        ),
                      ),
                      const Text(
                        'Premium Member • Joined 2023',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xff94a3b8),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Settings Groups
                      _SettingsGroup(
                        items: [
                          _SettingsItem(
                            icon: Icons.person_outline_rounded,
                            color: const Color(0xff14b8a6),
                            title: 'Personal Information',
                            onTap: () {},
                          ),
                          _SettingsItem(
                            icon: Icons.notifications_active_outlined,
                            color: const Color(0xffa855f7),
                            title: 'Notifications',
                            onTap: () {},
                          ),
                          _SettingsItem(
                            icon: Icons.security_outlined,
                            color: const Color(0xffec4899),
                            title: 'Privacy & Security',
                            onTap: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _SettingsGroup(
                        items: [
                          _SettingsItem(
                            icon: Icons.account_balance_wallet_outlined,
                            color: const Color(0xff3b82f6),
                            title: 'Payment Methods',
                            onTap: () {},
                          ),
                          _SettingsItem(
                            icon: Icons.help_outline_rounded,
                            color: const Color(0xff14b8a6),
                            title: 'Help & Support',
                            onTap: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Log Out Button
                      GestureDetector(
                        onTap: () async {
                          await ref.read(authNotifierProvider).signOut();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xffec4899,
                            ).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: const Color(
                                0xffec4899,
                              ).withValues(alpha: 0.3),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.logout_rounded,
                                color: Color(0xffec4899),
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Log Out',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xffec4899),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 120),
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
              currentIndex: 3, // Settings/Profile
              onTabSelected: (index) {
                if (index == 0) context.go('/home');
                if (index == 1) context.go('/analytics');
                if (index == 2) context.go('/wallet');
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
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          size: 20,
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.items});
  final List<Widget> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.glassBackground(context),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.glassBorder(context)),
      ),
      child: Column(children: items),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  const _SettingsItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xff64748b),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
