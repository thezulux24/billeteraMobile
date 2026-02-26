import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../shared/widgets/app_popup.dart';
import '../../../../shared/widgets/app_top_bar.dart';
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth > 740 ? 620.0 : 540.0;
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTokens.spaceLg),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppTopBar(
                        title: 'Mi perfil',
                        subtitle: 'Personaliza tu experiencia y preferencias.',
                        actions: [
                          AppTopBarAction(
                            label: 'Inicio',
                            icon: Icons.home_outlined,
                            style: AppTopBarActionStyle.primary,
                            onPressed: () => context.go('/home'),
                          ),
                          AppTopBarAction(
                            label: 'Salir',
                            icon: Icons.logout_rounded,
                            style: AppTopBarActionStyle.danger,
                            onPressed: auth.isBusy
                                ? null
                                : () async {
                                    await ref
                                        .read(authNotifierProvider)
                                        .signOut();
                                  },
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTokens.spaceLg),
                      GlassCard(
                        padding: const EdgeInsets.all(AppTokens.spaceLg),
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
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
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
                    ],
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
    final notifier = ref.read(profileNotifierProvider);
    if (notifier.isSaving) {
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) {
      showAppPopup(
        context,
        message: 'Revisa la moneda base antes de guardar.',
        type: AppPopupType.error,
      );
      return;
    }

    final nextCurrency = _currencyController.text.trim().toUpperCase();
    final currentProfile = notifier.profile;
    if (currentProfile != null &&
        currentProfile.baseCurrency.toUpperCase() == nextCurrency &&
        currentProfile.aiEnabled == _aiEnabled) {
      showAppPopup(
        context,
        message: 'No hay cambios para guardar.',
        type: AppPopupType.info,
      );
      return;
    }

    await notifier.save(baseCurrency: nextCurrency, aiEnabled: _aiEnabled);
    if (!mounted) {
      return;
    }

    if (notifier.error != null) {
      showAppPopup(context, message: notifier.error!, type: AppPopupType.error);
      return;
    }

    showAppPopup(
      context,
      message: 'Perfil actualizado correctamente.',
      type: AppPopupType.success,
    );
    context.go('/home');
  }
}
