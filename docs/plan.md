# 📋 Plan de Implementación - Let Me Know

**Versión**: 1.0  
**Fecha de inicio**: 11 de diciembre de 2025  
**Metodología**: Implementación atómica (una feature, probar, siguiente)

---

## 📊 Estado Actual

### ✅ Completado
- [x] Estructura base de carpetas (Clean Architecture)
- [x] Entidad `Reminder` con `copyWith`, helpers (`isOverdue`, `isToday`, etc.)
- [x] Enums `ReminderType` y `ReminderStatus` con extensiones
- [x] Interfaz `ReminderRepository` (contrato)
- [x] UI de lista de recordatorios (páginas base)
- [x] Widgets reutilizables (`ReminderCard`, `AnimatedCounter`, etc.)
- [x] Sistema de navegación con `go_router`
- [x] Configuración de dependencias base (`get_it`)
- [x] Tema y colores de la app
- [x] Dependencias en `pubspec.yaml`

### ❌ Pendiente
- [ ] Capa de infraestructura (modelo + base de datos SQLite)
- [ ] Implementación del repositorio
- [ ] Cubits para gestión de estado
- [ ] Inyección de dependencias funcional
- [ ] Formulario de creación/edición de recordatorios
- [ ] Funcionalidad de grabación de voz
- [ ] Integración con APIs de IA (Whisper + Gemini)
- [ ] Notificaciones locales

---

## 🎯 Fases de Implementación

### Fase 1: Base de Datos y Repositorio (Prioridad Alta)
**Objetivo**: Poder guardar, leer, actualizar y eliminar recordatorios en SQLite.

| # | Tarea | Archivo(s) | Estado |
|---|-------|-----------|--------|
| 1.1 | Crear `ReminderModel` (mapeo DB ↔ Entity) | `lib/features/reminders/infrastructure/models/reminder_model.dart` | ⏳ |
| 1.2 | Crear `DatabaseHelper` (inicialización SQLite) | `lib/core/database/database_helper.dart` | ⏳ |
| 1.3 | Crear `LocalReminderDataSource` | `lib/features/reminders/infrastructure/datasources/local_reminder_datasource.dart` | ⏳ |
| 1.4 | Implementar `ReminderRepositoryImpl` | `lib/features/reminders/infrastructure/repositories/reminder_repository_impl.dart` | ⏳ |
| 1.5 | **Probar**: CRUD básico con datos de prueba | Test manual en la app | ⏳ |

**Criterios de éxito Fase 1**:
- [ ] Puedo guardar un recordatorio en SQLite
- [ ] Puedo recuperar todos los recordatorios
- [ ] Puedo actualizar un recordatorio
- [ ] Puedo eliminar un recordatorio
- [ ] Los datos persisten después de reiniciar la app

---

### Fase 2: Gestión de Estado (Cubit)
**Objetivo**: Conectar la UI con el repositorio mediante Cubits.

| # | Tarea | Archivo(s) | Estado |
|---|-------|-----------|--------|
| 2.1 | Crear estados del Cubit (`sealed class`) | `lib/features/reminders/application/cubit/reminder_list_state.dart` | ⏳ |
| 2.2 | Crear `ReminderListCubit` | `lib/features/reminders/application/cubit/reminder_list_cubit.dart` | ⏳ |
| 2.3 | Configurar inyección de dependencias | `lib/di/injection_container.dart` | ⏳ |
| 2.4 | Conectar `ReminderListPage` con Cubit | `lib/features/reminders/presentation/pages/reminder_list_page.dart` | ⏳ |
| 2.5 | **Probar**: La lista muestra recordatorios de la BD | Test manual en la app | ⏳ |

**Criterios de éxito Fase 2**:
- [ ] La página de lista carga recordatorios automáticamente
- [ ] Se muestra estado de carga (loading)
- [ ] Se muestra estado vacío cuando no hay datos
- [ ] Se muestra mensaje de error si falla
- [ ] Los filtros funcionan (Todos, Hoy, Pendientes, Completados)

