import 'dart:async';

import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/constants.dart';
import '../../../../di/injection_container.dart';
import '../../../../services/alarm/alarm_service.dart';
import '../../../../services/tts/tts_service.dart';
import '../../application/cubit/reminder_detail_cubit.dart';
import '../../application/cubit/reminder_detail_state.dart';
import '../../domain/entities/reminder.dart';
import '../../domain/entities/reminder_importance.dart';
import '../../domain/entities/reminder_status.dart';
import '../../domain/entities/reminder_type.dart';
import '../widgets/alarm_ringing_banner.dart';

class ReminderDetailPage extends StatefulWidget {
  const ReminderDetailPage({super.key});

  @override
  State<ReminderDetailPage> createState() => _ReminderDetailPageState();
}

class _ReminderDetailPageState extends State<ReminderDetailPage> {
  Timer? _countdownTimer;
  Duration _timeRemaining = Duration.zero;
  bool _isTimeUp = false;
  bool _isSpeaking = false;
  bool _isAlarmRinging = false;

  late final TtsService _ttsService;
  late final AlarmService _alarmService;
  StreamSubscription<AlarmSettings>? _alarmSubscription;

  @override
  void initState() {
    super.initState();
    _ttsService = getIt<TtsService>();
    _alarmService = getIt<AlarmService>();
    _setupAlarmListener();
  }

  void _setupAlarmListener() {
    // Escuchar el stream de alarmas sonando
    _alarmSubscription = _alarmService.ringingStream.listen((alarm) {
      _checkAlarmStatus();
    });
    // Verificar estado inicial
    _checkAlarmStatus();
  }

