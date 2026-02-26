import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../shared/widgets/brand_banner.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/glass_scaffold.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTokens.spaceLg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: GlassCard(
              padding: const EdgeInsets.all(AppTokens.spaceLg),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  BrandBanner(
                    title: 'billeteraMobile',
                    subtitle:
                        'Preparando tus datos y protegiendo tu sesion de forma segura.',
                  ),
                  SizedBox(height: AppTokens.spaceMd),
                  Center(child: CircularProgressIndicator()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
