import 'package:flutter/material.dart';

import '../../core/theme/app_tokens.dart';
import 'glass_card.dart';

enum AppTopBarActionStyle { neutral, primary, danger }

class AppTopBarAction {
  const AppTopBarAction({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.style = AppTopBarActionStyle.neutral,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final AppTopBarActionStyle style;
}

class AppTopBar extends StatelessWidget {
  const AppTopBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const <AppTopBarAction>[],
  });

  final String title;
  final String? subtitle;
  final List<AppTopBarAction> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassCard(
      padding: const EdgeInsets.all(AppTokens.spaceMd),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 560;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.headlineSmall),
              if (subtitle != null) ...[
                const SizedBox(height: AppTokens.spaceXs),
                Text(subtitle!, style: theme.textTheme.bodyMedium),
              ],
              if (actions.isNotEmpty) ...[
                SizedBox(
                  height: compact ? AppTokens.spaceSm : AppTokens.spaceMd,
                ),
                Wrap(
                  spacing: AppTokens.spaceSm,
                  runSpacing: AppTokens.spaceSm,
                  children: actions
                      .map((action) => _ActionChip(action: action))
                      .toList(growable: false),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({required this.action});

  final AppTopBarAction action;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    Color foreground;
    Color? background;
    BorderSide border;
    switch (action.style) {
      case AppTopBarActionStyle.primary:
        foreground = scheme.primary;
        background = scheme.primaryContainer.withValues(alpha: 0.6);
        border = BorderSide(color: scheme.primary.withValues(alpha: 0.3));
        break;
      case AppTopBarActionStyle.danger:
        foreground = scheme.error;
        background = scheme.errorContainer.withValues(alpha: 0.6);
        border = BorderSide(color: scheme.error.withValues(alpha: 0.35));
        break;
      case AppTopBarActionStyle.neutral:
        foreground = scheme.onSurface;
        background = scheme.surface.withValues(alpha: 0.45);
        border = BorderSide(color: Colors.white.withValues(alpha: 0.26));
        break;
    }

    return FilledButton.icon(
      onPressed: action.onPressed,
      icon: Icon(action.icon, size: 18),
      label: Text(action.label),
      style: FilledButton.styleFrom(
        foregroundColor: foreground,
        backgroundColor: background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          side: border,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppTokens.spaceMd,
          vertical: AppTokens.spaceSm,
        ),
      ),
    );
  }
}
