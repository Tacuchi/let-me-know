# Funcionalidades

## Características principales

- **Voz primero** — Crea recordatorios hablando naturalmente en español
- **IA inteligente** — Detecta patrones, sugiere recurrencias y responde preguntas
- **Notas consultables** — "¿Dónde dejé mis llaves?" → responde por voz con contexto
- **Alertas inteligentes** — Repetición automática para medicamentos, citas y tareas
- **Accesible** — Interfaz grande, clara, con feedback auditivo para adultos mayores
- **Multi-turno** — Conversaciones acumulativas: varios recordatorios en una sola sesión
- **Dual input** — Voz o texto, ambos procesados por el mismo pipeline de IA

## Casos de uso

```
"Tomar pastillas a las 3pm"     → Recordatorio con notificación y alarma
"Tomar pastillas a las 9pm"     → Detecta patrón → sugiere recurrencia diaria
"Dejé llaves en la cómoda"      → Nota guardada (sin alarma)
"¿Dónde dejé mis llaves?"       → "En la cómoda de la habitación" (respuesta por voz)
"Cita con el doctor el viernes" → Recordatorio tipo appointment con alta importancia
"Losartán cada 12 horas x 30 d" → Preview de batch → confirma → crea 60 recordatorios
```

## Pantallas

### 1. Chat de Voz (`/` — pantalla principal)

Pantalla principal y punto de entrada de la app. Interfaz conversacional que permite
crear recordatorios, guardar notas y hacer consultas mediante voz o texto.

**Ruta:** `/` (home)
**Archivo:** `features/voice_recording/presentation/pages/voice_recording_page.dart`
**Estado:** `VoiceChatCubit` → `VoiceChatState` (sealed class)

**Funcionalidades:**
- Grabación de voz con transcripción en tiempo real (indicador de ondas sonoras + texto live)
- Envío de texto escrito como alternativa a la voz
- Chat multi-turno: los mensajes se acumulan en el historial de la sesión
- Procesamiento por backend IA que clasifica la intención (crear recordatorio, crear nota, consultar, completar, etc.)
- Cards de preview inline para batches de recordatorios recurrentes (ej. medicamentos x30 días)
- Cards de creación pendiente para recordatorios/notas individuales
- Botón "Finalizar" que guarda todos los items pendientes en la DB con progreso visual
- Botón "Nuevo chat" para reiniciar la sesión (con confirmación si hay pendientes)
- Chips de ejemplo interactivos en estado idle ("Recordarme tomar pastillas a las 3pm")
- Panel de ayuda con tips de uso (bottom sheet)
- TTS automático en respuestas del sistema (toca un mensaje para re-escucharlo)
- Retry en mensajes con error

**Fases del micrófono (`VoiceChatPhase`):**
1. `idle` — Esperando input del usuario
2. `recording` — Grabando voz, mostrando transcripción en tiempo real
3. `processing` — LLM procesando la transcripción (indicador "Pensando...")

**Flujo de creación:**
```
Usuario habla/escribe → STT transcribe → LLM clasifica intención
  ├─ createReminder → PendingCreation card en el chat
  ├─ createNote     → PendingCreation card (tipo location, sin alarma)
  ├─ createBatch    → PendingPreview card (resumen del batch)
  ├─ query          → Respuesta hablada por TTS
  ├─ completeTask   → Acción ejecutada inline
  └─ error          → Mensaje de error con opción de retry

Usuario toca "Finalizar" → VoiceChatSaving (progreso) → VoiceChatCompleted → reset
```

**Tipos de mensaje (`ChatMessageType`):**
- `userMessage` — Mensaje del usuario (voz o texto)
- `systemResponse` — Respuesta del asistente con posible acción adjunta
- `systemError` — Error de procesamiento (con retry)
- `systemAction` — Acción ejecutada inline (completar, eliminar)

### 2. Lista de Recordatorios (`/reminders`)

Vista general de todos los recordatorios guardados con filtros, búsqueda y
agrupación por recurrencia.

**Ruta:** `/reminders`
**Archivo:** `features/reminders/presentation/pages/reminder_list_page.dart`
**Estado:** `ReminderListCubit` → `ReminderListState`

**Funcionalidades:**
- Filtros por chip horizontal: Todos, Pendientes, Hoy, Completados
- Resumen del día (filtro "Hoy"): fecha, contadores animados de pendientes/vencidos/completados
- Búsqueda de recordatorios (bottom sheet con campo de texto y resultados en tiempo real)
- Agrupación automática por `recurrenceGroupId` (ej. "Tratamiento Losartán")
  - Sección colapsable (`ExpansionTile`) con ícono, label editable y contador
  - Edición del nombre de grupo via bottom sheet
- Recordatorios sin grupo listados individualmente
- Cada recordatorio usa `ReminderCard` con:
  - Swipe para completar (→) o eliminar (←)
  - Tap para ir al detalle
  - Badge de tipo, hora programada, indicador de importancia
