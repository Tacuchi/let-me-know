# Funcionalidades

## Características principales

| Funcionalidad | Descripción |
|---------------|-------------|
| **Voz primero** | Crea recordatorios hablando naturalmente en español |
| **IA inteligente** | Detecta patrones, sugiere recurrencias y responde preguntas |
| **Notas consultables** | "¿Dónde dejé mis llaves?" — responde por voz con contexto |
| **Alertas inteligentes** | Repetición automática para medicamentos, citas y tareas |
| **Accesible** | Interfaz grande, clara, con feedback auditivo para adultos mayores |

## Casos de uso

```
"Tomar pastillas a las 3pm"     → Recordatorio con notificación y alarma
"Tomar pastillas a las 9pm"     → Detecta patrón → sugiere recurrencia diaria
"Dejé llaves en la cómoda"      → Nota guardada (sin alarma)
"¿Dónde dejé mis llaves?"       → "En la cómoda de la habitación" (respuesta por voz)
"Cita con el doctor el viernes" → Recordatorio tipo appointment con alta importancia
```

## Tipos de recordatorio

| Tipo | Descripción |
|------|-------------|
| `medication` | Medicamentos con recurrencia |
| `appointment` | Citas médicas, reuniones |
| `call` | Llamadas pendientes |
| `shopping` | Lista de compras |
| `task` | Tareas generales |
| `event` | Eventos con fecha/hora |
| `location` | Notas de ubicación (sin alarma) |

## Niveles de importancia

- **high** — Alarma con sonido, vibración y pantalla completa
- **medium** — Notificación con sonido
- **low** — Notificación silenciosa
- **info** — Solo nota, sin notificación

## Stack tecnológico

| Capa | Tecnología |
|------|------------|
| Frontend | Flutter 3.41+ / Dart 3.11+ |
| Estado | flutter_bloc (Cubits) |
| Base de datos local | Drift (SQLite) |
| Backend IA | API propia (`letmeknow-api.tacuchi.net`) |
| Voz → Texto | speech_to_text |
| Texto → Voz | flutter_tts |
| Alarmas | alarm (foreground service) |
| Notificaciones | flutter_local_notifications |

## Arquitectura

Clean Architecture con módulos por feature:

```
lib/
├── core/           # Shared: config, database, theme, widgets
├── di/             # GetIt (inyección de dependencias)
├── features/
│   ├── alarm/      # Pantalla de alarma
│   ├── groups/     # Agrupación de recordatorios
│   ├── reminders/  # CRUD + detalle de recordatorios
│   ├── settings/   # Configuración
│   └── voice_recording/  # Chat por voz con IA
├── router/         # GoRouter (navegación)
└── services/       # Alarma, asistente IA, notificaciones, STT, TTS
```

Cada feature sigue la estructura de capas:
- **domain/** — Entidades y contratos (Dart puro)
- **infrastructure/** — Implementaciones (Drift, HTTP)
- **application/** — Cubits (lógica de estado)
- **presentation/** — Páginas y widgets (Flutter UI)

## Roadmap

- [x] Estructura base (Clean Architecture)
- [x] Navegación con go_router
- [x] Grabación y transcripción de voz
- [x] Integración con backend IA
- [x] Creación de recordatorios por voz
- [x] Detección de patrones y recurrencias
- [x] Consultas por voz (notas de ubicación)
- [x] Alarmas con foreground service
- [x] Manejo de permisos OEM (Xiaomi, Huawei, OPPO)
- [x] Agrupación de recordatorios
- [x] Vista previa de recordatorios en chat
- [ ] Tests unitarios y de integración
- [ ] CI/CD con GitHub Actions
- [ ] Publicación en Play Store
