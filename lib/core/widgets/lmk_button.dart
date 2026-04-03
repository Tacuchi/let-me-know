import 'package:flutter/material.dart';
import '../constants/constants.dart';

/// Botón primario con gradiente (#504DCD → #7D7CFE), pill shape
class LmkPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final double? width;

  const LmkPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width,
        height: 44,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentPrimary.withValues(alpha: 0.2),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label.toUpperCase(),
          style: AppTypography.buttonSmall.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}

/// Botón secundario — fondo gris claro, texto oscuro, icono opcional
class LmkSecondaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;

  const LmkSecondaryButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = AppColors.buttonSecondaryBgAdaptive(
      Theme.of(context).brightness,
    );
    final textColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimary;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: textColor),
              const SizedBox(width: AppSpacing.sm),
            ],
            Text(
              label,
              style: AppTypography.chipLabel.copyWith(color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}

/// Botón texto con icono — estilo "Nuevo Chat", opacidad reducida
class LmkTextIconButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final double opacity;

  const LmkTextIconButton({
    super.key,
    required this.label,
    required this.icon,
    this.onPressed,
    this.opacity = 0.6,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.textSecondaryAdaptive(Theme.of(context).brightness);
    return Opacity(
      opacity: opacity,
      child: GestureDetector(
        onTap: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: AppSpacing.sm),
            Text(
              label.toUpperCase(),
              style: AppTypography.buttonSmall.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

/// FAB cuadrado redondeado — fondo oscuro, icono blanco (estilo "+" de la lista)
class LmkFab extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;

  const LmkFab({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? AppColors.bgPrimaryDark;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: AppSpacing.fabSizeSm,
        height: AppSpacing.fabSizeSm,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 25,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
