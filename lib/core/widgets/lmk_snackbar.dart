import 'package:flutter/material.dart';

import '../constants/constants.dart';

/// Muestra un SnackBar temático Resonant Horizon con acción opcional.
void showLmkSnackBar(
  BuildContext context, {
  required String message,
  String? actionLabel,
  VoidCallback? onAction,
  Duration duration = const Duration(seconds: 4),
  Color? backgroundColor,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final bgColor =
      backgroundColor ??
      (isDark ? AppColors.bgTertiaryDark : AppColors.textPrimary);
  final textColor = isDark ? AppColors.textPrimaryDark : AppColors.bgPrimary;
  final actionColor = isDark
      ? AppColors.accentPrimaryDark
      : AppColors.accentSecondary;

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTypography.bodySmall.copyWith(
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        margin: const EdgeInsets.all(AppSpacing.md),
        duration: duration,
        action: actionLabel != null && onAction != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: actionColor,
                onPressed: onAction,
              )
            : null,
      ),
    );
}
