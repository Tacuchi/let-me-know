import 'dart:ui';

import 'package:flutter/material.dart';

import '../constants/constants.dart';

/// Contador animado con tratamiento glassmorphic — Resonant Horizon.
///
/// Muestra un valor numérico con animación y una etiqueta uppercase debajo.
/// El [color] se usa para la barra de acento superior (preserva el significado
/// cromático del dato sin degradar al fondo plano).
class LmkAnimatedCounter extends StatelessWidget {
  final int value;
  final String label;

  /// Color de acento (barra superior). Default: accentPrimary adaptativo.
  final Color? color;

  /// Override del fondo. Si es null usa el tratamiento glassmorphic por defecto.
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

    // Fondo glassmorphic: bgSecondary 80% (igual que LmkGlassCard)
    final glassBg =
        backgroundColor ??
        (isDark
            ? AppColors.bgSecondaryDark.withValues(alpha: 0.80)
            : AppColors.bgSecondary.withValues(alpha: 0.80));

    // Ghost border: white @ 20% light / 8% dark
    final ghostBorder = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.white.withValues(alpha: 0.20);

    final textColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimary;
    final secondaryColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: glassBg,
            borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
            border: Border.all(color: ghostBorder),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Accent bar superior con el color del dato
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: effectiveColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppSpacing.radiusCard),
                    topRight: Radius.circular(AppSpacing.radiusCard),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.md,
                  horizontal: AppSpacing.sm,
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
                          style: AppTypography.number.copyWith(
                            color: textColor,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      label.toUpperCase(),
                      style: AppTypography.sectionHeader.copyWith(
                        color: secondaryColor,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
