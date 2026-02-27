import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../shared/widgets/app_popup.dart';
import '../../../../shared/widgets/glass_button.dart';
import '../../../../shared/widgets/glass_scaffold.dart';
import '../../../../shared/widgets/glass_text_field.dart';
import '../../../../shared/widgets/premium_brand_icon.dart';
import '../../../../shared/widgets/social_login_button.dart';
import '../../providers/auth_notifier.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  static final RegExp _emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showContent = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _showContent = true);
      }
    });
  }

  Future<void> _submit(AuthNotifier auth) async {
    auth.clearError();
    final inputError = _validateInputs();
    if (inputError != null) {
      showAppPopup(context, message: inputError, type: AppPopupType.error);
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) {
      showAppPopup(
        context,
        message: 'Revisa los campos marcados antes de continuar.',
        type: AppPopupType.error,
      );
      return;
    }
    final notifier = ref.read(authNotifierProvider);
    await notifier.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    if (!mounted) {
      return;
    }
    if (notifier.isAuthenticated) {
      context.go('/home');
      return;
    }
    if (notifier.error != null) {
      showAppPopup(context, message: notifier.error!, type: AppPopupType.error);
    }
  }

  String? _validateInputs() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty) {
      return 'Ingresa tu correo electronico.';
    }
    if (!_emailRegex.hasMatch(email)) {
      return 'Correo invalido. Usa un formato como nombre@dominio.com.';
    }
    if (password.length < 8) {
      return 'La contrasena debe tener al menos 8 caracteres.';
    }

    final hasUpper = RegExp(r'[A-Z]').hasMatch(password);
    final hasLower = RegExp(r'[a-z]').hasMatch(password);
    final hasNumber = RegExp(r'\d').hasMatch(password);
    if (!hasUpper || !hasLower || !hasNumber) {
      return 'La contrasena debe incluir mayuscula, minuscula y numero.';
    }

    return null;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider);

    return GlassScaffold(
      isPremium: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth > 640 ? 520.0 : 460.0;
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTokens.spaceLg),
              child: AnimatedOpacity(
                opacity: _showContent ? 1 : 0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
                child: AnimatedSlide(
                  offset: _showContent ? Offset.zero : const Offset(0, 0.06),
                  duration: const Duration(milliseconds: 560),
                  curve: Curves.easeOutCubic,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Center(child: PremiumBrandIcon()),
                        const SizedBox(height: AppTokens.spaceLg),
                        const Text(
                          'Welcome Back',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: AppTokens.spaceXs),
                        const Text(
                          'Continue your premium financial journey',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Colors.white60),
                        ),
                        const SizedBox(height: AppTokens.spaceLg * 1.5),
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              GlassTextField(
                                controller: _emailController,
                                label: 'Email Address',
                                isPremium: true,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                              ),
                              const SizedBox(height: AppTokens.spaceMd),
                              GlassTextField(
                                controller: _passwordController,
                                label: 'Password',
                                isPremium: true,
                                obscureText: true,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _submit(auth),
                              ),
                              const SizedBox(height: AppTokens.spaceSm),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () =>
                                      context.push('/forgot-password'),
                                  child: const Text(
                                    'Forgot password?',
                                    style: TextStyle(
                                      color: Colors.white38,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppTokens.spaceMd),
                              GlassButton(
                                isPremium: true,
                                label: 'Log In',
                                loading: auth.isBusy,
                                onPressed: () => _submit(auth),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppTokens.spaceLg),
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'Or continue with',
                                style: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTokens.spaceLg),
                        Row(
                          children: [
                            SocialLoginButton(
                              icon: const Icon(
                                Icons.g_mobiledata,
                                color: Colors.white,
                                size: 28,
                              ),
                              label: 'Google',
                              onPressed: () {},
                            ),
                            const SizedBox(width: AppTokens.spaceMd),
                            SocialLoginButton(
                              icon: const Icon(
                                Icons.apple,
                                color: Colors.white,
                                size: 24,
                              ),
                              label: 'Apple',
                              onPressed: () {},
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTokens.spaceLg),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'New to WealthFlow?',
                              style: TextStyle(color: Colors.white60),
                            ),
                            TextButton(
                              onPressed: () => context.push('/register'),
                              child: const Text(
                                'Create account',
                                style: TextStyle(
                                  color: Color(0xFFA5B4FC),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
