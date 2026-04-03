import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/constants.dart';

/// Card glassmorphic — backdrop blur 10px, fondo blanco 80%, borde sutil
/// Para listas de recordatorios con barra de color lateral opcional
class LmkGlassCard extends StatelessWidget {
  final Widget child;
  final Color? accentColor; // barra lateral izquierda
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  const LmkGlassCard({
    super.key,
    required this.child,
    this.accentColor,
    this.onTap,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? AppColors.bgSecondaryDark.withValues(alpha: 0.8)
        : Colors.white.withValues(alpha: 0.8);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.white.withValues(alpha: 0.2);

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: padding ?? const EdgeInsets.all(AppSpacing.cardPadding),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: accentColor != null
                ? Row(
                    children: [
                      Container(
                        width: 6,
                        height: 48,
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusFull,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(child: child),
                    ],
                  )
                : child,
          ),
        ),
      ),
    );
  }
}

/// Card bento — formato grande (160h), radius 24, icono + contenido
/// Para recordatorios tipo "mandados/compras"
class LmkBentoCard extends StatelessWidget {
  final Widget icon;
  final String title;
  final String? subtitle;
  final Color? statusDotColor;
  final VoidCallback? onTap;

  const LmkBentoCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.statusDotColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? AppColors.bgSecondaryDark.withValues(alpha: 0.8)
        : Colors.white.withValues(alpha: 0.8);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.white.withValues(alpha: 0.2);

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 160,
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    icon,
                    if (statusDotColor != null)
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: statusDotColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: AppTypography.caption.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
