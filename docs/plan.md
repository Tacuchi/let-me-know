# 📋 Plan de Implementación - Let Me Know

**Versión**: 1.2  
**Fecha de inicio**: 11 de diciembre de 2025  
**Última actualización**: 12 de diciembre de 2025  
**Metodología**: Implementación atómica (una feature, probar, siguiente)

---

## 📊 Estado Actual (Auditoría 12/dic/2025)

### ✅ Completado
- [x] Estructura base de carpetas (Clean Architecture)
- [x] Entidad `Reminder` con `copyWith`, helpers (`isOverdue`, `isToday`, etc.)
- [x] Enums `ReminderType` y `ReminderStatus` con extensiones
- [x] Interfaz `ReminderRepository` (contrato)
- [x] UI de lista de recordatorios con filtros (Todos, Hoy, Pendientes, Completados)
- [x] Widgets reutilizables (`ReminderCard`, `AnimatedCounter`, `AnimatedMicButton`, etc.)
- [x] Sistema de navegación con `go_router` (shell + tabs)
- [x] Configuración de dependencias (`get_it`)
- [x] Tema y colores de la app (modo claro/oscuro)
- [x] Capa de infraestructura (Drift + SQLite)
- [x] Repositorio funcional (`ReminderRepositoryDriftImpl`) con CRUD completo
- [x] Cubits funcionales (`ReminderListCubit`, `ReminderSummaryCubit`, `HistoryCubit`)
- [x] Inyección de dependencias conectada
- [x] Grabación de voz con `speech_to_text` (transcripción en tiempo real)
- [x] Permisos Android/iOS configurados para micrófono
- [x] UX de grabación premium (estados visuales, animaciones)
- [x] Swipe actions en `ReminderCard` (completar/eliminar)
- [x] Marcar recordatorio como completado
- [x] Eliminar recordatorio

- [x] HomePage: Recordatorios próximos con datos reales
- [x] Búsqueda de recordatorios funcional (SQL LIKE)
- [x] Historial: Filtros por período y tipo de recordatorio
- [x] Settings: Tamaño de texto funcional con persistencia

### ⚠️ Parcialmente Implementado
- [ ] **Creación de recordatorio desde voz**: Transcripción se guarda como `description`, pero usa datos MOCK

### ❌ Pendiente (Pospuesto)
- [ ] Clasificación con IA (Gemini) - **POSPUESTO**
- [ ] Página de detalle de recordatorio
- [ ] Formulario de creación/edición manual
- [ ] Notificaciones locales

---

## 🎯 Sprint Actual: Funcionalidades Core

### 📍 Prioridad 1: HomePage - Recordatorios Próximos ✅ COMPLETADA

**Objetivo**: Mostrar los próximos recordatorios del día en la pantalla principal.

| # | Tarea | Estado |
|---|-------|--------|
| 1.1 | Crear método `getUpcoming(limit)` en repositorio | ✅ |
| 1.2 | Crear `watchUpcoming()` stream reactivo | ✅ |
| 1.3 | Agregar `upcomingReminders` al `ReminderSummaryCubit` | ✅ |
| 1.4 | Conectar `_buildUpcomingSection` con el cubit | ✅ |
| 1.5 | Mostrar lista de `ReminderCard` (max 5) | ✅ |
| 1.6 | "Ver todos" navega a pestaña Tareas | ✅ |
| 1.7 | Estado vacío solo si no hay recordatorios | ✅ |

**Dependencia agregada**: `rxdart: ^0.28.0` para combinar streams

---

### 📍 Prioridad 2: Búsqueda de Recordatorios ✅ COMPLETADA

**Objetivo**: Permitir buscar recordatorios por texto (título/descripción).

| # | Tarea | Estado |
|---|-------|--------|
| 2.1 | Crear método `search(query)` en repositorio (SQL LIKE) | ✅ |
| 2.2 | Agregar método `search()` al `ReminderListCubit` | ✅ |
| 2.3 | Crear estado de búsqueda en `ReminderListState` | ✅ |
| 2.4 | Bottom sheet con `DraggableScrollableSheet` | ✅ |
| 2.5 | Mostrar resultados de búsqueda en tiempo real | ✅ |
| 2.6 | Limpiar búsqueda al cerrar el sheet | ✅ |
| 2.7 | Estado vacío con mensaje personalizado | ✅ |

---

### 📍 Prioridad 3: Historial - Filtros ✅ COMPLETADA

**Objetivo**: Permitir filtrar el historial por período y tipo (UX accesible para adultos mayores).

| # | Tarea | Estado |
|---|-------|--------|
| 3.1 | Crear `HistoryPeriodFilter` enum (Todo, Esta semana, Este mes) | ✅ |
| 3.2 | Agregar filtro por tipo de recordatorio | ✅ |
| 3.3 | Actualizar `HistoryCubit` con métodos de filtrado | ✅ |
| 3.4 | UI de chips accesibles (min 48dp touch target) | ✅ |
| 3.5 | Botón "Limpiar filtros" cuando hay filtros activos | ✅ |
| 3.6 | Estado vacío diferenciado (sin resultados vs sin historial) | ✅ |

