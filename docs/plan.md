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
- [x] **Capa de infraestructura (Drift + SQLite)**
- [x] **Implementación del repositorio (`ReminderRepositoryDriftImpl`)**
- [x] **Cubits para gestión de estado (`ReminderListCubit`, `ReminderSummaryCubit`)**
- [x] **Inyección de dependencias funcional**
- [x] **Grabación y transcripción de voz real (`speech_to_text`)**
- [x] **Permisos Android/iOS configurados para micrófono**
- [x] **UX de grabación premium (transcripción en tiempo real, estados claros)**
- [x] **Creación de recordatorio mock desde voz (datos fijos)**

### ⏳ En Progreso
- [ ] **Clasificación inteligente con IA** (Fase 6 - actualmente usa datos mock)
  - Parsear transcripción → extraer título, tipo, fecha, hora

### ❌ Pendiente (por Funcionalidad según docs/requerimientos-funcionales.md)

| Funcionalidad | Detalle | Fase |
|---------------|---------|------|
| **F1: Creación por voz** | IA extrae título/tipo/fecha de transcripción | 6 |
| **F2: Patrones recurrentes** | Detectar y sugerir recordatorios repetidos | Futuro |
| **F3: Notas de ubicación** | Guardar y consultar "¿dónde dejé X?" | Futuro |
| **F4: Notificaciones** | Alertas a la hora programada | 7 |
| **F5: Accesibilidad** | Texto configurable, guías de voz | Parcial ✓ |

### 📊 Comparación con Requerimientos

| Requerimiento (docs/) | Estado Actual |
|-----------------------|---------------|
| Grabar con un toque | ✅ Implementado |
| Transcribir < 3s | ✅ Tiempo real |
| IA extrae título/tipo/fecha | ❌ Usa mock |
| Usuario edita antes de confirmar | ⚠️ No editable aún |
| Programar notificación | ❌ Fase 7 |

---

## 🎯 Fases de Implementación

### Fase 1: Base de Datos y Repositorio ✅ COMPLETADA
**Objetivo**: Poder guardar, leer, actualizar y eliminar recordatorios en SQLite.

| # | Tarea | Archivo(s) | Estado |
|---|-------|-----------|--------|
| 1.1 | Crear `ReminderModel` (mapeo DB ↔ Entity) | Drift genera modelos | ✅ |
| 1.2 | Crear `DatabaseHelper` (inicialización SQLite) | `lib/core/database/drift/app_database.dart` | ✅ |
| 1.3 | Crear `LocalReminderDataSource` | Integrado en Drift | ✅ |
| 1.4 | Implementar `ReminderRepositoryImpl` | `lib/features/reminders/infrastructure/repositories/reminder_repository_drift_impl.dart` | ✅ |
| 1.5 | **Probar**: CRUD básico con datos de prueba | Test manual en la app | ✅ |

**Criterios de éxito Fase 1**: ✅ TODOS CUMPLIDOS

---

### Fase 2: Gestión de Estado (Cubit) ✅ COMPLETADA
**Objetivo**: Conectar la UI con el repositorio mediante Cubits.

| # | Tarea | Archivo(s) | Estado |
|---|-------|-----------|--------|
| 2.1 | Crear estados del Cubit (`sealed class`) | `lib/features/reminders/application/cubit/reminder_list_state.dart` | ✅ |
| 2.2 | Crear `ReminderListCubit` | `lib/features/reminders/application/cubit/reminder_list_cubit.dart` | ✅ |
| 2.3 | Configurar inyección de dependencias | `lib/di/injection_container.dart` | ✅ |
| 2.4 | Conectar `ReminderListPage` con Cubit | `lib/features/reminders/presentation/pages/reminder_list_page.dart` | ✅ |
| 2.5 | **Probar**: La lista muestra recordatorios de la BD | Test manual en la app | ✅ |

**Criterios de éxito Fase 2**: ✅ TODOS CUMPLIDOS

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

### Fase 5: Grabación de Voz ✅ COMPLETADA
**Objetivo**: Grabar audio y transcribir usando el dispositivo o Whisper API.

| # | Tarea | Archivo(s) | Estado |
|---|-------|-----------|--------|
| 5.1 | Agregar dependencias de audio (`speech_to_text`) | `pubspec.yaml` | ✅ |
| 5.2 | Crear servicio de transcripción (STT) | `lib/services/speech_to_text/speech_to_text_service.dart` | ✅ |
| 5.3 | Implementar UI de grabación | `lib/features/voice_recording/presentation/pages/voice_recording_page.dart` | ✅ |
| 5.4 | Integrar STT con UI | Conectados | ✅ |
| 5.5 | **Probar**: Grabar y transcribir audio | Test manual en dispositivo real | ✅ |

**Criterios de éxito Fase 5**: ✅ TODOS CUMPLIDOS
- [x] Permisos de micrófono se solicitan correctamente (iOS/Android)
- [x] Se puede iniciar/detener grabación
- [x] Feedback visual durante grabación (ondas, animaciones)
- [x] Audio se transcribe a texto (reconocimiento nativo en español)
- [x] Transcripción se muestra al usuario
- [x] Recordatorio se guarda en BD al confirmar

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

**Fase 6**: Clasificación con IA (Gemini) para extraer automáticamente título, tipo, fecha y hora del recordatorio.

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

*Documento actualizado: 12 de diciembre de 2025*
