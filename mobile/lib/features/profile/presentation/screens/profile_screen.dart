import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../shared/widgets/brand_banner.dart';
import '../../../../shared/widgets/glass_button.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/glass_scaffold.dart';
import '../../../../shared/widgets/glass_text_field.dart';
import '../../../auth/providers/auth_notifier.dart';
import '../../providers/profile_notifier.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currencyController = TextEditingController();
  bool _aiEnabled = true;
  bool _initializedForm = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(profileNotifierProvider).load());
  }

  @override
  void dispose() {
    _currencyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider);
    final profileState = ref.watch(profileNotifierProvider);
    final profile = profileState.profile;

    if (profile != null && !_initializedForm) {
      _currencyController.text = profile.baseCurrency;
      _aiEnabled = profile.aiEnabled;
      _initializedForm = true;
    }

    return GlassScaffold(
      appBar: AppBar(
        title: const Text('Mi perfil'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppTokens.spaceSm),
            child: TextButton.icon(
              onPressed: auth.isBusy
                  ? null
                  : () async {
                      await ref.read(authNotifierProvider).signOut();
                    },
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text('Salir'),
            ),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth > 740 ? 620.0 : 540.0;
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const BrandBanner(
                          title: 'Tu centro de configuracion',
                          subtitle:
                              'Ajusta tu moneda principal y preferencias de IA para personalizar todo el flujo financiero.',
                        ),
                        const SizedBox(height: AppTokens.spaceLg),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppTokens.spaceMd),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surface.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(
                              AppTokens.radiusMd,
                            ),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.verified_user_outlined,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: AppTokens.spaceSm),
                              Expanded(
                                child: Text(
                                  auth.session?.email ?? '-',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppTokens.spaceMd),
                        GlassTextField(
                          controller: _currencyController,
                          label: 'Moneda base (ISO)',
                          textInputAction: TextInputAction.done,
                          prefixIcon: Icons.attach_money_rounded,
                          onFieldSubmitted: (_) => _save(),
                          validator: (value) {
                            if (value == null || value.trim().length != 3) {
                              return 'Usa codigo de 3 letras (ej. USD)';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppTokens.spaceSm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTokens.spaceSm,
                            vertical: AppTokens.spaceXs,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surface.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(
                              AppTokens.radiusMd,
                            ),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.28),
                            ),
                          ),
                          child: SwitchListTile.adaptive(
                            contentPadding: EdgeInsets.zero,
                            value: _aiEnabled,
                            onChanged: (value) =>
                                setState(() => _aiEnabled = value),
                            title: const Text('Asistente IA habilitado'),
                            subtitle: const Text(
                              'Recomendaciones y analisis contextual',
                            ),
                          ),
                        ),
                        if (profileState.error != null) ...[
                          const SizedBox(height: AppTokens.spaceMd),
                          Container(
                            width: double.infinity,
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
                              profileState.error!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: AppTokens.spaceMd),
                        if (profileState.isLoading && profile == null)
                          const Center(child: CircularProgressIndicator())
                        else
                          GlassButton(
                            label: 'Guardar cambios',
                            icon: Icons.save_outlined,
                            loading: profileState.isSaving,
                            onPressed: _save,
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

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    await ref
        .read(profileNotifierProvider)
        .save(
          baseCurrency: _currencyController.text.trim().toUpperCase(),
          aiEnabled: _aiEnabled,
        );
  }
}