---

### Fase 3: Creación Manual de Recordatorios
**Objetivo**: Formulario para crear recordatorios manualmente (sin voz).

| # | Tarea | Archivo(s) | Estado |
|---|-------|-----------|--------|
| 3.1 | Crear página de creación/edición | `lib/features/reminders/presentation/pages/reminder_form_page.dart` | ⏳ |
| 3.2 | Crear Cubit para el formulario | `lib/features/reminders/application/cubit/reminder_form_cubit.dart` | ⏳ |
| 3.3 | Agregar navegación al formulario | `lib/router/app_router.dart` | ⏳ |
| 3.4 | Conectar FAB de home para crear recordatorio | `lib/features/home/presentation/pages/home_page.dart` | ⏳ |
| 3.5 | **Probar**: Crear, editar y ver recordatorios | Test manual en la app | ⏳ |

**Criterios de éxito Fase 3**:
- [ ] Puedo abrir formulario desde el FAB
- [ ] Puedo seleccionar tipo, fecha, hora
- [ ] Puedo guardar y ver el recordatorio en la lista
- [ ] Puedo editar un recordatorio existente
- [ ] Validaciones funcionan (título requerido, fecha futura, etc.)

---

### Fase 4: Acciones sobre Recordatorios
**Objetivo**: Completar, eliminar, posponer recordatorios.

| # | Tarea | Archivo(s) | Estado |
|---|-------|-----------|--------|
| 4.1 | Implementar marcar como completado | Cubit + Repository | ⏳ |
| 4.2 | Implementar eliminar con confirmación | Cubit + UI | ⏳ |
| 4.3 | Implementar swipe actions en la lista | `reminder_list_page.dart` | ⏳ |
| 4.4 | Agregar página de detalle de recordatorio | `reminder_detail_page.dart` | ⏳ |
| 4.5 | **Probar**: Flujo completo de gestión | Test manual en la app | ⏳ |

**Criterios de éxito Fase 4**:
- [ ] Swipe derecha = completar recordatorio
- [ ] Swipe izquierda = eliminar (con confirmación)
- [ ] Tap = ver detalle
- [ ] Botón editar en detalle funciona
- [ ] Estados visuales se actualizan correctamente

---

### Fase 5: Grabación de Voz
**Objetivo**: Grabar audio y transcribir usando el dispositivo o Whisper API.

| # | Tarea | Archivo(s) | Estado |
|---|-------|-----------|--------|
| 5.1 | Agregar dependencias de audio (`record`) | `pubspec.yaml` | ⏳ |
| 5.2 | Crear servicio de grabación | `lib/services/audio/audio_recorder_service.dart` | ⏳ |
| 5.3 | Implementar UI de grabación | `lib/features/voice_recording/presentation/pages/voice_recording_page.dart` | ⏳ |
| 5.4 | Crear servicio de transcripción (STT) | `lib/services/speech_to_text/stt_service.dart` | ⏳ |
| 5.5 | **Probar**: Grabar y transcribir audio | Test manual en la app | ⏳ |

**Criterios de éxito Fase 5**:
- [ ] Permisos de micrófono se solicitan correctamente
- [ ] Se puede iniciar/detener grabación
- [ ] Feedback visual durante grabación (ondas, tiempo)
- [ ] Audio se transcribe a texto
- [ ] Transcripción se muestra al usuario

---

### Fase 6: Clasificación con IA
**Objetivo**: Usar LLM para clasificar el recordatorio automáticamente.

| # | Tarea | Archivo(s) | Estado |
|---|-------|-----------|--------|
| 6.1 | Configurar API de Gemini | `.env` + `lib/core/config/api_config.dart` | ⏳ |
| 6.2 | Crear servicio de clasificación | `lib/services/ai_classification/ai_service.dart` | ⏳ |
| 6.3 | Implementar prompt de clasificación | `lib/services/ai_classification/prompts.dart` | ⏳ |
| 6.4 | Integrar clasificación en flujo de voz | Conectar servicios | ⏳ |
| 6.5 | **Probar**: Flujo completo voz → clasificación → guardar | Test manual en la app | ⏳ |

