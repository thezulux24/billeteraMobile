import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/auth/providers/auth_notifier.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/analytics/presentation/screens/analytics_screen.dart';
import '../features/wallet/presentation/screens/wallet_assets_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/wallet/presentation/screens/account_details_screen.dart';
import 'package:flutter/material.dart';

// Premium fade and slight scale transition
Page<dynamic> _buildPageWithTransition(
  BuildContext context,
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Fade in
      final fadeAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));

      // Slight scale up from 95% to 100%
      final scaleAnimation = Tween<double>(
        begin: 0.95,
        end: 1.0,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

      return FadeTransition(
        opacity: fadeAnimation,
        child: ScaleTransition(scale: scaleAnimation, child: child),
      );
    },
  );
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/home',
        pageBuilder: (context, state) =>
            _buildPageWithTransition(context, state, const HomeScreen()),
      ),
      GoRoute(
        path: '/analytics',
        pageBuilder: (context, state) =>
            _buildPageWithTransition(context, state, const AnalyticsScreen()),
      ),
      GoRoute(
        path: '/wallet',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context,
          state,
          const WalletAssetsScreen(),
        ),
      ),
      GoRoute(
        path: '/profile',
        pageBuilder: (context, state) =>
            _buildPageWithTransition(context, state, const ProfileScreen()),
      ),
      GoRoute(
        path: '/account-details',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          return AccountDetailsScreen(
            assetId: args['assetId'] as String,
            assetName: args['assetName'] as String,
            assetSubtitle: args['subtitle'] as String?,
            assetAmount: args['amount'] as String,
            accentColor: args['accentColor'] as Color,
          );
        },
      ),
    ],
    redirect: (context, state) {
      final path = state.uri.path;
      final authPaths = <String>{'/login', '/register', '/forgot-password'};

      if (!auth.isInitialized) {
        return path == '/splash' ? null : '/splash';
      }

      if (!auth.isAuthenticated) {
        if (authPaths.contains(path)) {
          return null;
        }
        return '/login';
      }

      if (path == '/splash' || authPaths.contains(path)) {
        return '/home';
      }

      return null;
    },
  );
});
