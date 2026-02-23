# AGENTS.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Descripción
**Let Me Know** es una app Flutter de recordatorios por voz para adultos mayores. Usa un backend LLM (Spring Boot) para clasificar comandos de voz, crear recordatorios/notas, y responder consultas naturales como "¿Dónde dejé mis llaves?".

## Comandos de Desarrollo

```bash
flutter pub get                                          # Instalar dependencias
flutter run                                              # Ejecutar la app
flutter analyze                                          # Análisis estático
flutter test                                             # Ejecutar todos los tests
flutter test test/path/to/test_file.dart                 # Test específico
dart run build_runner build --delete-conflicting-outputs # Generar código Drift
```

## Arquitectura

Clean Architecture con estructura por features:

```
lib/
├── main.dart              # Entry point, inicializa DI, alarmas, locale
├── app.dart               # MaterialApp con tema y routing
├── core/
│   ├── database/drift/    # AppDatabase (tablas: reminders, groups, action_history)
│   ├── constants/         # Colores, tipografía, spacing
│   ├── extensions/        # date_extensions.dart (formattedTime, formattedDate)
│   └── widgets/           # ReminderCard, botones compartidos
├── di/injection_container.dart  # get_it service locator
├── features/
│   ├── reminders/         # CRUD recordatorios con filtros
│   ├── notes/             # Vista de notas (tipo=location)
│   ├── groups/            # Agrupación de recordatorios batch
│   ├── home/              # Dashboard principal
│   ├── alarm/             # Pantalla fullscreen cuando suena alarma
│   └── voice_recording/   # Interfaz unificada "Habla conmigo"
├── router/app_router.dart # go_router con StatefulShellRoute
└── services/
    ├── alarm/             # AlarmService (package:alarm) - alarmas infalibles
    ├── assistant/         # VoiceAssistantService + AssistantApiClient (backend)
    ├── speech_to_text/    # Reconocimiento de voz nativo
    ├── tts/               # Text-to-Speech para respuestas
    ├── query/             # Consultas locales (offline)
    └── transcription/     # Análisis offline con regex
```

### Stack Técnico
- **Estado**: flutter_bloc (Cubit + sealed class states)
- **DI**: get_it
- **Navegación**: go_router con StatefulShellRoute (bottom nav + FAB central)
- **DB Local**: Drift (SQLite)
- **Alarmas**: package:alarm (foreground service Android, background audio iOS)
- **Backend**: Spring Boot en `letmeknow-api` (LLM con Gemini)

### Flujo de Creación por Voz
1. Usuario habla → `SpeechToTextService` transcribe
2. Transcripción → `VoiceAssistantService.processCommand()` → Backend LLM
3. Backend clasifica y retorna `AssistantResponse` con acciones:
   - `CREATE`: Crear un recordatorio
   - `CREATE_BATCH`: Crear múltiples recordatorios (ej: medicamentos c/8h)
   - `DELETE_GROUP`: Eliminar grupo completo
   - `QUERY`: Responder consulta
4. App ejecuta acciones, programa alarmas via `AlarmService`, y responde con TTS

### Conceptos de Dominio

**Recordatorio** vs **Nota** (ambos en tabla `reminders`):
- **Recordatorio**: `type` = medication/task/appointment/etc., tiene `scheduledAt`, usa alarma
- **Nota**: `type` = location, `scheduledAt` = null, sin alarma. Guarda `object` + `location` para consultas

**Groups**: Recordatorios creados en batch (CREATE_BATCH) comparten `groupId`. Se eliminan juntos con DELETE_GROUP.

### Backend API (letmeknow-api)
Endpoint: `POST /api/assistant/process`
```json
{
  "transcription": "Recordarme tomar pastillas a las 3pm",
  "currentTime": "2025-01-15T10:30:00",
  "deviceTimezone": "America/Lima"
}
```
Respuesta incluye `action`, `message`, `reminders[]` con campos mapeables a entidad local.

### Alarmas Infalibles
- `AlarmService` usa `package:alarm` para alarmas que funcionan con app cerrada
- Requiere permisos: `SCHEDULE_EXACT_ALARM`, `ignoreBatteryOptimizations`, `notification`
- Pantalla fullscreen al sonar: `AlarmScreenPage` en `/alarm/:id`
- Config iOS: `AppDelegate.swift` con `SwiftAlarmPlugin.registerBackgroundTasks()`

### Regenerar código Drift
Después de cambios en `lib/core/database/drift/app_database.dart`:
```bash
dart run build_runner build --delete-conflicting-outputs
```

## Convenciones

- Archivos: `snake_case.dart`
- Estados Cubit: sealed classes (`ReminderListLoading`, `ReminderListLoaded`, `ReminderListError`)
- Imports: SDK → Flutter → externos → proyecto
- Idioma UI: Español (`es_ES`)
- Formato hora: Muestra segundos solo si ≠ 0

<!-- MULTIREPO_SPACE_MANAGED:START -->
## Multirepo Space Managed Init

This repo is linked to workspace `let-me-know` at `/Users/tacuchi/Git/personal-lab/projects/let-me-know`.
Repo alias in workspace: `let-me-know`.
Primary specialist: `repo-let-me-know`.

Tool compatibility:
- Codex: use workspace `AGENTS.md` and `.agents/repo-let-me-know.md`.
- Claude Code: use workspace `CLAUDE.md` and `.claude/agents/repo-let-me-know.md`.

Suggested verification commands:
- `flutter analyze`
- `flutter test`

<!-- MULTIREPO_SPACE_MANAGED:END -->
