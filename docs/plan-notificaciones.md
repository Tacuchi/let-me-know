# Plan de Implementación: Notificaciones Locales

**Proyecto**: Let Me Know  
**Prioridad**: 🔴 Alta  
**Estimación**: 3-4 horas  
**Dependencias**: Ninguna (puede ejecutarse en paralelo)

---

## 🎯 Objetivo

Implementar notificaciones locales para alertar al usuario cuando llegue la hora del recordatorio.

## 📦 Estado Actual

- `flutter_local_notifications` está **comentado** en `pubspec.yaml`
- No existe `NotificationService`
- No hay permisos configurados para notificaciones
- Los recordatorios se guardan pero nunca notifican

---

## 📋 Tareas

### 1. Agregar dependencia

**Archivo**: `pubspec.yaml`

```yaml
dependencies:
  # Notificaciones
  flutter_local_notifications: ^18.0.1
```

Ejecutar:
```bash
flutter pub get
```

---

### 2. Configurar permisos iOS

**Archivo**: `ios/Runner/Info.plist`

Agregar dentro de `<dict>`:

```xml
<!-- Notificaciones -->
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

---

### 3. Configurar permisos Android

**Archivo**: `android/app/src/main/AndroidManifest.xml`

Agregar dentro de `<manifest>` (antes de `<application>`):

```xml
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.VIBRATE"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.USE_EXACT_ALARM"/>
```

Agregar dentro de `<application>`:

```xml
<receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
<receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
    <intent-filter>
        <action android:name="android.intent.action.BOOT_COMPLETED"/>
        <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
        <action android:name="android.intent.action.QUICKBOOT_POWERON" />
        <category android:name="android.intent.category.DEFAULT" />
    </intent-filter>
</receiver>
```

---

### 4. Crear interfaz del servicio

**Archivo nuevo**: `lib/services/notifications/notification_service.dart`

```dart
import '../../features/reminders/domain/entities/reminder.dart';

abstract class NotificationService {
  /// Inicializa el plugin de notificaciones
  Future<bool> initialize();
  
  /// Programa una notificación para un recordatorio
  Future<void> scheduleNotification(Reminder reminder);
  
  /// Cancela una notificación programada
  Future<void> cancelNotification(int notificationId);
  
  /// Cancela todas las notificaciones
  Future<void> cancelAllNotifications();
  
  /// Solicita permisos al usuario
  Future<bool> requestPermissions();
  
  /// Verifica si tiene permisos
  Future<bool> hasPermissions();
}
```

---

### 5. Implementar el servicio

**Archivo nuevo**: `lib/services/notifications/notification_service_impl.dart`

```dart
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

import '../../features/reminders/domain/entities/reminder.dart';
import '../../features/reminders/domain/entities/reminder_type.dart';
import 'notification_service.dart';

class NotificationServiceImpl implements NotificationService {
  final FlutterLocalNotificationsPlugin _plugin = 
      FlutterLocalNotificationsPlugin();
  
  bool _initialized = false;

  @override
  Future<bool> initialize() async {
    if (_initialized) return true;
    
    tz.initializeTimeZones();
    
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    final result = await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
    
    _initialized = result ?? false;
    return _initialized;
  }

  void _onNotificationTap(NotificationResponse response) {
    // TODO: Navegar al recordatorio cuando se toca la notificación
    // El payload contiene el ID del recordatorio
  }

  @override
  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final granted = await android?.requestNotificationsPermission();
      return granted ?? false;
    }
    
    if (Platform.isIOS) {
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      final granted = await ios?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }
    
    return false;
  }

  @override
  Future<bool> hasPermissions() async {
    // Simplificado - en producción verificar permisos reales
    return true;
  }

  @override
  Future<void> scheduleNotification(Reminder reminder) async {
    if (!_initialized) await initialize();
    if (reminder.scheduledAt == null) return;
    
    // No programar si ya pasó la hora
    if (reminder.scheduledAt!.isBefore(DateTime.now())) return;
    
    final notificationId = reminder.notificationId ?? 
        reminder.id.hashCode.abs() % 2147483647;
    
    final androidDetails = AndroidNotificationDetails(
      'reminders_channel',
      'Recordatorios',
      channelDescription: 'Notificaciones de recordatorios',
      importance: _getImportance(reminder),
      priority: _getPriority(reminder),
      icon: '@mipmap/ic_launcher',
    );
    
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    final scheduledDate = tz.TZDateTime.from(
      reminder.scheduledAt!,
      tz.local,
    );
    
    await _plugin.zonedSchedule(
      notificationId,
      _getIcon(reminder.type) + ' ' + reminder.title,
      reminder.description,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: reminder.id,
    );
  }

  @override
  Future<void> cancelNotification(int notificationId) async {
    await _plugin.cancel(notificationId);
  }

  @override
  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }

  Importance _getImportance(Reminder reminder) {
    switch (reminder.importance) {
      case ReminderImportance.high:
        return Importance.high;
      case ReminderImportance.medium:
        return Importance.defaultImportance;
      case ReminderImportance.low:
        return Importance.low;
    }
  }

  Priority _getPriority(Reminder reminder) {
    switch (reminder.importance) {
      case ReminderImportance.high:
        return Priority.high;
      case ReminderImportance.medium:
        return Priority.defaultPriority;
      case ReminderImportance.low:
        return Priority.low;
    }
  }

  String _getIcon(ReminderType type) {
    switch (type) {
      case ReminderType.medication:
        return '💊';
      case ReminderType.appointment:
        return '🏥';
      case ReminderType.call:
        return '📞';
      case ReminderType.shopping:
        return '🛒';
      case ReminderType.event:
        return '📅';
      case ReminderType.location:
        return '📍';
      case ReminderType.task:
        return '📝';
    }
  }
}
```

---

### 6. Agregar dependencia timezone

**Archivo**: `pubspec.yaml`

```yaml
dependencies:
  timezone: ^0.9.4
