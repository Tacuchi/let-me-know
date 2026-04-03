import 'package:flutter/material.dart';

/// Icono dentro de una caja coloreada con fondo semitransparente.
///
/// Es el patrón más repetido del app — aparece en settings, drawer,
/// cards, bottom sheets, y secciones. Centraliza el estilo:
/// padding + borderRadius + color.withAlpha(0.12) + Icon.
///
/// Ejemplos de uso:
/// ```dart
/// LmkIconBox(icon: Icons.palette_outlined, color: AppColors.accentPrimary)
/// LmkIconBox(icon: Icons.alarm_on_rounded, color: AppColors.error, circle: true)
/// LmkIconBox(icon: Icons.medication_rounded, color: AppColors.reminderMedication, size: 28, padding: 12)
/// ```
class LmkIconBox extends StatelessWidget {
  final IconData icon;
  final Color color;

  /// Tamaño del icono (default 22).
  final double size;

  /// Padding interno (default 8).
  final double padding;

  /// Radio de las esquinas. Si [circle] es true, se ignora.
  final double radius;

  /// Usar forma circular en lugar de rectángulo redondeado.
  final bool circle;

  /// Opacidad del fondo (default 0.12).
  final double backgroundOpacity;

  const LmkIconBox({
    super.key,
    required this.icon,
    required this.color,
    this.size = 22,
    this.padding = 8,
    this.radius = 8,
    this.circle = false,
    this.backgroundOpacity = 0.12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: color.withValues(alpha: backgroundOpacity),
        borderRadius: circle ? null : BorderRadius.circular(radius),
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
      ),
      child: Icon(icon, size: size, color: color),
    );
  }
}
