import 'package:flutter/material.dart';

import '../../core/theme/app_tokens.dart';

enum AppPopupType { info, success, error }

void showAppPopup(
  BuildContext context, {
  required String message,
  AppPopupType type = AppPopupType.info,
}) {
  final scheme = Theme.of(context).colorScheme;

  IconData icon;
  Color background;
  switch (type) {
    case AppPopupType.success:
      icon = Icons.check_circle_outline_rounded;
      background = Colors.green.shade700;
      break;
    case AppPopupType.error:
      icon = Icons.error_outline_rounded;
      background = scheme.error;
      break;
    case AppPopupType.info:
      icon = Icons.info_outline_rounded;
      background = scheme.primary;
      break;
  }

  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(AppTokens.spaceMd),
      backgroundColor: background,
      duration: const Duration(seconds: 3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
      ),
      content: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: AppTokens.spaceSm),
          Expanded(
            child: Text(message, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ),
  );
}
