# Plan: Alarmas y Notificaciones con Acciones Rápidas

**Proyecto**: Let Me Know  
**Prioridad**: 🔴 Alta  
**Estimación**: 8-10 horas  
**Fecha**: 25 de diciembre de 2025

## 🎯 Objetivo
Implementar un sistema completo de alarmas y notificaciones que permita al adulto mayor:
1. Recibir alertas de alta prioridad cuando llegue la hora del recordatorio
2. Marcar como completado o posponer directamente desde la notificación
3. Acceder al detalle del recordatorio al tocar la notificación
4. Editar el recordatorio desde la vista de detalle

## 👴 Consideraciones UX para Adultos Mayores
- **Botones grandes** en notificaciones con texto claro ("✓ Listo", "⏰ 5 min más")
- **Sonido distintivo** para alarmas de medicamentos (alta importancia)
- **Vibración prolongada** para asegurar que se perciba
- **Texto legible** en la notificación (título corto, descripción clara)
- **Vista de detalle simple** sin scroll innecesario
- **Botones de acción prominentes** en la vista de detalle

## 📊 Estado Actual
| Componente | Estado |
|------------|--------|
| NotificationService (interfaz) | ✅ Existe |
| NotificationServiceImpl | ✅ Existe (básico) |
| Integración con repositorio | ✅ Existe (save/delete/complete) |
| Permisos Android | ✅ Configurados |
| Permisos iOS | ✅ Configurados |
| Action buttons | ❌ No implementado |
| Background handler | ❌ No implementado |
| Deep linking a detalle | ❌ No implementado |
| Vista de detalle | ❌ No existe |

## 🤖 vs 🍎 Diferencias Android e iOS

### Comparativa de Capacidades
| Característica | Android | iOS | Notas |
|----------------|---------|-----|-------|
| **Permisos** | Automático (< Android 13) | Siempre requerido | Android 13+ requiere POST_NOTIFICATIONS |
| **Límite de notificaciones** | ~500 (Samsung) | 64 máximo | iOS solo mantiene las 64 más recientes |
| **Action buttons** | Ilimitados en notificación | Máx. 4 por categoría | iOS requiere definir categorías |
| **Canales** | Obligatorios (Android 8+) | No aplica | Android usa canales para prioridad |
| **Background handler** | Corre en isolate | Corre en isolate | Ambos requieren `@pragma('vm:entry-point')` |
| **Sonido personalizado** | Flexible (res/raw) | Requiere formato específico | iOS: .aiff, .wav, .caf (≤30 seg) |
| **Vibración** | Patrón configurable | Solo on/off | Android permite patrones complejos |
| **LED** | Configurable | No disponible | Solo algunos Android |
| **Heads-up** | Importance.max | Siempre si permitido | Android requiere canal de alta importancia |
| **Exact timing** | Requiere permiso exacto | Sí (aprox.) | Android 12+ necesita SCHEDULE_EXACT_ALARM |
| **App launch detection** | ✅ Completo | ✅ Completo | `getNotificationAppLaunchDetails()` |

### Limitaciones Críticas

#### iOS
1. **Máximo 64 notificaciones programadas**: iOS solo mantiene las últimas 64 notificaciones. Para una app de recordatorios esto es crítico si el usuario programa muchos.
2. **Categorías predefinidas**: Las acciones (botones) deben definirse en categorías durante la inicialización, no se pueden crear dinámicamente.
3. **Permisos obligatorios**: El usuario DEBE aprobar notificaciones. Si rechaza, no hay forma de mostrarlas.
4. **Simulador no soporta notificaciones**: Probar siempre en dispositivo físico.

#### Android
1. **Samsung limita a ~500 alarmas**: Dispositivos Samsung tienen un límite de AlarmManager. Manejar excepciones.
2. **Android 13+ requiere permiso explícito**: Solicitar `POST_NOTIFICATIONS` en runtime.
3. **Exact alarms requieren permisos**: Android 12+ necesita `SCHEDULE_EXACT_ALARM` o `USE_EXACT_ALARM`.
4. **Canales inmutables**: Una vez creado un canal, el usuario controla su comportamiento desde Ajustes.

### Estrategia de Implementación Cross-Platform

