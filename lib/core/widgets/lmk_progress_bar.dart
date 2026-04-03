import 'package:flutter/material.dart';

import '../constants/constants.dart';

/// Barra de progreso animada con gradiente primario.
///
/// [progress] va de 0.0 a 1.0. Usa el gradiente púrpura por defecto.
class LmkProgressBar extends StatelessWidget {
  final double progress;
  final double height;
  final Duration duration;
  final bool useGradient;
  final Color? color;
  final Color? backgroundColor;

  const LmkProgressBar({
    super.key,
    required this.progress,
    this.height = 6,
    this.duration = const Duration(milliseconds: 400),
    this.useGradient = true,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveBgColor =
        backgroundColor ?? (isDark ? AppColors.dividerDark : AppColors.divider);
    final effectiveRadius = BorderRadius.circular(height / 2);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: effectiveBgColor,
        borderRadius: effectiveRadius,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Align(
            alignment: Alignment.centerLeft,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
              duration: duration,
              curve: Curves.easeOutCubic,
              builder: (context, animatedProgress, child) {
                return Container(
                  width: constraints.maxWidth * animatedProgress,
                  decoration: BoxDecoration(
                    gradient: useGradient ? AppColors.primaryGradient : null,
                    color: useGradient
                        ? null
                        : (color ??
                              (isDark
                                  ? AppColors.accentPrimaryDark
                                  : AppColors.accentPrimary)),
                    borderRadius: effectiveRadius,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
