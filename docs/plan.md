# 📋 Plan de Implementación - Let Me Know

**Versión**: 1.3  
**Fecha de inicio**: 11 de diciembre de 2025  
**Última actualización**: 24 de diciembre de 2025  
**Metodología**: Implementación atómica (una feature, probar, siguiente)

---

## 📊 Estado Actual (Auditoría 24/dic/2025)

### ✅ Completado
- [x] Estructura base de carpetas (Clean Architecture)
- [x] Entidad `Reminder` completa con `copyWith`, helpers (`isOverdue`, `isToday`, etc.)
- [x] Enums completos: `ReminderType`, `ReminderStatus`, `ReminderImportance`, `ReminderSource`
- [x] Interfaz `ReminderRepository` (contrato) con `search()`, `getUpcoming()`, `watchUpcoming()`
- [x] UI de lista de recordatorios con filtros (Todos, Hoy, Pendientes, Completados)
- [x] Widgets reutilizables (`ReminderCard`, `AnimatedCounter`, `AnimatedMicButton`, `GlassCard`, etc.)
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
- [x] **Creación de recordatorio desde voz**: TextParserService extrae título, tipo, fecha e importancia de la transcripción

### ❌ Pendiente
- [ ] **Consultas por voz y filtro de notas** - **PRIORIDAD ALTA** (ver `docs/plan-consultas-voz.md`)
- [ ] Notificaciones locales - **PRIORIDAD ALTA** (ver `docs/plan-notificaciones.md`)
- [ ] Clasificación con IA (Gemini) - **POSPUESTO** (ver `docs/backend-options.md`)
- [ ] Página de detalle de recordatorio
- [ ] Formulario de creación/edición manual

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

### 📍 Prioridad 5: Creación Real desde Voz ✅ COMPLETADA

**Objetivo**: Reemplazar datos MOCK con extracción básica de la transcripción.

| # | Tarea | Estado |
|---|-------|---------|
| 5.1 | Usar transcripción como título (truncar a 60 chars) | ✅ |
| 5.2 | Detectar palabras clave para tipo (pastilla→medicamento, doctor→cita, etc.) | ✅ |
| 5.3 | Extraer hora con regex básico ("a las 3", "mañana", etc.) | ✅ |
| 5.4 | Asignar importancia según tipo detectado | ✅ |
| 5.5 | Extraer object/location para notas de ubicación | ✅ |
| 5.6 | Mostrar preview editable antes de guardar | ⏳ (opcional, pospuesto) |

**Archivos creados/modificados**:
- `lib/services/text_parser/text_parser_service.dart` (interfaz + ParsedReminder)
- `lib/services/text_parser/text_parser_service_impl.dart` (implementación)
- `lib/features/voice_recording/presentation/pages/voice_recording_page.dart`
- `lib/di/injection_container.dart`

---

### 📍 Prioridad 6: Consultas por Voz y Filtro de Notas ⏳ PENDIENTE

**Objetivo**: Permitir consultar notas por voz y separar notas de recordatorios en la UI.

**Plan detallado**: Ver `docs/plan-consultas-voz.md`

| # | Tarea | Estado |
|---|-------|---------|
| 6.1 | Agregar filtro "Notas" en ReminderListPage | ⏳ |
| 6.2 | Excluir notas del filtro "Pendientes" | ⏳ |
| 6.3 | Crear QueryService para procesar consultas | ⏳ |
| 6.4 | UI de consulta por voz (reutilizar grabación) | ⏳ |
| 6.5 | Alertas proactivas de recordatorios próximos | ⏳ |

---

### 📍 Prioridad 7: Notificaciones Locales ⏳ PENDIENTE

**Objetivo**: Alertar al usuario cuando llegue la hora del recordatorio.

| # | Tarea | Estado |
|---|-------|--------|
| 7.1 | Agregar `flutter_local_notifications` a pubspec.yaml | ⏳ |
| 7.2 | Configurar permisos iOS (`Info.plist`) | ⏳ |
| 7.3 | Configurar canal Android (`AndroidManifest.xml`) | ⏳ |
| 7.4 | Crear `NotificationService` | ⏳ |
| 7.5 | Inicializar servicio en `main.dart` | ⏳ |
| 7.6 | Programar notificación al guardar recordatorio | ⏳ |
| 7.7 | Cancelar notificación al completar/eliminar | ⏳ |
| 7.8 | Manejar tap en notificación (abrir app) | ⏳ |

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
| ~~HomePage - Próximos recordatorios~~ | ~~1-2 horas~~ | ✅ Completada |
| ~~Búsqueda de recordatorios~~ | ~~1-2 horas~~ | ✅ Completada |
| ~~Historial - Filtros~~ | ~~1-2 horas~~ | ✅ Completada |
| ~~Settings - Tamaño de texto~~ | ~~1-2 horas~~ | ✅ Completada |
| ~~Creación real desde voz~~ | ~~2-3 horas~~ | ✅ Completada |
| **Consultas por voz y filtro notas** | 4-6 horas | 🔴 Alta |
| **Notificaciones locales** | 3-4 horas | 🔴 Alta |
| Clasificación IA (Gemini) | 4-6 horas | 🟡 Pospuesto |
| Formulario edición manual | 2-3 horas | 🟢 Baja |

**Total pendiente**: ~9-13 horas

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

1. ~~**🔴 CRÍTICO - VoiceRecording usa datos MOCK**~~: ✅ RESUELTO - TextParserService extrae datos reales

2. **No hay confirmación antes de eliminar**: Swipe elimina directamente
3. **Búsquedas recientes hardcodeadas**: `['pastillas', 'doctor', 'compras']`
4. **Notas mezcladas con recordatorios**: Filtro "Pendientes" incluye notas de ubicación (ver plan-consultas-voz.md)

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