  void _checkAlarmStatus() {
    final state = context.read<ReminderDetailCubit>().state;
    if (state is ReminderDetailLoaded) {
      final isRinging = _alarmService.isRingingForReminder(state.reminder);
      if (isRinging != _isAlarmRinging && mounted) {
        setState(() => _isAlarmRinging = isRinging);
      }
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _alarmSubscription?.cancel();
    _ttsService.stop();
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
      final hours = duration.inHours.remainder(24);
      return '${duration.inDays} día${duration.inDays > 1 ? 's' : ''} y $hours hora${hours != 1 ? 's' : ''}';
    } else if (duration.inHours > 0) {
      final minutes = duration.inMinutes.remainder(60);
      return '${duration.inHours}h ${minutes}min';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} minuto${duration.inMinutes != 1 ? 's' : ''}';
    } else {
      return '${duration.inSeconds} segundo${duration.inSeconds != 1 ? 's' : ''}';
    }
  }

  Future<void> _speakReminder(Reminder reminder) async {
    if (_isSpeaking) {
      await _ttsService.stop();
      setState(() => _isSpeaking = false);
      return;
    }

    setState(() => _isSpeaking = true);

    final buffer = StringBuffer();
    buffer.write(reminder.title);

    if (reminder.description.isNotEmpty) {
      buffer.write('. ${reminder.description}');
    }

    if (reminder.scheduledAt != null) {
      final dateStr = _formatDateForSpeech(reminder.scheduledAt!);
      final timeStr = DateFormat.Hm('es_ES').format(reminder.scheduledAt!);
      buffer.write('. Programado para $dateStr a las $timeStr');
    }

    if (reminder.isNote) {
      if (reminder.object != null && reminder.object!.isNotEmpty) {
        buffer.write('. Objeto: ${reminder.object}');
      }
      if (reminder.location != null && reminder.location!.isNotEmpty) {
        buffer.write('. Ubicación: ${reminder.location}');
      }
    }

    await _ttsService.speak(buffer.toString());

    // Esperar a que termine de hablar
    await Future.delayed(const Duration(milliseconds: 500));
    while (_ttsService.isSpeaking) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    if (mounted) {
      setState(() => _isSpeaking = false);
    }
  }

  String _formatDateForSpeech(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'hoy';
    } else if (dateOnly == tomorrow) {
      return 'mañana';
    } else {
      return DateFormat('EEEE d \'de\' MMMM', 'es_ES').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReminderDetailCubit, ReminderDetailState>(
      listener: (context, state) {
        switch (state) {
          case ReminderDetailCompleted():
            _showSnackBar(context, 'Recordatorio completado');
            context.pop();
          case ReminderDetailDeleted():
            _showSnackBar(context, 'Recordatorio eliminado');
            context.pop();
          case ReminderDetailSnoozed(:final newTime):
            final timeStr = DateFormat.Hm('es_ES').format(newTime);
            _showSnackBar(context, 'Te recordaré a las $timeStr');
            context.pop();
          case ReminderDetailError(:final message):
            _showSnackBar(context, message, isError: true);
          case ReminderDetailLoaded(:final reminder):
            if (reminder.scheduledAt != null &&
                reminder.status != ReminderStatus.completed &&
                !reminder.isNote) {
              _startCountdown(reminder.scheduledAt!);
            }
            // Verificar si la alarma está sonando
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _checkAlarmStatus();
            });
          default:
            break;
        }
      },
      builder: (context, state) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Scaffold(
          backgroundColor: AppColors.bgPrimaryAdaptive(Theme.of(context).brightness),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_rounded,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                size: 28,
              ),
              onPressed: () => context.pop(),
              tooltip: 'Volver',
            ),
            title: Text(
              'Volver',
              style: TextStyle(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                fontWeight: FontWeight.w500,
                fontSize: 18,
              ),
            ),
            titleSpacing: 0,
          ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: AppColors.textHelper,
            ),
            const SizedBox(height: 24),
            Text(
              'No se encontró el recordatorio',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Volver', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                onPressed: () => context.read<ReminderDetailCubit>().reload(),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reintentar', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _stopAlarm(Reminder reminder) async {
    if (reminder.notificationId != null) {
      await _alarmService.stopAlarm(reminder.notificationId!);
      if (mounted) {
        setState(() => _isAlarmRinging = false);
        _showSnackBar(context, 'Alarma detenida');
      }
    }
  }

  Future<void> _snoozeAlarm(Reminder reminder) async {
    if (reminder.notificationId != null) {
      // Capturar el cubit antes del await
      final cubit = context.read<ReminderDetailCubit>();
      await _alarmService.stopAlarm(reminder.notificationId!);
      // Posponer el recordatorio
      cubit.snooze(const Duration(minutes: 5));
      if (mounted) {
        setState(() => _isAlarmRinging = false);
      }
    }
  }

  Widget _buildContent(BuildContext context, Reminder reminder) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isNote = reminder.isNote;
    final isCompleted = reminder.status == ReminderStatus.completed;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Banner de alarma sonando (si aplica)
          if (_isAlarmRinging && !isCompleted)
            AlarmRingingBanner(
              onStop: () => _stopAlarm(reminder),
              onSnooze: () => _snoozeAlarm(reminder),
            ),

          // Card principal: Tipo + Título
          _buildHeaderCard(reminder, isDark),
          const SizedBox(height: 16),

          // Card de fecha/hora o ubicación
          if (isNote)
            _buildLocationCard(reminder, isDark)
          else if (reminder.scheduledAt != null)
            _buildDateTimeCard(reminder, isDark),

          // Card de descripción con TTS
          if (reminder.description.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildDescriptionCard(reminder, isDark),
          ],

          const SizedBox(height: 32),

          // Botones de acción
          if (isCompleted)
            _buildCompletedBanner(isDark)
          else
            _buildActionButtons(context, reminder, isDark),

          // Link de eliminar
          const SizedBox(height: 24),
          _buildDeleteLink(context, isDark),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(Reminder reminder, bool isDark) {
    final typeColor = reminder.type.color;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgSecondaryDark : AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: typeColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chip de tipo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: typeColor.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Text(
              reminder.type.displayName,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: typeColor,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Título grande
          Text(
            reminder.title,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              height: 1.3,
            ),
          ),

          // Indicador de importancia si es alta
          if (reminder.importance == ReminderImportance.high) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.priority_high_rounded,
                  size: 20,
                  color: AppColors.error,
                ),
                const SizedBox(width: 6),
                Text(
                  'Importante',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDateTimeCard(Reminder reminder, bool isDark) {
    final scheduledAt = reminder.scheduledAt!;
    final isOverdue = reminder.isOverdue;
    final showCountdown = !isOverdue && reminder.status != ReminderStatus.completed;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgSecondaryDark : AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(16),
        border: isOverdue
            ? Border.all(color: AppColors.error.withValues(alpha: 0.5), width: 2)
            : null,
      ),
      child: Column(
        children: [
          // Fecha y hora principal
          Row(
            children: [
              Icon(
                Icons.schedule_rounded,
                size: 28,
                color: isOverdue ? AppColors.error : AppColors.accentPrimary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDateDisplay(scheduledAt),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat.Hm('es_ES').format(scheduledAt),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: isOverdue ? AppColors.error : AppColors.accentPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Countdown o estado vencido
          if (showCountdown && !_isTimeUp) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.accentPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 22,
                    color: AppColors.accentPrimary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Faltan ${_formatCountdown(_timeRemaining)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accentPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ] else if (isOverdue) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.warning_rounded,
                    size: 22,
                    color: AppColors.error,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Recordatorio vencido',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLocationCard(Reminder reminder, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgSecondaryDark : AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          if (reminder.object != null && reminder.object!.isNotEmpty) ...[
            Row(
              children: [
                Icon(
                  Icons.category_rounded,
                  size: 24,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Objeto',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                reminder.object!,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
              ),
            ),
          ],
          if (reminder.object != null &&
              reminder.object!.isNotEmpty &&
              reminder.location != null &&
              reminder.location!.isNotEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1),
            ),
          if (reminder.location != null && reminder.location!.isNotEmpty) ...[
            Row(
              children: [
                Icon(
                  Icons.place_rounded,
                  size: 24,
                  color: AppColors.reminderLocation,
                ),
                const SizedBox(width: 12),
                Text(
                  'Ubicación',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                reminder.location!,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppColors.reminderLocation,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(Reminder reminder, bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _speakReminder(reminder),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.bgSecondaryDark : AppColors.bgSecondary,
            borderRadius: BorderRadius.circular(16),
            border: _isSpeaking
                ? Border.all(color: AppColors.accentPrimary, width: 2)
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _isSpeaking ? Icons.volume_up_rounded : Icons.volume_up_outlined,
                    size: 24,
                    color: _isSpeaking
                        ? AppColors.accentPrimary
                        : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Descripción',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _isSpeaking
                          ? AppColors.accentPrimary.withValues(alpha: 0.15)
                          : (isDark ? AppColors.bgTertiaryDark : AppColors.bgTertiary),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _isSpeaking ? 'Escuchando...' : 'Tocar para escuchar',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: _isSpeaking
                            ? AppColors.accentPrimary
                            : (isDark ? AppColors.textHelperDark : AppColors.textHelper),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                reminder.description,
                style: TextStyle(
                  fontSize: 18,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Reminder reminder, bool isDark) {
    final isNote = reminder.isNote;
    final cubit = context.read<ReminderDetailCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Botón principal: Completar
        if (!isNote)
          SizedBox(
            height: 60,
            child: FilledButton.icon(
              onPressed: () {
                HapticFeedback.mediumImpact();
                cubit.markAsCompleted();
              },
              icon: const Icon(Icons.check_rounded, size: 26),
              label: const Text(
                'Completar',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
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

        // Botón de posponer
        if (!isNote && reminder.scheduledAt != null) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 60,
            child: OutlinedButton.icon(
              onPressed: () => _showSnoozeOptions(context),
              icon: const Icon(Icons.snooze_rounded, size: 26),
              label: const Text(
                'Recordar más tarde',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                side: BorderSide(
                  color: isDark ? AppColors.dividerDark : AppColors.divider,
                  width: 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],

        // Botón de editar
        const SizedBox(height: 12),
        SizedBox(
          height: 60,
          child: OutlinedButton.icon(
            onPressed: () {
              // TODO: Implementar edición
              _showSnackBar(context, 'Edición próximamente disponible');
            },
            icon: const Icon(Icons.edit_rounded, size: 26),
            label: const Text(
              'Editar',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              side: BorderSide(
                color: isDark ? AppColors.dividerDark : AppColors.divider,
                width: 2,
              ),
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
        color: AppColors.success.withValues(alpha: 0.15),
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
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteLink(BuildContext context, bool isDark) {
    return Center(
      child: TextButton(
        onPressed: () => _showDeleteConfirmation(context),
        style: TextButton.styleFrom(
          foregroundColor: AppColors.error.withValues(alpha: 0.8),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        child: const Text(
          'Eliminar recordatorio',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  void _showSnoozeOptions(BuildContext context) {
    final cubit = context.read<ReminderDetailCubit>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.bgSecondaryDark : AppColors.bgSecondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '¿Cuándo te recuerdo?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _buildSnoozeOption(
                context: ctx,
                label: 'En 5 minutos',
                duration: const Duration(minutes: 5),
                cubit: cubit,
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              _buildSnoozeOption(
                context: ctx,
                label: 'En 15 minutos',
                duration: const Duration(minutes: 15),
                cubit: cubit,
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              _buildSnoozeOption(
                context: ctx,
                label: 'En 1 hora',
                duration: const Duration(hours: 1),
                cubit: cubit,
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              _buildSnoozeOption(
                context: ctx,
                label: 'Mañana a esta hora',
                duration: const Duration(days: 1),
                cubit: cubit,
                isDark: isDark,
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
    required bool isDark,
  }) {
    return SizedBox(
      height: 56,
      child: OutlinedButton(
        onPressed: () {
          Navigator.pop(context);
          HapticFeedback.mediumImpact();
          cubit.snooze(duration);
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          side: BorderSide(
            color: isDark ? AppColors.dividerDark : AppColors.divider,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    final cubit = context.read<ReminderDetailCubit>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.bgSecondaryDark : AppColors.bgSecondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          '¿Eliminar recordatorio?',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Esta acción no se puede deshacer.',
          style: TextStyle(
            fontSize: 18,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          ),
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          SizedBox(
            height: 48,
            child: TextButton(
              onPressed: () => Navigator.pop(ctx),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24),
              ),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                HapticFeedback.mediumImpact();
                cubit.delete();
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.error,
                padding: const EdgeInsets.symmetric(horizontal: 24),
              ),
              child: const Text(
                'Eliminar',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateDisplay(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Hoy';
    } else if (dateOnly == tomorrow) {
      return 'Mañana';
    } else {
      // Capitalizar primera letra
      final formatted = DateFormat('EEEE d MMM', 'es_ES').format(date);
      return formatted[0].toUpperCase() + formatted.substring(1);
    }
  }
}
