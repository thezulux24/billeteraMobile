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

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  String? _message;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider);

    return GlassScaffold(
      appBar: AppBar(title: const Text('Recuperar acceso')),
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
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const BrandBanner(
                          title: 'Recupera tu cuenta',
                          subtitle:
                              'Te enviaremos un enlace seguro para restablecer la contrasena y volver a entrar.',
                        ),
                        const SizedBox(height: AppTokens.spaceLg),
                        GlassTextField(
                          controller: _emailController,
                          label: 'Correo electronico',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                          prefixIcon: Icons.mark_email_read_outlined,
                          onFieldSubmitted: (_) => _submit(auth),
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
                          const SizedBox(height: AppTokens.spaceSm),
                        ],
                        if (_message != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTokens.spaceSm,
                              vertical: AppTokens.spaceXs,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer
                                  .withValues(alpha: 0.75),
                              borderRadius: BorderRadius.circular(
                                AppTokens.radiusSm,
                              ),
                            ),
                            child: Text(_message!),
                          ),
                          const SizedBox(height: AppTokens.spaceSm),
                        ],
                        GlassButton(
                          label: 'Enviar enlace',
                          icon: Icons.send_outlined,
                          loading: auth.isBusy,
                          onPressed: () => _submit(auth),
                        ),
                        const SizedBox(height: AppTokens.spaceSm),
                        TextButton(
                          onPressed: () => context.pop(),
                          child: const Text('Volver al login'),
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

  Future<void> _submit(AuthNotifier auth) async {
    auth.clearError();
    setState(() => _message = null);
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    await ref
        .read(authNotifierProvider)
        .recoverPassword(email: _emailController.text.trim());

    if (mounted && auth.error == null) {
      setState(() {
        _message = 'Si el email existe, recibiras instrucciones.';
      });
    }
  }
}