- SnackBar con acción "Deshacer" al completar o eliminar
- Estado vacío contextual según filtro activo

### 3. Detalle de Recordatorio (`/reminders/:id`)

Vista completa de un recordatorio individual con countdown en tiempo real,
TTS y acciones.

**Ruta:** `/reminders/:id`
**Archivo:** `features/reminders/presentation/pages/reminder_detail_page.dart`
**Estado:** `ReminderDetailCubit` → `ReminderDetailState`

**Funcionalidades:**
- Card de cabecera: chip de tipo (con color), título grande, badge de importancia
- Card de fecha/hora (para recordatorios):
  - Fecha y hora programada en formato grande
  - Countdown en tiempo real ("Faltan 2h 15min") actualizado cada segundo
  - Indicador "Recordatorio vencido" si ya pasó la hora
  - Badge "Sonando" si la alarma está activa (escucha stream de alarmas)
- Card de ubicación (para notas tipo location):
  - Objeto guardado (ej. "llaves")
  - Ubicación (ej. "cómoda de la habitación")
- Card de descripción con TTS:
  - Toca la card para escuchar el recordatorio completo
  - Indicador visual "Escuchando..." mientras habla
  - Incluye título, descripción, fecha y datos de ubicación en la lectura
- Botones de acción (tamaño grande, accesible):
  - **Completar** — Marca como completado, detiene alarma si suena
  - **Recordar más tarde** — Posponer con opciones: 5min, 15min, 1h, mañana
  - **Editar** — (Próximamente)
  - **Eliminar** — Con diálogo de confirmación
- Banner de "Completado" si ya fue marcado

### 4. Pantalla de Alarma (`/alarm/:id`)

Pantalla fullscreen que se muestra cuando se dispara un recordatorio de alta
importancia. Diseñada para máxima accesibilidad con adultos mayores.

**Ruta:** `/alarm/:id`
**Archivo:** `features/alarm/presentation/pages/alarm_screen_page.dart`

**Funcionalidades:**
- Pantalla completa sin AppBar (inmersiva)
- Ícono animado con pulso continuo (emoji del tipo de recordatorio)
- Título del recordatorio en texto grande (28px, bold)
- Badge de tipo de recordatorio
- Texto "¡Es hora!" para recordatorios con fecha
- Botones grandes y accesibles:
  - **✓ Listo** — Completa el recordatorio y detiene la alarma (alto: 72px)
  - **⏰ 5 min / ⏰ 15 min** — Posponer (alto: 64px)
- Vibración fuerte al abrir (`HapticFeedback.heavyImpact`)
- Auto-cierre después de 5 minutos sin interacción
- Botón de cerrar (X) en esquina superior derecha

### 5. Configuración (`/settings`)

Ajustes de la aplicación organizados en secciones con cards.

**Ruta:** `/settings`
**Archivo:** `features/settings/presentation/pages/settings_page.dart`

**Secciones:**

**Apariencia:**
- Tema: Claro / Auto / Oscuro (selector visual con iconos)
- Tamaño de texto: picker con preview en vivo por cada opción (bottom sheet)

**Experiencia:**
- Vibración: toggle para feedback háptico
- Sonidos: toggle para efectos de audio del sistema

**Voz:**
- Voz de respuesta: selector de voces en español disponibles (toca para escuchar muestra, long-press para confirmar)
- Velocidad de voz: slider de 0.2 a 0.8 con labels (Muy lenta → Muy rápida) y botón de prueba

**Datos:**
- Borrar todos los recordatorios (con confirmación de doble paso)
- Permisos de la app (abre configuración del sistema)

**Acerca de:**
- Versión, Tutorial (próximamente), Soporte (próximamente)

## Navegación

### Estructura

La app usa `StatefulShellRoute.indexedStack` de go_router con un drawer lateral
como menú principal (no bottom navigation).

```
MainShell (Scaffold + Drawer)
├── Rama 0: Chat de Voz        /
├── Rama 1: Recordatorios       /reminders
└── Rama 2: Configuración       /settings

Rutas fuera del shell (sin drawer):
├── Detalle de recordatorio     /reminders/:id
└── Alarma fullscreen           /alarm/:id
```

### Drawer lateral

Opciones: Chat, Recordatorios, Ajustes. Se abre desde el ícono de perfil
en el AppBar de cada pantalla principal. Incluye feedback háptico al cambiar.

## Tipos de recordatorio

- `medication` — Medicamentos con recurrencia
- `appointment` — Citas médicas, reuniones
- `call` — Llamadas pendientes
- `shopping` — Lista de compras
- `task` — Tareas generales
- `event` — Eventos con fecha/hora
- `location` — Notas de ubicación (sin alarma, consultables por voz)

## Niveles de importancia

- **high** — Alarma fullscreen con sonido, vibración y pulso animado
- **medium** — Notificación con sonido
- **low** — Notificación silenciosa
- **info** — Solo nota, sin notificación