---

### 📍 Prioridad 4: Settings - Tamaño de Texto ✅ COMPLETADA

**Objetivo**: Permitir ajustar el tamaño de texto globalmente con persistencia.

| # | Tarea | Estado |
|---|-------|--------|
| 4.1 | Crear `TextSizeOption` enum (Normal, Grande, Muy grande) | ✅ |
| 4.2 | Agregar `shared_preferences` para persistencia | ✅ |
| 4.3 | Actualizar `app.dart` con `textScaleFactor` global | ✅ |
| 4.4 | Conectar picker de Settings con app state | ✅ |
| 4.5 | Preview de tamaño en el picker | ✅ |
| 4.6 | Persistir preferencias al reiniciar | ✅ |

**Dependencia agregada**: `shared_preferences: ^2.5.3`

---

### 📍 Prioridad 5: Notificaciones Locales ⏳ PENDIENTE

**Objetivo**: Alertar al usuario cuando llegue la hora del recordatorio.

| # | Tarea | Estado |
|---|-------|--------|
| 5.1 | Agregar `flutter_local_notifications` a pubspec.yaml | ⏳ |
| 5.2 | Configurar permisos iOS (`Info.plist`) | ⏳ |
| 5.3 | Configurar canal Android (`AndroidManifest.xml`) | ⏳ |
| 5.4 | Crear `NotificationService` | ⏳ |
| 5.5 | Inicializar servicio en `main.dart` | ⏳ |
| 5.6 | Programar notificación al guardar recordatorio | ⏳ |
| 5.7 | Cancelar notificación al completar/eliminar | ⏳ |
| 5.8 | Manejar tap en notificación (abrir app) | ⏳ |

**Archivos a crear/modificar**:
- `pubspec.yaml` (agregar dependencia)
- `ios/Runner/Info.plist` (permisos)
- `android/app/src/main/AndroidManifest.xml` (canal)
- `lib/services/notifications/notification_service.dart` (nuevo)
- `lib/di/injection_container.dart`
- `lib/main.dart`
- `lib/features/reminders/infrastructure/repositories/reminder_repository_drift_impl.dart`

---

## 📁 Estructura de Archivos Objetivo

```
lib/
├── services/
│   ├── speech_to_text/              ✅ Completado
│   │   ├── speech_to_text_service.dart
│   │   └── speech_to_text_service_impl.dart
│   │
│   └── notifications/               🎯 NUEVO
│       ├── notification_service.dart
│       └── notification_service_impl.dart
│
├── features/
│   └── reminders/
│       ├── domain/
│       │   └── repositories/
│       │       └── reminder_repository.dart   # + getUpcoming(), search()
│       │
│       ├── infrastructure/
│       │   └── repositories/
│       │       └── reminder_repository_drift_impl.dart  # + implementaciones
│       │
│       └── application/
│           └── cubit/
│               ├── reminder_list_cubit.dart    # + search()
│               ├── reminder_list_state.dart    # + searchQuery, searchResults
│               ├── reminder_summary_cubit.dart # + upcomingReminders
│               └── reminder_summary_state.dart # + upcomingReminders
```

---

## 📅 Estimación de Tiempo

| Funcionalidad | Estimación | Prioridad |
|---------------|------------|-----------|
| HomePage - Próximos recordatorios | 1-2 horas | 🔴 Alta |
| Búsqueda de recordatorios | 1-2 horas | 🔴 Alta |
| Notificaciones locales | 3-4 horas | 🔴 Alta |

**Total estimado**: ~6-8 horas

---

## 🔮 Backlog (Pospuesto)

| Funcionalidad | Fase Original | Notas |
|---------------|---------------|-------|
| Clasificación con IA (Gemini) | Fase 6 | Requiere API key y configuración |
| Página de detalle | Fase 4 | Después de notificaciones |
| Formulario de creación/edición | Fase 3 | Después de detalle |
| Acciones desde notificación | Fase 7+ | Completar, Posponer |

---

## 🐛 Bugs/Deuda Técnica

1. **VoiceRecording usa datos mock**: Transcripción no se procesa (título fijo)
2. **No hay confirmación antes de eliminar**: Swipe elimina directamente
3. **Búsquedas recientes hardcodeadas**: ['pastillas', 'doctor', 'compras']

---

## 📝 Notas Técnicas

### Notificaciones - Configuración Requerida

**iOS (Info.plist)**:
```xml
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

**Android (AndroidManifest.xml)**:
```xml
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.VIBRATE"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

### Búsqueda - Query SQL
```sql
SELECT * FROM reminders 
WHERE title LIKE '%query%' OR description LIKE '%query%'
ORDER BY scheduled_at ASC
```

---

*Documento actualizado: 12 de diciembre de 2025*