#### Action Buttons
```dart
// Android: Acciones directamente en NotificationDetails
const androidDetails = AndroidNotificationDetails(
  'channel_id',
  'Channel Name',
  actions: <AndroidNotificationAction>[
    AndroidNotificationAction('complete', '✓ Listo', cancelNotification: true),
    AndroidNotificationAction('snooze_5', '⏰ 5 min', cancelNotification: true),
  ],
);

// iOS: Acciones en categoría durante inicialización
final iosSettings = DarwinInitializationSettings(
  notificationCategories: [
    DarwinNotificationCategory(
      'reminder_actions',
      actions: <DarwinNotificationAction>[
        DarwinNotificationAction.plain('complete', '✓ Listo'),
        DarwinNotificationAction.plain('snooze_5', '⏰ 5 min'),
      ],
    ),
  ],
);

// Al mostrar notificación iOS, referenciar la categoría
const iosDetails = DarwinNotificationDetails(
  categoryIdentifier: 'reminder_actions',
);
```

#### Manejo de Permisos
```dart
Future<bool> requestPermissions() async {
  if (Platform.isAndroid) {
    // Android 13+ requiere permiso explícito
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    // Verificar versión de Android
    final deviceInfo = await DeviceInfoPlugin().androidInfo;
    if (deviceInfo.version.sdkInt >= 33) {
      return await android?.requestNotificationsPermission() ?? false;
    }
    return true; // Versiones anteriores no requieren permiso
  }

  if (Platform.isIOS) {
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    return await ios?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    ) ?? false;
  }

  return false;
}
```

#### Canales de Notificación (Android)
```dart
// Crear canales al inicializar (Android 8+)
Future<void> _createNotificationChannels() async {
  if (!Platform.isAndroid) return;
  
  final android = _plugin.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>();
  
  // Canal de alta prioridad para medicamentos
  await android?.createNotificationChannel(
    const AndroidNotificationChannel(
      'high_importance',
      'Recordatorios Importantes',
      description: 'Medicamentos y citas médicas',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    ),
  );
  
  // Canal normal para tareas generales
  await android?.createNotificationChannel(
    const AndroidNotificationChannel(
      'default',
      'Recordatorios',
      description: 'Recordatorios generales',
      importance: Importance.high,
    ),
  );
}
```

### Configuración Nativa Requerida

#### iOS - AppDelegate.swift
```swift
import UIKit
import Flutter
import flutter_local_notifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Configurar delegate para notificaciones en foreground
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

#### Android - MainActivity.kt (opcional, para personalización)
```kotlin
package com.example.let_me_know