## Servicios

### VoiceAssistantService
Procesa transcripciones via backend LLM (`letmeknow-api.tacuchi.net`).
Dos endpoints: `process` (crear items) y `preview` (previsualizar batches).
Soporta historial de conversación y items de sesión para contexto multi-turno.

### SpeechToTextService
Captura audio del micrófono y transcribe en tiempo real usando `speech_to_text`.
Locale: `es_MX`. Emite callbacks `onResult(text, isFinal)` y `onError`.

### TtsService
Síntesis de voz con `flutter_tts`. Configurable: voz (picker de voces en español),
velocidad (0.2–0.8). Se usa para leer respuestas del asistente y descripción de recordatorios.

### AlarmService
Gestiona alarmas con `alarm` (foreground service). Expone `ringingStream` para
detectar alarmas activas en tiempo real. Métodos: `stopAlarm`, `isRingingForReminder`.

### NotificationService
Notificaciones locales con `flutter_local_notifications`. Programa notificaciones
según importancia del recordatorio.

### FeedbackService
Feedback háptico y sonoro centralizado. Niveles: light, medium, heavy, success,
error, selection, click. Configurable desde Settings (vibración y sonidos on/off).

## Modelo de datos

### Reminder
Entidad principal con los siguientes campos clave:
- `id`, `title`, `description`
- `scheduledAt` — null para notas sin alarma
- `type` (ReminderType), `status` (pending/completed/overdue), `importance`
- `source` — manual o voice
- `object`, `location` — para notas tipo ubicación
- `notificationId`, `snoozedUntil`, `lastNotifiedAt`
- `recurrenceGroupId`, `recurrenceRule` — para agrupación de recurrencias
- Computed: `isNote`, `isOverdue`, `isUpcoming`, `isToday`, `effectiveAlarmId`

### ReminderGroup
Agrupación de recordatorios recurrentes con label editable.

### PendingCreation
Recordatorio/nota parseado por el LLM pero **no guardado** aún. Vive en memoria
durante la sesión de chat. Se persiste al "Finalizar".

### PendingPreview
Preview de un batch de recordatorios recurrentes. Contiene resumen, grupo,
cantidad estimada, frecuencia, rango de fechas y la transcripción original
para re-enviar a `/process` al confirmar.

## Stack tecnológico

- **Frontend:** Flutter 3.41+ / Dart 3.11+
- **Estado:** flutter_bloc (Cubits con sealed classes)
- **Base de datos local:** Drift (SQLite)
- **Backend IA:** API propia (`letmeknow-api.tacuchi.net`)
- **Voz → Texto:** speech_to_text
- **Texto → Voz:** flutter_tts
- **Alarmas:** alarm (foreground service)
- **Notificaciones:** flutter_local_notifications
- **Navegación:** go_router (StatefulShellRoute)
- **DI:** GetIt

## Arquitectura

Clean Architecture con módulos por feature:

```
lib/
├── core/           # Shared: config, database, theme, widgets, extensions
├── di/             # GetIt (inyección de dependencias)
├── features/
│   ├── alarm/      # Pantalla de alarma fullscreen
│   ├── groups/     # Agrupación de recordatorios recurrentes
│   ├── reminders/  # CRUD + detalle + lista de recordatorios
│   ├── settings/   # Configuración (tema, voz, datos)
│   └── voice_recording/  # Chat por voz con IA (pantalla principal)
├── router/         # GoRouter (navegación + shell con drawer)
└── services/       # Alarma, asistente IA, notificaciones, STT, TTS, query
```

Cada feature sigue la estructura de capas:
- **domain/** — Entidades y contratos (Dart puro)
- **infrastructure/** — Implementaciones (Drift, HTTP)
- **application/** — Cubits (lógica de estado)
- **presentation/** — Páginas y widgets (Flutter UI)

## Roadmap

- [x] Estructura base (Clean Architecture)
- [x] Navegación con go_router (drawer lateral)
- [x] Grabación y transcripción de voz
- [x] Integración con backend IA
- [x] Creación de recordatorios por voz
- [x] Chat multi-turno con acumulación de items
- [x] Input dual (voz y texto)
- [x] Detección de patrones y recurrencias
- [x] Preview de batches recurrentes
- [x] Consultas por voz (notas de ubicación)
- [x] Alarmas con foreground service
- [x] Pantalla de alarma fullscreen accesible
- [x] Manejo de permisos OEM (Xiaomi, Huawei, OPPO)
- [x] Agrupación de recordatorios con label editable
- [x] Vista previa de recordatorios en chat
- [x] Countdown en tiempo real en detalle
- [x] TTS configurable (voz, velocidad)
- [x] Tema claro/oscuro/auto + tamaño de texto
- [x] Feedback háptico y sonoro configurable
- [ ] Edición de recordatorios existentes
- [ ] Tests unitarios y de integración
- [ ] CI/CD con GitHub Actions
- [ ] Publicación en Play Store
