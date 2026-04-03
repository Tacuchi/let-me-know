import 'package:flutter/material.dart';

import '../constants/constants.dart';

/// Chip/badge con icono opcional y texto coloreado.
///
/// Usado para indicar tipo de recordatorio (Medicamento, Cita…),
/// estado (Vencido, Completado…) o cualquier etiqueta categórica.
///
/// Ejemplos:
/// ```dart
/// LmkTypeBadge(label: 'Medicamento', color: AppColors.reminderMedication, icon: Icons.medication_rounded)
/// LmkTypeBadge(label: 'Vencido', color: AppColors.error)
/// LmkTypeBadge(label: 'GRUPO', color: AppColors.accentPrimary, compact: true)
/// ```
class LmkTypeBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  /// Modo compacto: padding y fuente más pequeños, texto uppercase (para badges inline).
  final bool compact;

  const LmkTypeBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final hPad = compact ? 6.0 : AppSpacing.sm + 4;
    final vPad = compact ? 2.0 : AppSpacing.xs + 2;
    final iconSize = compact ? 13.0 : 18.0;
    final iconGap = compact ? 3.0 : 6.0;

    // Pill shape para ambos modos (sistema Resonant Horizon)
    const borderRadius = BorderRadius.all(
      Radius.circular(AppSpacing.radiusFull),
    );

    // Tipografía: tokens del sistema en lugar de TextStyle raw
    final textStyle = compact
        ? AppTypography.badgeText.copyWith(color: color)
        : AppTypography.chipLabel.copyWith(color: color);

    // El label en modo compact va siempre uppercase (mandato del sistema)
    final displayLabel = compact ? label.toUpperCase() : label;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      decoration: BoxDecoration(
        // Alpha 0.10 — estándar del sistema (igual que LmkInfoBadge)
        color: color.withValues(alpha: 0.10),
        borderRadius: borderRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: iconSize),
            SizedBox(width: iconGap),
          ],
          Text(displayLabel, style: textStyle),
        ],
      ),
    );
  }
}
