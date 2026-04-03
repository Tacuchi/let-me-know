import 'package:flutter/material.dart';
import '../constants/constants.dart';

/// Badge informativo pill — fondo azul 10%, texto azul
/// Ej: "PENDIENTE", "2 ACTIVOS"
class LmkInfoBadge extends StatelessWidget {
  final String label;
  final Color? color; // color del texto y del fondo (10% alpha)

  const LmkInfoBadge({super.key, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final textColor = color ?? AppColors.infoBadgeText;
    final bgColor = color?.withValues(alpha: 0.1) ?? AppColors.infoBadgeBg;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 4,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTypography.badgeText.copyWith(color: textColor),
      ),
    );
  }
}

/// Dot de estado — círculo de color (12px) para indicar prioridad/tipo
class LmkStatusDot extends StatelessWidget {
  final Color color;
  final double size;

  const LmkStatusDot({super.key, required this.color, this.size = 12});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
