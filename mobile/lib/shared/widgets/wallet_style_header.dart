import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class WalletStyleHeader extends StatelessWidget {
  const WalletStyleHeader({
    super.key,
    required this.leading,
    required this.actions,
    this.padding = const EdgeInsets.only(
      top: 60,
      left: 24,
      right: 24,
      bottom: 16,
    ),
  });

  final Widget leading;
  final List<Widget> actions;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(child: leading),
          if (actions.isNotEmpty) const SizedBox(width: 16),
          if (actions.isNotEmpty)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: _buildActionsWithSpacing(actions),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildActionsWithSpacing(List<Widget> actions) {
    return List<Widget>.generate(actions.length * 2 - 1, (index) {
      if (index.isOdd) {
        return const SizedBox(width: 12);
      }
      return actions[index ~/ 2];
    });
  }
}

class WalletHeaderActionButton extends StatelessWidget {
  const WalletHeaderActionButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.semanticLabel,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final iconWidget = Icon(
      icon,
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
      size: 22,
    );

    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.glassBackground(context),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.glassBorder(context)),
            ),
            alignment: Alignment.center,
            child: iconWidget,
          ),
        ),
      ),
    );
  }
}
