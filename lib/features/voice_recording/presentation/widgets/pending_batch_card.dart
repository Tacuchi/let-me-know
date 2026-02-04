import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../../reminders/domain/entities/reminder_type.dart';
import '../../domain/models/pending_creation.dart';

/// Card compacta para mostrar un batch de recordatorios.
/// 
/// En vez de mostrar N cards individuales, muestra un resumen:
/// "💊 58 recordatorios de Losartán cada 12h por 30 días"
class PendingBatchCard extends StatelessWidget {
  final List<PendingCreation> items;
  final String groupLabel;
  final VoidCallback? onRemove;

  const PendingBatchCard({
    super.key,
    required this.items,
    required this.groupLabel,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final firstItem = items.first;
    final typeColor = firstItem.reminderType.color;
    final typeIcon = firstItem.reminderType.icon;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final secondaryColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final bgColor = isDark ? AppColors.bgSecondaryDark : Colors.white;

    // Calcular resumen
    final count = items.length;
    final summary = _buildSummary();
    final dateRange = _buildDateRange();

    return Semantics(
      label: '$count recordatorios pendientes: $summary',
      child: Container(
        margin: const EdgeInsets.only(
          left: AppSpacing.sm,
          right: AppSpacing.sm,
          bottom: AppSpacing.sm,
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Color.lerp(bgColor, typeColor, isDark ? 0.08 : 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: typeColor.withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: typeColor.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: icono + label del grupo + botón eliminar
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(typeIcon, size: 24, color: typeColor),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge de cantidad
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: typeColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$count recordatorios',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: typeColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Label del grupo
                      Text(
                        groupLabel,
                        style: AppTypography.titleSmall.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Botón eliminar
                if (onRemove != null)
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      size: 22,
                      color: AppColors.error.withValues(alpha: 0.8),
                    ),
                    tooltip: 'Eliminar todos',
                    onPressed: onRemove,
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // Resumen del contenido
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.bgTertiaryDark : AppColors.bgTertiary)
                    .withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Descripción del tratamiento
                  Text(
                    summary,
                    style: AppTypography.bodyMedium.copyWith(
                      color: textColor,
                      height: 1.4,
                    ),
                  ),
                  if (dateRange != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Icon(
                          Icons.date_range_rounded,
                          size: 14,
                          color: secondaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          dateRange,
                          style: AppTypography.helper.copyWith(
                            color: secondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _buildSummary() {
    if (items.isEmpty) return '';

    final firstItem = items.first;
    final title = firstItem.title;

    // Intentar detectar frecuencia
    if (items.length >= 2) {
      final first = items[0].scheduledAt;
      final second = items[1].scheduledAt;

      if (first != null && second != null) {
        final diff = second.difference(first);
        String frequency;

        if (diff.inHours == 24) {
          frequency = 'cada día';
        } else if (diff.inHours == 12) {
          frequency = 'cada 12 horas';
        } else if (diff.inHours == 8) {
          frequency = 'cada 8 horas';
        } else if (diff.inHours == 6) {
          frequency = 'cada 6 horas';
        } else if (diff.inMinutes < 60) {
          frequency = 'cada ${diff.inMinutes} minutos';
        } else {
          frequency = 'cada ${diff.inHours} horas';
        }

        return '$title $frequency';
      }
    }

    return title;
  }

  String? _buildDateRange() {
    if (items.isEmpty) return null;

    final dates = items
        .where((i) => i.scheduledAt != null)
        .map((i) => i.scheduledAt!)
        .toList();

    if (dates.isEmpty) return null;

    dates.sort();
    final first = dates.first;
    final last = dates.last;

    String formatDate(DateTime d) {
      final months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
                      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
      return '${d.day} ${months[d.month - 1]}';
    }

    if (first.day == last.day && first.month == last.month) {
      final hour1 = '${first.hour}:${first.minute.toString().padLeft(2, '0')}';
      final hour2 = '${last.hour}:${last.minute.toString().padLeft(2, '0')}';
      return '${formatDate(first)}, $hour1 - $hour2';
    }

    return '${formatDate(first)} al ${formatDate(last)}';
  }
}
