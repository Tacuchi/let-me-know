import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/constants.dart';
import '../../application/cubit/reminder_detail_cubit.dart';
import '../../application/cubit/reminder_detail_state.dart';
import '../../domain/entities/reminder.dart';
import '../../domain/entities/reminder_importance.dart';
import '../../domain/entities/reminder_status.dart';
import '../../domain/entities/reminder_type.dart';

class ReminderDetailPage extends StatefulWidget {
  const ReminderDetailPage({super.key});

  @override
  State<ReminderDetailPage> createState() => _ReminderDetailPageState();
}

class _ReminderDetailPageState extends State<ReminderDetailPage> {
  Timer? _countdownTimer;
  Duration _timeRemaining = Duration.zero;
  bool _isTimeUp = false;

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown(DateTime scheduledAt) {
    _countdownTimer?.cancel();
    _updateTimeRemaining(scheduledAt);
    
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateTimeRemaining(scheduledAt);
    });
  }

  void _updateTimeRemaining(DateTime scheduledAt) {
    final now = DateTime.now();
    final diff = scheduledAt.difference(now);
    
    setState(() {
      if (diff.isNegative) {
        _timeRemaining = Duration.zero;
        _isTimeUp = true;
        _countdownTimer?.cancel();
      } else {
        _timeRemaining = diff;
        _isTimeUp = false;
      }
    });
  }

  String _formatCountdown(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours.remainder(24)}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m ${duration.inSeconds.remainder(60)}s';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}:${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReminderDetailCubit, ReminderDetailState>(
      listener: (context, state) {
        switch (state) {
          case ReminderDetailCompleted():
            _showSnackBar(context, '✓ Recordatorio completado');
            context.pop();
          case ReminderDetailDeleted():
            _showSnackBar(context, 'Recordatorio eliminado');
            context.pop();
          case ReminderDetailSnoozed(:final newTime):
            final timeStr = DateFormat.Hm('es_ES').format(newTime);
            _showSnackBar(context, '⏰ Pospuesto hasta las $timeStr');
            context.pop();
          case ReminderDetailError(:final message):
            _showSnackBar(context, message, isError: true);
          case ReminderDetailLoaded(:final reminder):
            // Iniciar countdown si tiene fecha programada
            if (reminder.scheduledAt != null && 
                reminder.status != ReminderStatus.completed &&
                !reminder.isNote) {
              _startCountdown(reminder.scheduledAt!);
            }
          default:
            break;
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.bgPrimaryAdaptive(Theme.of(context).brightness),
          appBar: _buildAppBar(context, state),
          body: _buildBody(context, state),
        );
      },
    );
  }

  void _showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontSize: 16)),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, ReminderDetailState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_rounded,
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        ),
        onPressed: () => context.pop(),
        tooltip: 'Volver',
      ),
      title: Text(
        'Detalle',
        style: TextStyle(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        if (state is ReminderDetailLoaded)
          IconButton(
            icon: Icon(
              Icons.delete_outline_rounded,
              color: AppColors.error,
            ),
            onPressed: () => _showDeleteConfirmation(context),
            tooltip: 'Eliminar',
          ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, ReminderDetailState state) {
    return switch (state) {
      ReminderDetailLoading() => const Center(
          child: CircularProgressIndicator(),
        ),
      ReminderDetailNotFound() => _buildNotFound(context),
      ReminderDetailLoaded(:final reminder) => _buildContent(context, reminder),
      ReminderDetailError(:final message) => _buildError(context, message),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _buildNotFound(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 80,
            color: AppColors.textHelper,
          ),
          const SizedBox(height: 16),
          Text(
            'Recordatorio no encontrado',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Volver'),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 80,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => context.read<ReminderDetailCubit>().reload(),
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, Reminder reminder) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isNote = reminder.isNote;
    final isCompleted = reminder.status == ReminderStatus.completed;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Icono grande del tipo
          _buildTypeIcon(reminder, isDark),
          const SizedBox(height: 24),

          // Título
          Text(
            reminder.title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Badge de tipo
          _buildTypeBadge(reminder, isDark),
          const SizedBox(height: 32),

          // Información según tipo
          if (isNote)
            _buildNoteInfo(reminder, isDark)
          else
            _buildReminderInfo(reminder, isDark),

          // Descripción
          if (reminder.description.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildDescription(reminder, isDark),
          ],

          const SizedBox(height: 40),

          // Botones de acción
          if (!isCompleted) _buildActionButtons(context, reminder, isDark),
          if (isCompleted) _buildCompletedBanner(isDark),
        ],
      ),
    );
  }

  Widget _buildTypeIcon(Reminder reminder, bool isDark) {
    final typeColor = reminder.type.color;

    return Container(
      width: 100,
      height: 100,
      margin: const EdgeInsets.symmetric(horizontal: 100),
      decoration: BoxDecoration(
        color: typeColor.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          reminder.type.emoji,
          style: const TextStyle(fontSize: 48),
        ),
      ),
    );
  }

  Widget _buildTypeBadge(Reminder reminder, bool isDark) {
    final typeColor = reminder.type.color;

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: typeColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          reminder.type.displayName,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: typeColor,
          ),
        ),
      ),
    );
  }

  Widget _buildReminderInfo(Reminder reminder, bool isDark) {
    final isCompleted = reminder.status == ReminderStatus.completed;
    final showCountdown = reminder.scheduledAt != null && 
        !isCompleted && 
        !reminder.isOverdue;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgSecondaryDark : AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Countdown en tiempo real
          if (showCountdown) ...[
            _buildCountdownSection(reminder, isDark),
            const Divider(height: 24),
          ],

          // Fecha y hora
          if (reminder.scheduledAt != null)
            _buildInfoRow(
              icon: Icons.calendar_today_rounded,
              label: 'Fecha',
              value: _formatDate(reminder.scheduledAt!),
              isDark: isDark,
            ),
          if (reminder.scheduledAt != null) ...[
            const Divider(height: 24),
            _buildInfoRow(
              icon: Icons.access_time_rounded,
              label: 'Hora',
              value: DateFormat.Hm('es_ES').format(reminder.scheduledAt!),
              isDark: isDark,
              valueStyle: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
            ),
          ],
          const Divider(height: 24),

          // Importancia
          _buildInfoRow(
            icon: Icons.flag_rounded,
            label: 'Importancia',
            value: reminder.importance.displayName,
            valueColor: _getImportanceColor(reminder.importance),
            isDark: isDark,
          ),
          const Divider(height: 24),

          // Notificación
          _buildInfoRow(
            icon: reminder.hasNotification
                ? Icons.notifications_active_rounded
                : Icons.notifications_off_rounded,
            label: 'Notificación',
            value: reminder.hasNotification ? 'Activa' : 'Desactivada',
            valueColor: reminder.hasNotification ? AppColors.success : AppColors.textHelper,
            isDark: isDark,
          ),

          // Estado vencido
          if (reminder.isOverdue) ...[
            const Divider(height: 24),
            _buildInfoRow(
              icon: Icons.warning_rounded,
              label: 'Estado',
              value: 'Vencido',
              valueColor: AppColors.error,
              isDark: isDark,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCountdownSection(Reminder reminder, bool isDark) {
    final typeColor = reminder.type.color;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            typeColor.withValues(alpha: 0.15),
            typeColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isTimeUp ? Icons.alarm_on_rounded : Icons.timer_rounded,
                color: _isTimeUp ? AppColors.warning : typeColor,
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(
                _isTimeUp ? '¡Ahora!' : 'Faltan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              _isTimeUp ? '⏰' : _formatCountdown(_timeRemaining),
              key: ValueKey(_isTimeUp ? 'timeup' : _timeRemaining.inSeconds),
              style: TextStyle(
                fontSize: _isTimeUp ? 48 : 36,
                fontWeight: FontWeight.bold,
                color: _isTimeUp ? AppColors.warning : typeColor,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          if (!_isTimeUp && _timeRemaining.inMinutes < 5) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '¡Casi es hora!',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.warning,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNoteInfo(Reminder reminder, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgSecondaryDark : AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Objeto
          if (reminder.object != null && reminder.object!.isNotEmpty)
            _buildInfoRow(
              icon: Icons.category_rounded,
              label: 'Objeto',
              value: reminder.object!,
              isDark: isDark,
              valueStyle: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
            ),
          if (reminder.object != null &&
              reminder.object!.isNotEmpty &&
              reminder.location != null &&
              reminder.location!.isNotEmpty)
            const Divider(height: 24),

          // Ubicación
          if (reminder.location != null && reminder.location!.isNotEmpty)
            _buildInfoRow(
              icon: Icons.place_rounded,
              label: 'Ubicación',
              value: reminder.location!,
              isDark: isDark,
              valueStyle: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.reminderLocation,
              ),
            ),

          const Divider(height: 24),

          // Fecha de creación
          _buildInfoRow(
            icon: Icons.access_time_rounded,
            label: 'Guardado',
            value: _formatDate(reminder.createdAt),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
    Color? valueColor,
    TextStyle? valueStyle,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 24,
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: valueStyle ??
              TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: valueColor ??
                    (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
              ),
        ),
      ],
    );
  }

  Widget _buildDescription(Reminder reminder, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.bgTertiaryDark : AppColors.bgTertiary)
            .withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Descripción',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            reminder.description,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Reminder reminder, bool isDark) {
    final isNote = reminder.isNote;
    final cubit = context.read<ReminderDetailCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Botón principal: Completar (para recordatorios) o Eliminar (para notas)
        if (!isNote)
          SizedBox(
            height: 56,
            child: FilledButton.icon(
              onPressed: () {
                HapticFeedback.mediumImpact();
                cubit.markAsCompleted();
              },
              icon: const Icon(Icons.check_rounded, size: 24),
              label: const Text(
                '✓ Marcar como completado',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),

        // Botón de posponer (solo para recordatorios)
        if (!isNote && reminder.scheduledAt != null) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 56,
            child: OutlinedButton.icon(
              onPressed: () => _showSnoozeOptions(context),
              icon: const Icon(Icons.snooze_rounded, size: 24),
              label: const Text(
                '⏰ Posponer',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.warning,
                side: BorderSide(color: AppColors.warning, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],

        // Botón de eliminar
        const SizedBox(height: 12),
        SizedBox(
          height: 56,
          child: OutlinedButton.icon(
            onPressed: () => _showDeleteConfirmation(context),
            icon: const Icon(Icons.delete_outline_rounded, size: 24),
            label: const Text(
              '🗑️ Eliminar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: BorderSide(color: AppColors.error, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletedBanner(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.completed.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.success, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_rounded, color: AppColors.success, size: 32),
          const SizedBox(width: 12),
          Text(
            'Completado',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }

  void _showSnoozeOptions(BuildContext context) {
    final cubit = context.read<ReminderDetailCubit>();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '⏰ Posponer recordatorio',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _buildSnoozeOption(
                context: ctx,
                label: '5 minutos',
                duration: const Duration(minutes: 5),
                cubit: cubit,
              ),
              const SizedBox(height: 12),
              _buildSnoozeOption(
                context: ctx,
                label: '15 minutos',
                duration: const Duration(minutes: 15),
                cubit: cubit,
              ),
              const SizedBox(height: 12),
              _buildSnoozeOption(
                context: ctx,
                label: '1 hora',
                duration: const Duration(hours: 1),
                cubit: cubit,
              ),
              const SizedBox(height: 12),
              _buildSnoozeOption(
                context: ctx,
                label: 'Mañana a esta hora',
                duration: const Duration(days: 1),
                cubit: cubit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSnoozeOption({
    required BuildContext context,
    required String label,
    required Duration duration,
    required ReminderDetailCubit cubit,
  }) {
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: () {
          Navigator.pop(context);
          HapticFeedback.mediumImpact();
          cubit.snooze(duration);
        },
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    final cubit = context.read<ReminderDetailCubit>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar recordatorio?'),
        content: const Text(
          'Esta acción no se puede deshacer.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              HapticFeedback.mediumImpact();
              cubit.delete();
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Color _getImportanceColor(ReminderImportance importance) {
    return switch (importance) {
      ReminderImportance.high => AppColors.error,
      ReminderImportance.medium => AppColors.warning,
      ReminderImportance.low => AppColors.success,
      ReminderImportance.info => AppColors.textHelper,
    };
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Hoy';
    } else if (dateOnly == tomorrow) {
      return 'Mañana';
    } else {
      return DateFormat('EEEE d MMM', 'es_ES').format(date);
    }
  }
}
