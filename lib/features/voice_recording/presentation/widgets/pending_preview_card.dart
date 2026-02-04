import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../domain/models/pending_preview.dart';

/// Card para mostrar un preview de batch pendiente de confirmar.
/// 
/// Muestra el resumen del LLM sin haber creado los items individuales.
/// Al "Finalizar", el cubit enviará [originalRequest] a /process.
class PendingPreviewCard extends StatelessWidget {
  final PendingPreview preview;
  final VoidCallback? onRemove;

  const PendingPreviewCard({
    super.key,
    required this.preview,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final typeColor = AppColors.primary;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final secondaryColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final bgColor = isDark ? AppColors.bgSecondaryDark : Colors.white;

    return Semantics(
      label: '${preview.estimatedCount} recordatorios pendientes: ${preview.summary}',
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
                  child: Icon(Icons.medical_services_rounded, size: 24, color: typeColor),
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
                          '${preview.estimatedCount} recordatorios',
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
                        preview.groupLabel,
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
                    tooltip: 'Eliminar',
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
                  // Resumen
                  Text(
                    preview.summary,
                    style: AppTypography.bodyMedium.copyWith(
                      color: textColor,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  // Frecuencia
                  if (preview.frequency.isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 14,
                          color: secondaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          preview.frequency,
                          style: AppTypography.helper.copyWith(
                            color: secondaryColor,
                          ),
                        ),
                      ],
                    ),
                  if (preview.dateRange.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.date_range_rounded,
                          size: 14,
                          color: secondaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          preview.dateRange,
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
}
