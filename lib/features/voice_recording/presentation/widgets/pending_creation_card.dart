import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../../reminders/domain/entities/reminder_type.dart';
import '../../domain/models/pending_creation.dart';

/// Card de vista previa para un item pendiente de crear.
///
/// Muestra el tipo, titulo, fecha/hora y un boton para eliminar.
/// Reutiliza los patrones visuales de ReminderCard.
class PendingCreationCard extends StatelessWidget {
  final PendingCreation item;
  final VoidCallback? onRemove;

  const PendingCreationCard({
    super.key,
    required this.item,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final typeColor = item.reminderType.color;
    final typeIcon = item.reminderType.icon;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final bgColor = isDark ? AppColors.bgSecondaryDark : Colors.white;

    return Semantics(
      label:
          '${item.reminderType.label} pendiente: ${item.title}. ${item.scheduledAt != null ? _formatDateTime(item.scheduledAt!) : "Sin fecha"}',
      child: Container(
        margin: const EdgeInsets.only(
          left: AppSpacing.sm,
          right: AppSpacing.sm,
          bottom: AppSpacing.sm,
        ),
        padding: const EdgeInsets.all(AppSpacing.sm + 2),
        decoration: BoxDecoration(
          color: Color.lerp(bgColor, typeColor, isDark ? 0.06 : 0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: typeColor.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Icono de tipo
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(typeIcon, size: 18, color: typeColor),
            ),
            const SizedBox(width: AppSpacing.sm),
            // Titulo y detalle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: AppTypography.bodyMedium.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      if (item.isNote && item.location != null) ...[
                        Icon(Icons.place_rounded, size: 13, color: typeColor),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            item.location!,
                            style: AppTypography.helper.copyWith(
                              color: secondaryColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ] else if (item.scheduledAt != null) ...[
                        Icon(Icons.schedule_rounded,
                            size: 13, color: secondaryColor),
                        const SizedBox(width: 3),
                        Text(
                          _formatDateTime(item.scheduledAt!),
                          style: AppTypography.helper.copyWith(
                            color: secondaryColor,
                          ),
                        ),
                      ] else ...[
                        Text(
                          item.reminderType.displayName,
                          style: AppTypography.helper.copyWith(
                            color: typeColor,
                          ),
                        ),
                      ],
                      if (item.hasBatchGroup) ...[
                        const SizedBox(width: AppSpacing.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: typeColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Grupo',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: typeColor,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Boton eliminar
            if (onRemove != null)
              SizedBox(
                width: 32,
                height: 32,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: secondaryColor,
                  ),
                  tooltip: 'Quitar',
                  onPressed: onRemove,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);

    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final time = '$displayHour:$minute $period';

    if (date == today) {
      return 'Hoy, $time';
    } else if (date == tomorrow) {
      return 'Manana, $time';
    } else {
      final months = [
        'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
        'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
      ];
      return '${dateTime.day} ${months[dateTime.month - 1]}, $time';
    }
  }
}
