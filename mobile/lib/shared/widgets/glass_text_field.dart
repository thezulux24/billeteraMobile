import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';

class GlassTextField extends StatelessWidget {
  const GlassTextField({
    super.key,
    required this.controller,
    required this.label,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.prefixIcon,
    this.textInputAction,
    this.onFieldSubmitted,
    this.isPremium = false,
  });

  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;
  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final isDark = theme.brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      style: TextStyle(color: onSurface),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: onSurface.withValues(alpha: 0.6)),
        prefixIcon: prefixIcon == null
            ? null
            : Icon(prefixIcon, color: onSurface.withValues(alpha: 0.6)),
        filled: true,
        fillColor: isPremium
            ? AppColors.glassBackground(context)
            : (isDark
                  ? AppColors.glassDark
                  : Colors.black.withValues(alpha: 0.05)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          borderSide: BorderSide(
            color: isPremium
                ? AppColors.glassBorder(context)
                : (isDark
                      ? AppColors.glassBorderDark
                      : Colors.black.withValues(alpha: 0.1)),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          borderSide: BorderSide(
            color: isPremium
                ? AppColors.glassBorder(context)
                : (isDark
                      ? AppColors.glassBorderDark
                      : Colors.black.withValues(alpha: 0.1)),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          borderSide: const BorderSide(color: AppColors.stitchIndigo),
        ),
      ),
    );
  }
}