```

---

### 7. Registrar en inyección de dependencias

**Archivo**: `lib/di/injection_container.dart`

```dart
// Agregar imports
import 'package:let_me_know/services/notifications/notification_service.dart';
import 'package:let_me_know/services/notifications/notification_service_impl.dart';

// En configureDependencies()
getIt.registerLazySingleton<NotificationService>(
  () => NotificationServiceImpl(),
);
```

---

### 8. Inicializar en main.dart

**Archivo**: `lib/main.dart`

```dart
import 'services/notifications/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  
  // Inicializar notificaciones
  final notificationService = getIt<NotificationService>();
  await notificationService.initialize();
  await notificationService.requestPermissions();
  
  runApp(const App());
}
```

---

### 9. Programar notificación al guardar recordatorio

**Archivo**: `lib/features/reminders/infrastructure/repositories/reminder_repository_drift_impl.dart`

Modificar método `save()`:

```dart
@override
Future<void> save(Reminder reminder) async {
  await _db
      .into(_db.reminders)
      .insertOnConflictUpdate(_toCompanion(reminder));
  
  // Programar notificación si tiene fecha
  if (reminder.scheduledAt != null && reminder.hasNotification) {
    final notificationService = getIt<NotificationService>();
    await notificationService.scheduleNotification(reminder);
  }
}
```

---

### 10. Cancelar notificación al completar/eliminar

**Archivo**: `lib/features/reminders/infrastructure/repositories/reminder_repository_drift_impl.dart`

Modificar métodos `delete()` y `markAsCompleted()`:

```dart
@override
Future<void> delete(String id) async {
  // Obtener el recordatorio para cancelar notificación
  final reminder = await getById(id);
  if (reminder?.notificationId != null) {
    final notificationService = getIt<NotificationService>();
    await notificationService.cancelNotification(reminder!.notificationId!);
  }
  
  await (_db.delete(_db.reminders)..where((t) => t.id.equals(id))).go();
}

@override
Future<void> markAsCompleted(String id) async {
  // Cancelar notificación
  final reminder = await getById(id);
  if (reminder?.notificationId != null) {
    final notificationService = getIt<NotificationService>();
    await notificationService.cancelNotification(reminder!.notificationId!);
  }
  
  await (_db.update(_db.reminders)..where((t) => t.id.equals(id))).write(
    RemindersCompanion(
      status: const Value('completed'),
      completedAtMs: Value(DateTime.now().millisecondsSinceEpoch),
      updatedAtMs: Value(DateTime.now().millisecondsSinceEpoch),
    ),
  );
}
```

---

## ✅ Criterios de Aceptación

- [ ] Al crear un recordatorio con fecha futura, se programa notificación
- [ ] La notificación aparece en la hora programada
- [ ] Al tocar la notificación, se abre la app
- [ ] Al completar un recordatorio, se cancela su notificación
- [ ] Al eliminar un recordatorio, se cancela su notificación
- [ ] Funciona en Android 13+ (requiere permiso explícito)
- [ ] Funciona en iOS
- [ ] `flutter analyze` sin errores

---

## 📁 Archivos a Crear/Modificar

| Archivo | Acción |
|---------|--------|
| `pubspec.yaml` | MODIFICAR (agregar dependencias) |
| `ios/Runner/Info.plist` | MODIFICAR |
| `android/app/src/main/AndroidManifest.xml` | MODIFICAR |
| `lib/services/notifications/notification_service.dart` | **NUEVO** |
| `lib/services/notifications/notification_service_impl.dart` | **NUEVO** |
| `lib/di/injection_container.dart` | MODIFICAR |
| `lib/main.dart` | MODIFICAR |
| `lib/features/reminders/infrastructure/repositories/reminder_repository_drift_impl.dart` | MODIFICAR |

---

## ⚠️ Notas Importantes

1. **Android 13+**: Requiere solicitar `POST_NOTIFICATIONS` en runtime
2. **iOS**: Requiere solicitar permisos la primera vez
3. **Timezone**: Usar `timezone` package para manejar zonas horarias correctamente
4. **Exact Alarms**: En Android 12+, usar `SCHEDULE_EXACT_ALARM` o `USE_EXACT_ALARM`
5. **Background**: Las notificaciones funcionan incluso con la app cerrada

---

## 🔗 Recursos

- [flutter_local_notifications docs](https://pub.dev/packages/flutter_local_notifications)
- [Android notification permissions](https://developer.android.com/develop/ui/views/notifications/notification-permission)

---

*Plan creado: 24 de diciembre de 2025*