**Criterios de éxito Fase 6**:
- [ ] Transcripción se envía a Gemini
- [ ] Se recibe clasificación (tipo, título, fecha)
- [ ] Usuario puede revisar antes de guardar
- [ ] Fallback a clasificación manual si IA falla

---

### Fase 7: Notificaciones Locales
**Objetivo**: Alertar al usuario cuando llegue la hora del recordatorio.

| # | Tarea | Archivo(s) | Estado |
|---|-------|-----------|--------|
| 7.1 | Agregar `flutter_local_notifications` | `pubspec.yaml` | ⏳ |
| 7.2 | Configurar permisos iOS/Android | `Info.plist`, `AndroidManifest.xml` | ⏳ |
| 7.3 | Crear servicio de notificaciones | `lib/services/notifications/notification_service.dart` | ⏳ |
| 7.4 | Programar notificación al guardar recordatorio | Integrar en repository | ⏳ |
| 7.5 | **Probar**: Notificación aparece a la hora programada | Test manual en la app | ⏳ |

**Criterios de éxito Fase 7**:
- [ ] Notificación aparece a la hora correcta
- [ ] Acciones desde notificación (Completar, Posponer)
- [ ] Sonido configurable
- [ ] Funciona con app cerrada

---

## 🚀 Próximo Paso

**Iniciar con Fase 1.1**: Crear `ReminderModel`

Este modelo convierte entre la entidad de dominio (`Reminder`) y el mapa de la base de datos SQLite.

---

## 📝 Notas de Implementación

### Convenciones
- Cada fase debe completarse y probarse antes de pasar a la siguiente
- Commits frecuentes con mensajes descriptivos
- Tests unitarios para lógica crítica (Cubits, Repositorios)

### Estructura de Archivos por Fase

```
lib/
├── features/
│   └── reminders/
│       ├── domain/                 # ✅ Completado
│       │   ├── entities/
│       │   └── repositories/
│       │
│       ├── infrastructure/         # 📍 Fase 1
│       │   ├── models/
│       │   │   └── reminder_model.dart
│       │   ├── datasources/
│       │   │   └── local_reminder_datasource.dart
│       │   └── repositories/
│       │       └── reminder_repository_impl.dart
│       │
│       ├── application/            # 📍 Fase 2-3
│       │   └── cubit/
│       │       ├── reminder_list_cubit.dart
│       │       ├── reminder_list_state.dart
│       │       └── reminder_form_cubit.dart
│       │
│       └── presentation/           # ✅ Base + 📍 Fase 3-4
│           ├── pages/
│           │   ├── reminder_list_page.dart
│           │   ├── reminder_form_page.dart
│           │   └── reminder_detail_page.dart
│           └── widgets/
│
├── core/
│   └── database/                   # 📍 Fase 1
│       └── database_helper.dart
│
└── services/                       # 📍 Fase 5-7
    ├── audio/
    ├── speech_to_text/
    ├── ai_classification/
    └── notifications/
```

---

## 📅 Estimación de Tiempo

| Fase | Estimación | Acumulado |
|------|------------|-----------|
| Fase 1: Base de Datos | 2-3 horas | 3 horas |
| Fase 2: Cubits | 2 horas | 5 horas |
| Fase 3: Formulario | 2-3 horas | 8 horas |
| Fase 4: Acciones | 2 horas | 10 horas |
| Fase 5: Voz | 3-4 horas | 14 horas |
| Fase 6: IA | 2-3 horas | 17 horas |
| Fase 7: Notificaciones | 2-3 horas | 20 horas |

**Total estimado**: ~20 horas de desarrollo

---

*Documento actualizado: 11 de diciembre de 2025*
