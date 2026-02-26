import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../shared/widgets/app_popup.dart';
import '../../../../shared/widgets/brand_banner.dart';
import '../../../../shared/widgets/glass_button.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/glass_scaffold.dart';
import '../../../../shared/widgets/glass_text_field.dart';
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
                    child: GlassCard(
                      padding: const EdgeInsets.all(AppTokens.spaceLg),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const BrandBanner(
                              title: 'Control real de tu dinero',
                              subtitle:
                                  'Inicia sesion para ver cuentas, presupuesto y metas en un solo flujo.',
                            ),
                            const SizedBox(height: AppTokens.spaceLg),
                            GlassTextField(
                              controller: _emailController,
                              label: 'Correo electronico',
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              prefixIcon: Icons.mail_outline_rounded,
                              validator: (value) {
                                final email = (value ?? '').trim();
                                if (email.isEmpty) {
                                  return 'Ingresa tu email';
                                }
                                if (!_emailRegex.hasMatch(email)) {
                                  return 'Correo invalido';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppTokens.spaceMd),
                            GlassTextField(
                              controller: _passwordController,
                              label: 'Contrasena',
                              obscureText: true,
                              textInputAction: TextInputAction.done,
                              prefixIcon: Icons.lock_outline_rounded,
                              onFieldSubmitted: (_) => _submit(auth),
                              validator: (value) {
                                final password = value ?? '';
                                if (password.length < 8) {
                                  return 'Minimo 8 caracteres';
                                }
                                final hasUpper = RegExp(
                                  r'[A-Z]',
                                ).hasMatch(password);
                                final hasLower = RegExp(
                                  r'[a-z]',
                                ).hasMatch(password);
                                final hasNumber = RegExp(
                                  r'\d',
                                ).hasMatch(password);
                                if (!hasUpper || !hasLower || !hasNumber) {
                                  return 'Incluye mayuscula, minuscula y numero';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppTokens.spaceSm),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () =>
                                    context.push('/forgot-password'),
                                child: const Text('Olvide mi contrasena'),
                              ),
                            ),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 320),
                              switchInCurve: Curves.easeOutCubic,
                              switchOutCurve: Curves.easeInCubic,
                              child: auth.error == null
                                  ? const SizedBox(
                                      key: ValueKey('no-login-error'),
                                      height: AppTokens.spaceXs,
                                    )
                                  : Container(
                                      key: ValueKey(auth.error),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppTokens.spaceSm,
                                        vertical: AppTokens.spaceXs,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .errorContainer
                                            .withValues(alpha: 0.75),
                                        borderRadius: BorderRadius.circular(
                                          AppTokens.radiusSm,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.error_outline_rounded,
                                            size: 18,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.error,
                                          ),
                                          const SizedBox(
                                            width: AppTokens.spaceXs,
                                          ),
                                          Expanded(
                                            child: Text(
                                              auth.error!,
                                              style: TextStyle(
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.error,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                            ),
                            const SizedBox(height: AppTokens.spaceMd),
                            GlassButton(
                              label: 'Entrar a mi cuenta',
                              icon: Icons.arrow_forward_rounded,
                              loading: auth.isBusy,
                              onPressed: () => _submit(auth),
                            ),
                            const SizedBox(height: AppTokens.spaceSm),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Nuevo en billeteraMobile?'),
                                TextButton(
                                  onPressed: () => context.push('/register'),
                                  child: const Text('Crear cuenta'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
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
