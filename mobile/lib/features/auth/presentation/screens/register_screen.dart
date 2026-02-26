import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../shared/widgets/brand_banner.dart';
import '../../../../shared/widgets/glass_button.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/glass_scaffold.dart';
import '../../../../shared/widgets/glass_text_field.dart';
import '../../providers/auth_notifier.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _submit(AuthNotifier auth) async {
    auth.clearError();
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final notifier = ref.read(authNotifierProvider);
    await notifier.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    if (!mounted) {
      return;
    }
    if (notifier.isAuthenticated) {
      context.go('/profile');
    }
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
      appBar: AppBar(title: const Text('Crear cuenta')),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth > 640 ? 520.0 : 460.0;
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTokens.spaceLg),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: GlassCard(
                  padding: const EdgeInsets.all(AppTokens.spaceLg),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const BrandBanner(
                          title: 'Comienza hoy',
                          subtitle:
                              'Crea tu cuenta para activar seguimiento de gastos, metas y alertas personalizadas.',
                        ),
                        const SizedBox(height: AppTokens.spaceLg),
                        GlassTextField(
                          controller: _emailController,
                          label: 'Correo electronico',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          prefixIcon: Icons.mail_outline_rounded,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Ingresa tu email';
                            }
                            if (!value.contains('@')) {
                              return 'Email invalido';
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
                            if (value == null || value.length < 8) {
                              return 'Minimo 8 caracteres';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppTokens.spaceSm),
                        if (auth.error != null) ...[
                          Container(
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
                            child: Text(
                              auth.error!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppTokens.spaceMd),
                        ] else
                          const SizedBox(height: AppTokens.spaceXs),
                        GlassButton(
                          label: 'Crear cuenta',
                          icon: Icons.person_add_alt_1_rounded,
                          loading: auth.isBusy,
                          onPressed: () => _submit(auth),
                        ),
                        const SizedBox(height: AppTokens.spaceSm),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Ya tienes cuenta?'),
                            TextButton(
                              onPressed: () => context.pop(),
                              child: const Text('Volver al login'),
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
