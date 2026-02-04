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

  /// Verifica si una alarma específica está sonando actualmente
  bool isAlarmRinging(int alarmId);

  /// Verifica si hay alguna alarma sonando para un reminder (por notificationId)
  bool isRingingForReminder(Reminder reminder);

  /// Obtiene el ID del reminder desde el payload de una alarma sonando
  String? getReminderIdFromRingingAlarm(int alarmId);
}

class AlarmServiceImpl implements AlarmService {
  bool _initialized = false;
  
  /// Conjunto de alarmas actualmente sonando (rastreadas internamente)
  final Set<AlarmSettings> _ringingAlarms = {};
  // ignore: unused_field - usado para mantener la suscripción activa
  StreamSubscription<dynamic>? _ringingSubscription;

  @override
  Future<void> initialize() async {
    if (_initialized) return;

    await Alarm.init();
    _initialized = true;
    
    // Escuchar el stream de alarmas sonando para mantener estado interno
    _ringingSubscription = Alarm.ringing.listen((alarmSet) {
      _ringingAlarms.clear();
      _ringingAlarms.addAll(alarmSet.alarms);
    });
    
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
      payload: reminder.id, // Incluir reminderId para navegación
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
  Future<List<AlarmSettings>> getScheduledAlarms() async {
    return await Alarm.getAlarms();
  }

  @override
  bool shouldUseAlarm(Reminder reminder) {
    // Todos los recordatorios usan alarma infalible
    return true;
  }

  @override
  bool isAlarmRinging(int alarmId) {
    return _ringingAlarms.any((alarm) => alarm.id == alarmId);
  }

  @override
  bool isRingingForReminder(Reminder reminder) {
    if (reminder.notificationId == null) return false;
    return isAlarmRinging(reminder.notificationId!);
  }

  @override
  String? getReminderIdFromRingingAlarm(int alarmId) {
    final alarm = _ringingAlarms.where((a) => a.id == alarmId).firstOrNull;
    return alarm?.payload;
  }

  @override
  Future<bool> stopAlarm(int alarmId) async {
    final result = await Alarm.stop(alarmId);
    // Remover del conjunto de alarmas sonando
    _ringingAlarms.removeWhere((alarm) => alarm.id == alarmId);
    return result;
  }
}
