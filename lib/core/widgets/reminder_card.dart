import 'dart:async';

import 'package:flutter/material.dart';


import '../constants/constants.dart';
import '../../features/reminders/domain/entities/reminder.dart';
import '../../features/reminders/domain/entities/reminder_type.dart';
import '../../features/reminders/domain/entities/reminder_status.dart';

import '../../../../di/injection_container.dart';
import '../../../../core/services/feedback_service.dart';

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
  Timer? _progressTimer;
  late final FeedbackService _feedbackService;

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
    
    _feedbackService = getIt<FeedbackService>();
    
    // Iniciar timer si tiene fecha programada y muestra progreso
    _startProgressTimer();
  }

  @override
  void didUpdateWidget(ReminderCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reminder.scheduledAt != widget.reminder.scheduledAt) {
      _startProgressTimer();
    }
  }

  void _startProgressTimer() {
    _progressTimer?.cancel();
    
    final shouldShowProgress = widget.showProgress &&
        !_isNote &&
        widget.reminder.scheduledAt != null &&
        widget.reminder.status != ReminderStatus.completed &&
        widget.reminder.status != ReminderStatus.overdue;
    
    if (shouldShowProgress) {
      // Actualizar cada 10 segundos para mostrar progreso más fluido
      _progressTimer = Timer.periodic(const Duration(seconds: 10), (_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _progressTimer?.cancel();
    super.dispose();
  }

  // Usar propiedades centralizadas de ReminderType
  Color get _typeColor => widget.reminder.type.color;
  IconData get _typeIcon => widget.reminder.type.icon;
  bool get _isNote => widget.reminder.type.isNote;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCompleted = widget.reminder.status == ReminderStatus.completed;
    // Notas nunca están "vencidas" (no tienen fecha)
    final isOverdue = !_isNote && widget.reminder.status == ReminderStatus.overdue;

    Widget card = ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) => _controller.reverse(),
        onTapCancel: () => _controller.reverse(),
        onTap: () {
          _feedbackService.light();
          widget.onTap?.call();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
            color: _getBackgroundColor(isDark, isCompleted, isOverdue),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: isOverdue 
              ? Border.all(color: AppColors.overdue, width: 2)
              : Border(left: BorderSide(color: _typeColor, width: 6)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08), // Sombra más marcada
                blurRadius: 12,
                offset: const Offset(0, 4),
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
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: _typeColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusSm,
                        ),
                      ),
                      child: Icon(_typeIcon, size: 22, color: _typeColor),
                    ),
                    const SizedBox(width: AppSpacing.sm),
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
                              : (isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimary),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
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
                    if (_isNote && !isCompleted)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: _typeColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusSm,
                          ),
                        ),
                        child: Text(
                          widget.reminder.type.displayName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _typeColor,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                // Mostrar ubicación para notas, fecha para recordatorios
                if (_isNote && widget.reminder.location != null)
                  Row(
                    children: [
                      Icon(
                        Icons.place_rounded,
                        size: 16,
                        color: _typeColor,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          widget.reminder.location!,
                          style: AppTypography.bodySmall.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
                else if (!_isNote && widget.reminder.scheduledAt != null)
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
                if (widget.showProgress &&
                    !_isNote && // No mostrar progreso para notas
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

    if (widget.onComplete != null || widget.onDelete != null) {
      // Notas solo permiten eliminar, no completar
      final allowComplete = !_isNote && widget.onComplete != null;
      final allowDelete = widget.onDelete != null;

      // Determinar dirección del swipe
      final DismissDirection direction;
      if (allowComplete && allowDelete) {
        direction = DismissDirection.horizontal;
      } else if (allowDelete) {
        direction = DismissDirection.endToStart;
      } else if (allowComplete) {
        direction = DismissDirection.startToEnd;
      } else {
        direction = DismissDirection.none;
      }

      // Solo envolver en Dismissible si hay alguna dirección permitida
      if (direction != DismissDirection.none) {
        card = Dismissible(
          key: Key(widget.reminder.id),
          direction: direction,
          confirmDismiss: (dir) async {
            if (dir == DismissDirection.endToStart && allowDelete) {
              await _feedbackService.medium();
              widget.onDelete?.call();
              return true;
            } else if (dir == DismissDirection.startToEnd && allowComplete) {
              await _feedbackService.success();
              widget.onComplete?.call();
              return false;
            }
            return false;
          },
          // Para endToStart solo necesitamos background (no secondaryBackground)
          background: _buildSwipeBackground(
            context,
            alignment: direction == DismissDirection.endToStart
                ? Alignment.centerRight
                : Alignment.centerLeft,
            color: direction == DismissDirection.endToStart
                ? AppColors.error
                : AppColors.accentSecondary,
            icon: direction == DismissDirection.endToStart
                ? Icons.delete_rounded
                : Icons.check_rounded,
            label: direction == DismissDirection.endToStart
                ? 'Eliminar'
                : 'Completar',
          ),
          secondaryBackground: direction == DismissDirection.horizontal
              ? _buildSwipeBackground(
                  context,
                  alignment: Alignment.centerRight,
                  color: AppColors.error,
                  icon: Icons.delete_rounded,
                  label: 'Eliminar',
                )
              : null,
          child: card,
        );
      }
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
          .withValues(alpha: 0.5);
    }
    if (isOverdue) {
      return AppColors.overdue.withValues(alpha: isDark ? 0.15 : 0.1);
    }
    // Fondo de tarjeta con buen contraste
    return isDark ? AppColors.bgSecondaryDark : Colors.white; 
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
                valueColor: AlwaysStoppedAnimation(_typeColor),
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
            color: _typeColor,
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
    final second = dateTime.second.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    // Mostrar segundos solo si no son cero
    final time = dateTime.second == 0
        ? '$displayHour:$minute $period'
        : '$displayHour:$minute:$second $period';

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
