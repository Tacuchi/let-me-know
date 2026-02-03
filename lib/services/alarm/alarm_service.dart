import 'dart:async';
import 'dart:io';

import 'package:alarm/alarm.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../features/reminders/domain/entities/reminder.dart';
import '../../features/reminders/domain/entities/reminder_type.dart';

/// Servicio de alarmas infalibles.
/// Usa foreground service en Android y audio background en iOS.
abstract class AlarmService {
  /// Inicializa el servicio de alarmas
  Future<void> initialize();

  /// Programa una alarma para un recordatorio
  Future<bool> scheduleAlarm(Reminder reminder);

  /// Cancela una alarma
  Future<bool> cancelAlarm(int alarmId);

  /// Cancela todas las alarmas
  Future<void> cancelAllAlarms();

  /// Stream de alarmas que están sonando (emite cada alarma individual)
  Stream<AlarmSettings> get ringingStream;

  /// Detiene la alarma que está sonando
  Future<bool> stopAlarm(int alarmId);

  /// Obtiene todas las alarmas programadas
  Future<List<AlarmSettings>> getScheduledAlarms();

  /// Verifica si el recordatorio debe usar alarma (alta importancia)
  bool shouldUseAlarm(Reminder reminder);
}

class AlarmServiceImpl implements AlarmService {
  bool _initialized = false;

  @override
  Future<void> initialize() async {
    if (_initialized) return;

    await Alarm.init();
    _initialized = true;
    
    if (Platform.isAndroid) {
      await _checkAndRequestPermissions();
    }
  }

  Future<void> _checkAndRequestPermissions() async {
    if ((await Permission.notification.status).isDenied) {
      await Permission.notification.request();
    }
    
    if ((await Permission.scheduleExactAlarm.status).isDenied) {
      await Permission.scheduleExactAlarm.request();
    }
    
    if ((await Permission.ignoreBatteryOptimizations.status).isDenied) {
      await Permission.ignoreBatteryOptimizations.request();
    }
  }

  @override
  Future<bool> scheduleAlarm(Reminder reminder) async {
    if (!_initialized) await initialize();
    if (reminder.scheduledAt == null) return false;
    
    final now = DateTime.now();
    final minTime = now.add(const Duration(seconds: 2));
    if (reminder.scheduledAt!.isBefore(minTime)) return false;

    final alarmId = reminder.notificationId ?? 
        reminder.id.hashCode.abs() % 2147483647;

    final alarmSettings = AlarmSettings(
      id: alarmId,
      dateTime: reminder.scheduledAt!,
      assetAudioPath: 'assets/sounds/alarm.mp3',
      loopAudio: true,
      vibrate: true,
      warningNotificationOnKill: true,
      androidFullScreenIntent: true,
      volumeSettings: VolumeSettings.fade(
        fadeDuration: const Duration(seconds: 3),
        volume: 0.8,
        volumeEnforced: true,
      ),
      notificationSettings: NotificationSettings(
        title: '${reminder.type.emoji} ${reminder.title}',
        body: reminder.description.isNotEmpty
            ? reminder.description
            : _getDefaultBody(reminder),
        stopButton: 'Detener',
        icon: 'ic_launcher',
      ),
    );

    return await Alarm.set(alarmSettings: alarmSettings);
  }

  String _getDefaultBody(Reminder reminder) {
    return switch (reminder.type) {
      ReminderType.medication => '¡Es hora de tu medicamento!',
      ReminderType.appointment => '¡Tienes una cita!',
      _ => '¡Tienes un recordatorio!'
    };
  }

  @override
  Future<bool> cancelAlarm(int alarmId) async {
    return await Alarm.stop(alarmId);
  }

  @override
  Future<void> cancelAllAlarms() async {
    await Alarm.stopAll();
  }

  @override
  Stream<AlarmSettings> get ringingStream {
    // Transformar el stream de AlarmSet a AlarmSettings individuales
    return Alarm.ringing.expand((alarmSet) => alarmSet.alarms);

  }

  @override
  Future<bool> stopAlarm(int alarmId) async {
    return await Alarm.stop(alarmId);
  }

  @override
  Future<List<AlarmSettings>> getScheduledAlarms() async {
    return await Alarm.getAlarms();
  }

  @override
  bool shouldUseAlarm(Reminder reminder) {
    // Todos los recordatorios usan alarma infalible
    return true;
  }
}
