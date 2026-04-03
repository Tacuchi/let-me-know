import 'package:flutter/material.dart';

import '../constants/constants.dart';
import 'lmk_icon_box.dart';
import 'lmk_gradient_text.dart';

/// Estado vacío con icono animado, título y subtítulo.
///
/// Patrón reutilizable para listas vacías, búsquedas sin resultados, etc.
class LmkEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;
  final Color? iconColor;

  /// Si es true, el título se renderiza con gradiente primario.
  final bool useGradientTitle;

  const LmkEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
    this.iconColor,
    this.useGradientTitle = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        iconColor ??
        (isDark ? AppColors.accentPrimaryDark : AppColors.accentPrimary);
    final textColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;
    final helperColor = isDark
        ? AppColors.textHelperDark
        : AppColors.textHelper;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.8, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(scale: value, child: child);
              },
              child: LmkIconBox(
                icon: icon,
                color: primaryColor,
                circle: true,
                size: 56,
                padding: AppSpacing.lg,
                backgroundOpacity: 0.10,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (useGradientTitle)
              LmkGradientText(
                title,
                style: AppTypography.titleSmall,
                textAlign: TextAlign.center,
              )
            else
              Text(
                title,
                style: AppTypography.titleSmall.copyWith(color: textColor),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              subtitle,
              style: AppTypography.bodyMedium.copyWith(color: helperColor),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: AppSpacing.lg),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
