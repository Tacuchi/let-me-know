import 'package:flutter/material.dart';

import '../constants/constants.dart';

/// Fila pequeña con icono + texto para metadatos (fecha, ubicación, duración…).
///
/// Patrón muy repetido en ReminderCard, PendingCreationCard y ReminderDetailPage.
///
/// Ejemplos:
/// ```dart
/// LmkMetaRow(icon: Icons.schedule_rounded, text: 'Hoy, 8:00 AM')
/// LmkMetaRow(icon: Icons.place_rounded, text: 'Farmacia Central', iconColor: AppColors.reminderLocation)
/// LmkMetaRow(icon: Icons.repeat_rounded, text: 'Cada 12 horas', compact: true)
/// ```
class LmkMetaRow extends StatelessWidget {
  final IconData icon;
  final String text;

  /// Color del icono. Si es null usa [AppColors.textHelper] adaptativo.
  final Color? iconColor;

  /// Color del texto. Si es null usa [AppColors.textSecondary] adaptativo.
  final Color? textColor;

  /// Modo compacto: icono 13px (para uso inline dentro de cards).
  final bool compact;

  /// Si el texto puede expandirse (wrap) dentro de un Row expandido.
  final bool expanded;

  const LmkMetaRow({
    super.key,
    required this.icon,
    required this.text,
    this.iconColor,
    this.textColor,
    this.compact = false,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveIconColor =
        iconColor ?? (isDark ? AppColors.textHelperDark : AppColors.textHelper);
    final effectiveTextColor =
        textColor ??
        (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary);
    final iconSize = compact ? 13.0 : 16.0;
    final gap = compact ? 3.0 : AppSpacing.xs;

    final textWidget = Text(
      text,
      style: AppTypography.bodySmall.copyWith(color: effectiveTextColor),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    return Row(
      mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
      children: [
        Icon(icon, size: iconSize, color: effectiveIconColor),
        SizedBox(width: gap),
        expanded ? Expanded(child: textWidget) : Flexible(child: textWidget),
      ],
    );
  }
}
