import 'package:flutter/material.dart';

import '../constants/constants.dart';

/// Contador animado con el tema Resonant Horizon.
///
/// Muestra un valor numérico con animación y una etiqueta debajo.
class LmkAnimatedCounter extends StatelessWidget {
  final int value;
  final String label;
  final Color? color;
  final Color? backgroundColor;
  final Duration duration;

  const LmkAnimatedCounter({
    super.key,
    required this.value,
    required this.label,
    this.color,
    this.backgroundColor,
    this.duration = const Duration(milliseconds: 500),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveColor =
        color ??
        (isDark ? AppColors.accentPrimaryDark : AppColors.accentPrimary);
    final effectiveBg =
        backgroundColor ??
        effectiveColor.withValues(alpha: isDark ? 0.2 : 0.12);
    final textColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimary;
    final secondaryColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
        horizontal: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: value),
            duration: duration,
            curve: Curves.easeOutCubic,
            builder: (context, animatedValue, child) {
              return Text(
                '$animatedValue',
                style: AppTypography.number.copyWith(color: textColor),
              );
            },
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.caption.copyWith(color: secondaryColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
