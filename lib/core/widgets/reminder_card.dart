import 'dart:async';

import 'package:flutter/material.dart';

import '../constants/constants.dart';
import '../../features/reminders/domain/entities/reminder.dart';
import '../../features/reminders/domain/entities/reminder_type.dart';
import '../../features/reminders/domain/entities/reminder_status.dart';

import '../../di/injection_container.dart';
import '../../core/services/feedback_service.dart';

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

  void _showContextMenu() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.bgSecondaryDark : AppColors.bgSecondary;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final isCompleted = widget.reminder.status == ReminderStatus.completed;

    _feedbackService.medium();

    showModalBottomSheet(
      context: context,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.dividerDark : AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                // Título del recordatorio
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: _typeColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                        ),
                        child: Icon(_typeIcon, size: 20, color: _typeColor),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          widget.reminder.title,
                          style: AppTypography.bodyLarge.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Divider(
                  color: isDark ? AppColors.dividerDark : AppColors.divider,
                  height: 1,
                ),
                // Opciones
                if (!_isNote && widget.onComplete != null && !isCompleted)
                  _buildMenuOption(
                    context,
                    icon: Icons.check_circle_outline_rounded,
                    label: 'Marcar como completado',
                    color: AppColors.completed,
                    onTap: () {
                      Navigator.pop(context);
                      _feedbackService.success();
                      widget.onComplete?.call();
                    },
                  ),
                _buildMenuOption(
                  context,
                  icon: Icons.edit_outlined,
                  label: 'Editar',
                  color: isDark ? AppColors.accentPrimaryDark : AppColors.accentPrimary,
                  onTap: () {
                    Navigator.pop(context);
                    _feedbackService.light();
                    widget.onTap?.call();
                  },
                ),
                if (widget.onDelete != null)
                  _buildMenuOption(
                    context,
                    icon: Icons.delete_outline_rounded,
                    label: 'Eliminar',
                    color: AppColors.error,
                    onTap: () {
                      Navigator.pop(context);
                      _feedbackService.medium();
                      widget.onDelete?.call();
                    },
                  ),
                const SizedBox(height: AppSpacing.sm),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(icon, size: 22, color: color),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.bodyLarge.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: isDark ? AppColors.textHelperDark : AppColors.textHelper,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCompleted = widget.reminder.status == ReminderStatus.completed;
    // Notas nunca están "vencidas" (no tienen fecha)
    final isOverdue =
        !_isNote && widget.reminder.status == ReminderStatus.overdue;

    final hasActions = widget.onComplete != null || widget.onDelete != null;

    final Widget card = ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) => _controller.reverse(),
        onTapCancel: () => _controller.reverse(),
        onTap: () {
          _feedbackService.light();
          widget.onTap?.call();
        },
        onLongPress: hasActions ? _showContextMenu : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: _getBackgroundColor(isDark, isCompleted, isOverdue),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isOverdue
                  ? AppColors.overdue
                  : _typeColor.withValues(alpha: isCompleted ? 0.3 : 0.5),
              width: isOverdue ? 2 : 1.5,
            ),
            boxShadow: isCompleted
                ? null
                : [
                    BoxShadow(
                      color: _typeColor.withValues(alpha: isDark ? 0.15 : 0.08),
                      blurRadius: 8,
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
                          decoration:
                              isCompleted ? TextDecoration.lineThrough : null,
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
                    // Indicador de que se puede mantener presionado
                    if (hasActions && !isCompleted) ...[
                      const SizedBox(width: AppSpacing.xs),
                      Icon(
                        Icons.more_vert_rounded,
                        size: 18,
                        color: isDark
                            ? AppColors.textHelperDark
                            : AppColors.textHelper,
                      ),
                    ],
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

    return Semantics(
      button: true,
      label: '${widget.reminder.type.label}: ${widget.reminder.title}. '
          '${widget.reminder.scheduledAt == null ? 'Sin fecha' : _formatDateTime(widget.reminder.scheduledAt!)}. '
          '${isCompleted ? 'Completado' : isOverdue ? 'Vencido' : 'Pendiente'}. '
          '${hasActions ? 'Mantén presionado para ver opciones.' : ''}',
      child: card,
    );
  }

  Color _getBackgroundColor(bool isDark, bool isCompleted, bool isOverdue) {
    if (isCompleted) {
      return (isDark ? AppColors.bgSecondaryDark : AppColors.bgSecondary)
          .withValues(alpha: 0.6);
    }
    if (isOverdue) {
      return AppColors.overdue.withValues(alpha: isDark ? 0.12 : 0.08);
    }
    // Fondo con tinte suave del color del tipo
    final baseColor = isDark ? AppColors.bgSecondaryDark : Colors.white;
    return Color.lerp(baseColor, _typeColor, isDark ? 0.08 : 0.05)!;
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
                backgroundColor:
                    isDark ? AppColors.dividerDark : AppColors.divider,
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