import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    // Por defecto no requiere cambios
    // Solo si necesitas manejar intents específicos
}
```

## 📋 Tareas por Fase

### Fase 1: Mejorar Notificaciones con Acciones (3-4 horas)

#### 1.1 Agregar action buttons a AndroidNotificationDetails
**Archivo**: `lib/services/notifications/notification_service_impl.dart`

Acciones requeridas:
- `complete`: Marcar como completado (cancela notificación)
- `snooze_5`: Posponer 5 minutos (reprograma notificación)

```dart
actions: <AndroidNotificationAction>[
  const AndroidNotificationAction(
    'complete',
    '✓ Listo',
    cancelNotification: true,
    showsUserInterface: false,
  ),
  const AndroidNotificationAction(
    'snooze_5',
    '⏰ 5 min',
    cancelNotification: true,
    showsUserInterface: false,
  ),
],
```

#### 1.2 Configurar categorías para iOS
**Archivo**: `lib/services/notifications/notification_service_impl.dart`

iOS requiere definir categorías con acciones en la inicialización:

```dart
final iosSettings = DarwinInitializationSettings(
  notificationCategories: [
    DarwinNotificationCategory(
      'reminder_category',
      actions: <DarwinNotificationAction>[
        DarwinNotificationAction.plain('complete', '✓ Listo'),
        DarwinNotificationAction.plain('snooze_5', '⏰ 5 min'),
      ],
    ),
  ],
);
```

#### 1.3 Implementar background handler para acciones
**Archivo**: `lib/services/notifications/notification_service_impl.dart`

El handler debe ejecutarse incluso con la app cerrada:

```dart
@pragma('vm:entry-point')
void notificationActionHandler(NotificationResponse response) async {
  // Este código corre en un isolate separado
  final reminderId = response.payload;
  final actionId = response.actionId;
  
  if (actionId == 'complete') {
    // Marcar como completado en BD
  } else if (actionId == 'snooze_5') {
    // Reprogramar +5 minutos
  }
}
```

**Importante**: El background handler no tiene acceso al árbol de widgets ni a GetIt. Necesita inicializar dependencias mínimas.

#### 1.4 Mejorar configuración de canal Android (alarmas)
**Archivo**: `lib/services/notifications/notification_service_impl.dart`

Crear canal de alta prioridad tipo alarma:

```dart
const AndroidNotificationChannel alarmChannel = AndroidNotificationChannel(
  'high_importance_reminders',
  'Recordatorios Importantes',
  description: 'Alertas de medicamentos y citas médicas',
  importance: Importance.max,
  playSound: true,
  enableVibration: true,
  enableLights: true,
);
```

#### 1.5 Agregar snooze al repositorio
**Archivo**: `lib/features/reminders/domain/repositories/reminder_repository.dart`

```dart
Future<void> snooze(String id, Duration duration);
```

**Archivo**: `lib/features/reminders/infrastructure/repositories/reminder_repository_drift_impl.dart`

```dart
@override
Future<void> snooze(String id, Duration duration) async {
  final reminder = await getById(id);
  if (reminder == null) return;
  
  final newTime = DateTime.now().add(duration);
  
  await (_db.update(_db.reminders)..where((t) => t.id.equals(id))).write(
    RemindersCompanion(
      scheduledAtMs: Value(newTime.millisecondsSinceEpoch),
      snoozedUntilMs: Value(newTime.millisecondsSinceEpoch),
      updatedAtMs: Value(DateTime.now().millisecondsSinceEpoch),
    ),
  );
  
  // Reprogramar notificación
  final notificationService = getIt<NotificationService>();
  await notificationService.scheduleNotification(
    reminder.copyWith(scheduledAt: newTime),
  );
}
```

### Fase 2: Vista de Detalle del Recordatorio (3-4 horas)

#### 2.1 Crear ReminderDetailPage
**Archivo nuevo**: `lib/features/reminders/presentation/pages/reminder_detail_page.dart`

Diseño accesible para adultos mayores:
- Header con icono grande del tipo + título
- Información clara: fecha, hora, importancia
- Para notas: objeto y ubicación destacados
- Botones de acción grandes al final

**Wireframe conceptual**:
```
┌─────────────────────────────────────┐
│  ← Detalle                          │
├─────────────────────────────────────┤
│                                     │
│         💊                          │
│                                     │
│   Tomar pastillas para              │
│   la presión                        │
│                                     │
│   ─────────────────────────────     │
│                                     │
│   📅  Hoy, 3:00 PM                  │
│   🔴  Importancia Alta              │
│   🔔  Notificación activa           │
│                                     │
│   ─────────────────────────────     │
│                                     │
│   (Descripción si existe)           │
│                                     │
│                                     │
├─────────────────────────────────────┤
│                                     │
│   [ ✏️ Editar ]  [ ✓ Completar ]    │
│                                     │
│   [ 🗑️ Eliminar ]                   │
│                                     │
└─────────────────────────────────────┘
```

#### 2.2 Crear ReminderDetailCubit
**Archivo nuevo**: `lib/features/reminders/application/cubit/reminder_detail_cubit.dart`

Estados:
- `ReminderDetailLoading`
- `ReminderDetailLoaded(reminder)`
- `ReminderDetailNotFound`
- `ReminderDetailError(message)`

Métodos:
- `load(String id)`
- `markAsCompleted()`
- `snooze(Duration duration)`
- `delete()`

#### 2.3 Agregar ruta de detalle
**Archivo**: `lib/router/app_router.dart`

```dart
GoRoute(
  path: AppRoutes.reminderDetail,
  name: AppRoutes.reminderDetailName,
  builder: (context, state) {
    final id = state.pathParameters['id']!;
    return BlocProvider(
      create: (_) => getIt<ReminderDetailCubit>()..load(id),
      child: const ReminderDetailPage(),
    );
  },
),
```

### Fase 3: Deep Linking desde Notificación (1-2 horas)

#### 3.1 Configurar navegación desde tap en notificación
**Archivo**: `lib/services/notifications/notification_service_impl.dart`

El payload contiene el ID del recordatorio:

```dart
void _onNotificationTap(NotificationResponse response) {
  final reminderId = response.payload;
  if (reminderId != null && reminderId.isNotEmpty) {
    // Navegar a detalle
    appRouter.pushNamed(
      AppRoutes.reminderDetailName,
      pathParameters: {'id': reminderId},
    );
  }
}
```

#### 3.2 Manejar app launch desde notificación
**Archivo**: `lib/main.dart`

Verificar si la app fue abierta desde una notificación:

```dart
void main() async {
  // ... inicialización existente ...
  
  // Verificar si app se abrió desde notificación
  final notificationService = getIt<NotificationService>();
  final launchDetails = await notificationService.getAppLaunchDetails();
  
  if (launchDetails?.didNotificationLaunchApp ?? false) {
    final payload = launchDetails!.notificationResponse?.payload;
    if (payload != null) {
      // Guardar para navegar después de que el router esté listo
      _initialReminderRoute = '/reminders/$payload';
    }
  }
  
  runApp(const LetMeKnowApp());
}
```

#### 3.3 Agregar método al servicio
**Archivo**: `lib/services/notifications/notification_service.dart`

```dart
Future<NotificationAppLaunchDetails?> getAppLaunchDetails();
```

### Fase 4: Formulario de Edición (Opcional - 2 horas)

#### 4.1 Crear ReminderEditPage o Bottom Sheet
**Archivo nuevo**: `lib/features/reminders/presentation/pages/reminder_edit_page.dart`

Campos editables:
- Título (TextField)
- Descripción (TextField multiline)
- Fecha y hora (DateTimePicker)
- Tipo (Dropdown o chips)
- Importancia (Segmented buttons)
- Notificación on/off (Switch)

Para notas de ubicación:
- Objeto (TextField)
- Ubicación (TextField)

**Nota**: Este formulario puede ser una fase separada. Para el MVP, la edición básica desde el detalle es suficiente.

## 📁 Archivos a Crear/Modificar

### Nuevos
| Archivo | Descripción |
|---------|-------------|
| `lib/features/reminders/presentation/pages/reminder_detail_page.dart` | Vista de detalle |
| `lib/features/reminders/application/cubit/reminder_detail_cubit.dart` | Lógica de detalle |
| `lib/features/reminders/application/cubit/reminder_detail_state.dart` | Estados del cubit |

### Modificar
| Archivo | Cambios |
|---------|---------|
| `lib/services/notifications/notification_service.dart` | Agregar `snoozeNotification`, `getAppLaunchDetails` |
| `lib/services/notifications/notification_service_impl.dart` | Action buttons, categorías iOS, background handler |
| `lib/features/reminders/domain/repositories/reminder_repository.dart` | Agregar `snooze()` |
| `lib/features/reminders/infrastructure/repositories/reminder_repository_drift_impl.dart` | Implementar `snooze()` |
| `lib/router/app_router.dart` | Agregar ruta de detalle |
| `lib/di/injection_container.dart` | Registrar `ReminderDetailCubit` |
| `lib/main.dart` | Manejar app launch desde notificación |

## ⚠️ Consideraciones Técnicas

### Background Handler (Isolate)
El handler de acciones en background corre en un isolate separado. Esto significa:
- No tiene acceso a `GetIt` inicializado en el main isolate
- No tiene acceso al `BuildContext`
- Necesita inicializar la base de datos de forma independiente

**Solución**: Crear una función estática que inicialice solo lo necesario:

```dart
@pragma('vm:entry-point')
void notificationActionHandler(NotificationResponse response) async {
  // Inicializar BD directamente (sin GetIt)
  final db = AppDatabase();
  final repo = ReminderRepositoryDriftImpl(db);
  
  final reminderId = response.payload;
  final actionId = response.actionId;
  
  if (reminderId == null) return;
  
  if (actionId == 'complete') {
    await repo.markAsCompleted(reminderId);
  } else if (actionId == 'snooze_5') {
    await repo.snooze(reminderId, const Duration(minutes: 5));
  }
  
  await db.close();
}
```

### iOS Action Categories
En iOS, las acciones deben:
1. Definirse en la inicialización con `DarwinNotificationCategory`
2. Referenciarse al mostrar la notificación con `categoryIdentifier`
3. Tener IDs únicos consistentes con Android

### Timezone
Ya está configurado con `flutter_timezone` y `timezone`. Asegurar que:
- Las notificaciones pospuestas usen `tz.TZDateTime.now(tz.local)`
- Los tiempos se persistan en UTC en la BD

## ✅ Criterios de Aceptación

### Notificaciones
- [ ] Al llegar la hora, aparece notificación con título y descripción
- [ ] Botón "✓ Listo" marca como completado y cierra notificación
- [ ] Botón "⏰ 5 min" pospone el recordatorio y cierra notificación
- [ ] Acciones funcionan con app cerrada (background handler)
- [ ] Medicamentos usan canal de alta prioridad (sonido + vibración)

### Vista de Detalle
- [ ] Al tocar la notificación, abre la app en el detalle del recordatorio
- [ ] Muestra toda la información del recordatorio de forma clara
- [ ] Botón "Completar" funciona y vuelve atrás
- [ ] Botón "Eliminar" pide confirmación y elimina
- [ ] Funciona para notas (sin hora, muestra objeto/ubicación)

### Integración
- [ ] `flutter analyze` sin errores
- [ ] Funciona en Android 13+ (permisos POST_NOTIFICATIONS)
- [ ] Funciona en iOS 15+
- [ ] La app se puede abrir desde notificación incluso si estaba cerrada

## 🔮 Mejoras Futuras (No incluidas)
1. **Opciones de snooze múltiples**: 15 min, 1 hora, mañana
2. **Repetición automática**: Si no se confirma en X minutos, repetir
3. **Alerta a contacto de emergencia**: Para medicamentos no confirmados
4. **Sonidos personalizados**: Diferentes tonos por tipo de recordatorio
5. **Formulario de edición completo**: Modificar todos los campos

## 📝 Notas de Implementación

### Orden sugerido
1. **Fase 1.5**: Agregar `snooze()` al repositorio (necesario para acciones)
2. **Fase 1.1-1.4**: Mejorar notificaciones con acciones
3. **Fase 2**: Vista de detalle (puede probarse independiente)
4. **Fase 3**: Deep linking (une todo)

### Testing Cross-Platform

#### Matriz de Pruebas
| Escenario | Android | iOS | Prioridad |
|-----------|---------|-----|----------|
| Notificación aparece a tiempo | ✅ | ✅ | Alta |
| Botón "Listo" funciona (foreground) | ✅ | ✅ | Alta |
| Botón "Listo" funciona (background) | ✅ | ✅ | Alta |
| Botón "Listo" funciona (terminated) | ✅ | ✅ | Alta |
| Botón "Posponer" funciona | ✅ | ✅ | Alta |
| Tap abre detalle (foreground) | ✅ | ✅ | Alta |
| Tap abre detalle (background) | ✅ | ✅ | Alta |
| Tap abre detalle (cold start) | ✅ | ✅ | Alta |
| Sonido/vibración en alta importancia | ✅ | ✅ | Media |
| Permisos denegados = mensaje amigable | ✅ | ✅ | Media |
| App cerrada forzosamente | ✅ | ✅ | Media |

#### Dispositivos Recomendados para Testing
**Android**:
- Pixel (Android 14) - Comportamiento stock
- Samsung Galaxy (Android 13+) - Probar límite de alarmas
- Xiaomi/Huawei - Agresiva optimización de batería

**iOS**:
- iPhone físico (iOS 15+) - Simulador NO funciona
- Probar con notificaciones en segundo plano
- Verificar categorías de acciones

#### Casos Edge a Probar
1. **Límite iOS 64 notificaciones**: Crear 65+ recordatorios y verificar cuáles se pierden
2. **Reinicio del dispositivo**: Verificar que las notificaciones programadas persistan
3. **Cambio de zona horaria**: Verificar que los tiempos se ajusten correctamente
4. **Modo "No molestar"**: Verificar comportamiento con recordatorios de alta prioridad
5. **Batería baja**: Verificar que exact alarms funcionen en modo ahorro

## 📱 Consideraciones para Adultos Mayores

### Accesibilidad en Notificaciones
- **Texto grande**: Título máx 40 caracteres, descripción clara
- **Emojis como ayuda visual**: 💊 🏥 📞 ayudan a identificar rápidamente el tipo
- **Botones con texto, no solo iconos**: "✓ Listo" en lugar de solo "✓"
- **Contraste alto**: Asegurar legibilidad en diferentes condiciones de luz

### Manejo de Errores Amigable
```dart
// Ejemplo de mensaje cuando permisos están denegados
final permissionsGranted = await notificationService.requestPermissions();
if (!permissionsGranted) {
  // Mostrar diálogo amigable, no técnico
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Necesitamos tu permiso'),
      content: const Text(
        'Para recordarte tus medicamentos y citas, '
        'necesitamos permiso para enviarte notificaciones. '
        '¿Puedes activarlas en Ajustes?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Ahora no'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(ctx);
            openAppSettings(); // Abrir ajustes del sistema
          },
          child: const Text('Ir a Ajustes'),
        ),
      ],
    ),
  );
}
```

### Sonidos y Vibración
- **Medicamentos**: Sonido distintivo + vibración prolongada
- **Citas médicas**: Similar a medicamentos
- **Tareas generales**: Sonido suave, vibración corta
- **Notas**: Sin sonido (no tienen alarma)

---

*Plan creado: 25 de diciembre de 2025*  
*Actualizado: Agregadas consideraciones iOS vs Android*
