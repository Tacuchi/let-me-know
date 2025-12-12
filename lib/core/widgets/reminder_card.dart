import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/constants.dart';
import '../../features/reminders/domain/entities/reminder.dart';
import '../../features/reminders/domain/entities/reminder_type.dart';
import '../../features/reminders/domain/entities/reminder_status.dart';

/// Tarjeta de recordatorio con diseño moderno y gestos
/// Soporta swipe para completar/eliminar
class ReminderCard extends StatefulWidget {
  final Reminder reminder;
  final VoidCallback? onTap;
  final VoidCallback? onComplete;
  final VoidCallback? onDelete;
  final bool showProgress;

  const ReminderCard({
    super.key,
    required this.reminder,
    this.onTap,
    this.onComplete,
    this.onDelete,
    this.showProgress = true,
  });

  @override
  State<ReminderCard> createState() => _ReminderCardState();
}

class _ReminderCardState extends State<ReminderCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _borderColor {
    switch (widget.reminder.type) {
      case ReminderType.medication:
        return AppColors.reminderMedication;
      case ReminderType.appointment:
        return AppColors.reminderAppointment;
      case ReminderType.call:
        return AppColors.reminderCall;
      case ReminderType.shopping:
        return AppColors.reminderShopping;
      case ReminderType.task:
        return AppColors.reminderTask;
      case ReminderType.event:
        return AppColors.reminderEvent;
      case ReminderType.location:
        return AppColors.reminderEvent; // fallback (se puede refinar luego)
    }
  }

  IconData get _typeIcon {
    switch (widget.reminder.type) {
      case ReminderType.medication:
        return Icons.medication_rounded;
      case ReminderType.appointment:
        return Icons.local_hospital_rounded;
      case ReminderType.call:
        return Icons.phone_rounded;
      case ReminderType.shopping:
        return Icons.shopping_cart_rounded;
      case ReminderType.task:
        return Icons.task_alt_rounded;
      case ReminderType.event:
        return Icons.event_rounded;
      case ReminderType.location:
        return Icons.place_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCompleted = widget.reminder.status == ReminderStatus.completed;
    final isOverdue = widget.reminder.status == ReminderStatus.overdue;

    Widget card = ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) => _controller.reverse(),
        onTapCancel: () => _controller.reverse(),
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onTap?.call();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: _getBackgroundColor(isDark, isCompleted, isOverdue),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border(left: BorderSide(color: _borderColor, width: 4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Icono del tipo
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: _borderColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusSm,
                        ),
                      ),
                      child: Icon(_typeIcon, size: 22, color: _borderColor),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    // Título
                    Expanded(
                      child: Text(
                        widget.reminder.title,
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: isCompleted
                              ? (isDark
                                    ? AppColors.textHelperDark
                                    : AppColors.textHelper)
                              : null,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Indicador de estado
                    if (isOverdue)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusSm,
                          ),
                        ),
                        child: const Text(
                          'Vencido',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    if (isCompleted)
                      Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.completed,
                        size: 24,
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                // Fecha y hora (si aplica)
                if (widget.reminder.scheduledAt != null)
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 16,
                        color: isDark
                            ? AppColors.textHelperDark
                            : AppColors.textHelper,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        _formatDateTime(widget.reminder.scheduledAt!),
                        style: AppTypography.bodySmall.copyWith(
                          color: isOverdue
                              ? AppColors.error
                              : (isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                // Barra de progreso (si aplica)
                if (widget.showProgress &&
                    widget.reminder.scheduledAt != null &&
                    !isCompleted &&
                    !isOverdue) ...[
                  const SizedBox(height: AppSpacing.sm),
                  _buildProgressIndicator(isDark),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    // Envolver en Dismissible para gestos swipe
    if (widget.onComplete != null || widget.onDelete != null) {
      card = Dismissible(
        key: Key(widget.reminder.id),
        direction: DismissDirection.horizontal,
        confirmDismiss: (direction) async {
          HapticFeedback.mediumImpact();
          if (direction == DismissDirection.endToStart) {
            // Eliminar
            widget.onDelete?.call();
            return widget.onDelete != null;
          } else if (direction == DismissDirection.startToEnd) {
            // Completar
            widget.onComplete?.call();
            return false; // No eliminar, solo marcar completado
          }
          return false;
        },
        background: _buildSwipeBackground(
          context,
          alignment: Alignment.centerLeft,
          color: AppColors.accentSecondary,
          icon: Icons.check_rounded,
          label: 'Completar',
        ),
        secondaryBackground: _buildSwipeBackground(
          context,
          alignment: Alignment.centerRight,
          color: AppColors.error,
          icon: Icons.delete_rounded,
          label: 'Eliminar',
        ),
        child: card,
      );
    }

    return Semantics(
      button: true,
      label:
          '${widget.reminder.type.label}: ${widget.reminder.title}. '
          '${widget.reminder.scheduledAt == null ? 'Sin fecha' : _formatDateTime(widget.reminder.scheduledAt!)}. '
          '${isCompleted
              ? 'Completado'
              : isOverdue
              ? 'Vencido'
              : 'Pendiente'}',
      child: card,
    );
  }

  Color _getBackgroundColor(bool isDark, bool isCompleted, bool isOverdue) {
    if (isCompleted) {
      return (isDark ? AppColors.bgSecondaryDark : AppColors.bgSecondary)
          .withValues(alpha: 0.7);
    }
    if (isOverdue) {
      return AppColors.overdue.withValues(alpha: isDark ? 0.2 : 0.3);
    }
    return isDark ? AppColors.bgSecondaryDark : AppColors.bgSecondary;
  }

  Widget _buildSwipeBackground(
    BuildContext context, {
    required AlignmentGeometry alignment,
    required Color color,
    required IconData icon,
    required String label,
  }) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: alignment == Alignment.centerLeft
            ? [
                Icon(icon, color: Colors.white, size: 28),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ]
            : [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Icon(icon, color: Colors.white, size: 28),
              ],
      ),
    );
  }

  Widget _buildProgressIndicator(bool isDark) {
    final now = DateTime.now();
    final scheduled = widget.reminder.scheduledAt!;
    final difference = scheduled.difference(now);

    String timeText;
    double progress;

    if (difference.isNegative) {
      timeText = 'Ahora';
      progress = 1.0;
    } else if (difference.inMinutes < 60) {
      timeText = 'En ${difference.inMinutes} min';
      progress = 1.0 - (difference.inMinutes / 60);
    } else if (difference.inHours < 24) {
      timeText = 'En ${difference.inHours}h ${difference.inMinutes % 60}min';
      progress = 1.0 - (difference.inHours / 24);
    } else {
      timeText = 'En ${difference.inDays} días';
      progress = 0.1;
    }

    return Row(
      children: [
        Expanded(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return LinearProgressIndicator(
                value: value,
                backgroundColor: isDark
                    ? AppColors.dividerDark
                    : AppColors.divider,
                valueColor: AlwaysStoppedAnimation(_borderColor),
                borderRadius: BorderRadius.circular(2),
              );
            },
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          timeText,
          style: AppTypography.helper.copyWith(
            fontWeight: FontWeight.w500,
            color: _borderColor,
          ),
        ),
      ],
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
      return 'Mañana, $time';
    } else {
      final months = [
        'Ene',
        'Feb',
        'Mar',
        'Abr',
        'May',
        'Jun',
        'Jul',
        'Ago',
        'Sep',
        'Oct',
        'Nov',
        'Dic',
      ];
      return '${dateTime.day} ${months[dateTime.month - 1]}, $time';
    }
  }
}
