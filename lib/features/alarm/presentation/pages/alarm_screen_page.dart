import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/constants.dart';
import '../../../../di/injection_container.dart';
import '../../../../services/alarm/alarm_service.dart';
import '../../../reminders/domain/entities/reminder.dart';
import '../../../reminders/domain/entities/reminder_status.dart';
import '../../../reminders/domain/entities/reminder_type.dart';
import '../../../reminders/domain/repositories/reminder_repository.dart';

/// Pantalla de alarma fullscreen que se muestra cuando se dispara un recordatorio
/// de alta importancia (medicamentos, citas médicas).
/// Diseñada para ser accesible para adultos mayores con botones grandes.
class AlarmScreenPage extends StatefulWidget {
  final String reminderId;

  const AlarmScreenPage({super.key, required this.reminderId});

  @override
  State<AlarmScreenPage> createState() => _AlarmScreenPageState();
}

class _AlarmScreenPageState extends State<AlarmScreenPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  Reminder? _reminder;
  bool _loading = true;
  Timer? _autoCloseTimer;

  @override
  void initState() {
    super.initState();
    
    // Animación de pulso para el ícono
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _loadReminder();
    
    // Auto-cerrar después de 5 minutos si no hay interacción
    _autoCloseTimer = Timer(const Duration(minutes: 5), () {
      if (mounted) context.pop();
    });

    // Vibración al abrir
    HapticFeedback.heavyImpact();
  }

  Future<void> _loadReminder() async {
    try {
      final repo = getIt<ReminderRepository>();
      final reminder = await repo.getById(widget.reminderId);
      if (mounted) {
        setState(() {
          _reminder = reminder;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _autoCloseTimer?.cancel();
    super.dispose();
  }

  Future<void> _completeReminder() async {
    HapticFeedback.mediumImpact();
    
    try {
      // Detener la alarma primero
      await _stopAlarm();
      
      final repo = getIt<ReminderRepository>();
      await repo.markAsCompleted(widget.reminderId);
      if (mounted) {
        _showSuccessAndClose('✓ ¡Completado!');
      }
    } catch (e) {
      if (mounted) context.pop();
    }
  }

  Future<void> _stopAlarm() async {
    if (_reminder?.notificationId != null) {
      final alarmService = getIt<AlarmService>();
      await alarmService.stopAlarm(_reminder!.notificationId!);
    }
  }

  Future<void> _snoozeReminder(Duration duration) async {
    HapticFeedback.mediumImpact();
    
    try {
      // Detener la alarma primero
      await _stopAlarm();
      
      final repo = getIt<ReminderRepository>();
      await repo.snooze(widget.reminderId, duration);
      if (mounted) {
        final minutes = duration.inMinutes;
        _showSuccessAndClose('⏰ Pospuesto $minutes min');
      }
    } catch (e) {
      if (mounted) context.pop();
    }
  }

  void _showSuccessAndClose(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontSize: 18)),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Fullscreen sin appbar
    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.bgPrimaryDark : AppColors.bgPrimary,
        body: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _reminder == null
                  ? _buildNotFound()
                  : _buildAlarmContent(isDark),
        ),
      ),
    );
  }

  Widget _buildNotFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            'Recordatorio no encontrado',
            style: TextStyle(fontSize: 20, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => context.pop(),
            child: const Text('Cerrar', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  Widget _buildAlarmContent(bool isDark) {
    final reminder = _reminder!;
    final isCompleted = reminder.status == ReminderStatus.completed;
    final typeColor = reminder.type.color;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Botón de cerrar en esquina
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: Icon(
                Icons.close_rounded,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                size: 32,
              ),
              onPressed: () => context.pop(),
            ),
          ),
          
          const Spacer(),

          // Ícono animado con pulso
          ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: typeColor.withValues(alpha: 0.3),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  reminder.type.emoji,
                  style: const TextStyle(fontSize: 64),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Título del recordatorio
          Text(
            reminder.title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),

          // Badge de tipo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(reminder.type.icon, color: typeColor, size: 24),
                const SizedBox(width: 8),
                Text(
                  reminder.type.displayName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: typeColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Hora programada
          if (reminder.scheduledAt != null)
            Text(
              '¡Es hora!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppColors.warning,
              ),
            ),

          const Spacer(),

          // Botones de acción (grandes y accesibles)
          if (!isCompleted) ...[
            // Botón principal: Completar
            SizedBox(
              width: double.infinity,
              height: 72,
              child: FilledButton.icon(
                onPressed: _completeReminder,
                icon: const Icon(Icons.check_rounded, size: 32),
                label: const Text(
                  '✓ Listo',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Botones de posponer
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 64,
                    child: OutlinedButton(
                      onPressed: () => _snoozeReminder(const Duration(minutes: 5)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.warning,
                        side: BorderSide(color: AppColors.warning, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        '⏰ 5 min',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 64,
                    child: OutlinedButton(
                      onPressed: () => _snoozeReminder(const Duration(minutes: 15)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.warning,
                        side: BorderSide(color: AppColors.warning, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        '⏰ 15 min',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            // Ya completado
            Container(
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
                    'Ya completado',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
