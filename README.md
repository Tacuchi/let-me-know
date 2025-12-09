# 🔔 Let Me Know

**Asistente de recordatorios por voz para adultos y adultos mayores**

<p align="center">
  <img src="assets/icons/play_store_512.png" alt="Let Me Know Logo" width="120"/>
</p>

> Una aplicación móvil que permite crear, gestionar y consultar recordatorios usando únicamente la voz, con inteligencia artificial que aprende patrones y responde preguntas de forma natural.

---

## 📋 Índice

- [Visión del Producto](#-visión-del-producto)
- [Características Principales](#-características-principales)
- [Casos de Uso](#-casos-de-uso)
- [Tipos de Recordatorios](#-tipos-de-recordatorios)
- [Flujos de Usuario](#-flujos-de-usuario)
- [Arquitectura Técnica](#-arquitectura-técnica)
- [Instalación](#-instalación)
- [Roadmap](#-roadmap)

---

## 🎯 Visión del Producto

**Let Me Know** nace de la necesidad de ayudar a adultos mayores a recordar tareas importantes de su día a día (medicamentos, citas médicas, objetos) sin complicaciones tecnológicas.

### Principios de Diseño

| Principio | Descripción |
|-----------|-------------|
| **🗣️ Voz primero** | La interacción principal es por voz, no por texto |
| **🧠 IA Inteligente** | El sistema aprende patrones y sugiere mejoras |
| **👴 Accesibilidad** | Interfaz grande, clara, con feedback auditivo |
| **🔒 Privacidad** | Los datos sensibles permanecen en el dispositivo |

---

## ✨ Características Principales

### 1. Creación de Recordatorios por Voz

- Graba un mensaje de voz natural
- La IA extrae automáticamente: **qué**, **cuándo**, **tipo**, **importancia**
- No requiere formato específico, habla naturalmente

### 2. Detección Inteligente de Patrones

- Identifica recordatorios similares existentes
- Sugiere crear recordatorios **recurrentes** automáticamente
- Aprende las rutinas del usuario

### 3. Recordatorios de Ubicación/Notas

- Guarda información sin tiempo de expiración
- Permite **consultar por voz**: *"¿Dónde dejé mis llaves?"*
- Respuesta audible con volumen configurable

### 4. Notificaciones Inteligentes

- Alertas configurables (sonido, vibración, voz)
- Repetición automática si no se confirma
- Horario silencioso nocturno

### 5. Interfaz Accesible

- Texto grande y contraste alto
- Feedback háptico en todas las acciones
- Guías de voz opcionales
- Diseñado para usuarios con dificultades visuales o motoras

---

## 📖 Casos de Uso

### Caso 1: Recordatorio con Tiempo Específico

> **Usuario dice**: *"Tengo que tomar mis pastillas para la presión a las 3 pm"*

**Comportamiento del sistema:**

```
┌─────────────────────────────────────────────────────────────────┐
│  🎤 Audio capturado                                              │
│  ↓                                                               │
│  📝 Transcripción: "Tengo que tomar mis pastillas para la       │
│     presión a las 3 pm"                                          │
│  ↓                                                               │
│  🤖 LLM analiza y extrae:                                        │
│     • Tipo: 💊 Medicamento                                       │
│     • Título: "Tomar pastillas para la presión"                  │
│     • Hora: 15:00                                                │
│     • Importancia: Alta (medicamento)                            │
│     • Recurrencia: No detectada                                  │
│  ↓                                                               │
│  ✅ Recordatorio creado                                          │
│  🔔 Notificación programada para las 3:00 PM                     │
└─────────────────────────────────────────────────────────────────┘
```

**Resultado en la app:**

| Campo | Valor |
|-------|-------|
| Título | Tomar pastillas para la presión |
| Tipo | 💊 Medicamento |
| Hora | 15:00 |
| Notificación | ✅ Activa |
| Importancia | 🔴 Alta |

---

### Caso 2: Detección de Patrón Recurrente

> **Usuario dice** (más tarde): *"Tengo que tomar mis pastillas para la presión a las 9 pm"*

**Comportamiento del sistema:**

```
┌─────────────────────────────────────────────────────────────────┐
│  🎤 Audio capturado                                              │
│  ↓                                                               │
│  📝 Transcripción: "Tengo que tomar mis pastillas para la       │
│     presión a las 9 pm"                                          │
│  ↓                                                               │
│  🤖 LLM analiza y DETECTA PATRÓN:                                │
│     • Recordatorio similar encontrado: "Pastillas presión 3pm"  │
│     • Mismo medicamento, diferente hora                          │
│     • Patrón sugerido: 2 veces al día (mañana/noche)            │
│  ↓                                                               │
│  💡 Sistema sugiere al usuario:                                  │
│     "Parece que tomas este medicamento 2 veces al día.          │
│      ¿Quieres crear un recordatorio recurrente?"                │
└─────────────────────────────────────────────────────────────────┘
```

**Pantalla de configuración de recurrencia:**

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                  │
│  💊 Pastillas para la presión                                   │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │  📅 Frecuencia                                           │    │
│  │  ○ Una vez        ● Diario        ○ Semanal             │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │  ⏰ Horarios                                             │    │
│  │  [✓] 3:00 PM                              [Añadir hora] │    │
│  │  [✓] 9:00 PM                                            │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │  📆 Duración                                             │    │
│  │  Desde: [Hoy]              Hasta: [Sin fecha fin]       │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │  🔴 Importancia: Alta                                    │    │
│  │  (Los medicamentos siempre son prioritarios)             │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                  │
│         [Cancelar]              [✓ Guardar recurrencia]         │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

**Patrones que la IA puede detectar:**

| Patrón | Ejemplo | Sugerencia |
|--------|---------|------------|
| Mismo medicamento, múltiples horas | Pastillas 8am, 2pm, 8pm | Recurrencia diaria con 3 tomas |
| Misma actividad semanal | "Llamar a mamá" cada domingo | Recurrencia semanal |
| Citas periódicas | Doctor cada 3 meses | Recordatorio trimestral |
| Compras repetidas | Comprar leche (detectado 3 veces) | Sugerir lista de compras |

---

### Caso 3: Recordatorio de Ubicación (Sin Tiempo)

> **Usuario dice**: *"Estoy dejando mis llaves encima de la cómoda de la habitación principal"*

**Comportamiento del sistema:**

```
┌─────────────────────────────────────────────────────────────────┐
│  🎤 Audio capturado                                              │
│  ↓                                                               │
│  📝 Transcripción: "Estoy dejando mis llaves encima de la       │
│     cómoda de la habitación principal"                           │
│  ↓                                                               │
│  🤖 LLM analiza:                                                 │
│     • Tipo: 📍 Ubicación/Nota                                   │
│     • Objeto: "Llaves"                                           │
│     • Ubicación: "Cómoda de la habitación principal"             │
│     • Tiempo: ❌ No aplica                                       │
│     • Notificación: ❌ No requerida                              │
│  ↓                                                               │
│  ✅ Nota de ubicación guardada                                   │
│  🔍 Indexada para búsqueda por voz                               │
└─────────────────────────────────────────────────────────────────┘
```

**Consulta posterior por voz:**

> **Usuario pregunta**: *"¿Dónde dejé mis llaves?"*

```
┌─────────────────────────────────────────────────────────────────┐
│  🎤 Audio capturado                                              │
│  ↓                                                               │
│  📝 Transcripción: "¿Dónde dejé mis llaves?"                    │
│  ↓                                                               │
│  🤖 LLM identifica:                                              │
│     • Tipo de consulta: Búsqueda de ubicación                   │
│     • Objeto buscado: "llaves"                                   │
│  ↓                                                               │
│  🔍 Búsqueda en notas de ubicación                               │
│     → Encontrado: "Llaves en cómoda, habitación principal"      │
│  ↓                                                               │
│  🔊 Respuesta por voz (volumen configurable):                    │
│     "Dejaste tus llaves encima de la cómoda                     │
│      de la habitación principal"                                 │
│  ↓                                                               │
│  📱 También se muestra en pantalla con la nota completa          │
└─────────────────────────────────────────────────────────────────┘
```

**Más ejemplos de notas consultables:**

| Usuario guarda | Usuario pregunta | Respuesta |
|----------------|------------------|-----------|
| "Dejé el control del TV en el cajón de la cocina" | "¿Dónde está el control?" | "El control del TV está en el cajón de la cocina" |
| "La contraseña del WiFi es casa123" | "¿Cuál es la clave del WiFi?" | "La contraseña del WiFi es casa123" |
| "El cumpleaños de María es el 15 de marzo" | "¿Cuándo cumple años María?" | "María cumple años el 15 de marzo" |
| "El doctor López está en el consultorio 405" | "¿En qué consultorio está el doctor?" | "El doctor López está en el consultorio 405" |

---

## 📦 Tipos de Recordatorios

### Clasificación Automática por IA

| Tipo | Ícono | Características | Importancia Default |
|------|-------|-----------------|---------------------|
| **Medicamento** | 💊 | Notificación con repetición, no descartar sin confirmar | 🔴 Alta |
| **Cita Médica** | 🏥 | Recordatorio 1 día antes + 1 hora antes | 🔴 Alta |
| **Llamada** | 📞 | Botón de llamada rápida, mostrar contacto | 🟡 Media |
| **Compras** | 🛒 | Agrupa en lista, sin hora específica | 🟢 Baja |
| **Tarea** | 📝 | Recordatorio estándar | 🟡 Media |
| **Evento** | 📅 | Fecha y hora específica | 🟡 Media |
| **Ubicación/Nota** | 📍 | Sin notificación, consultable por voz | ⚪ Info |

### Estados de un Recordatorio

```
┌─────────┐     ┌───────────┐     ┌─────────────┐
│ Activo  │────►│ Notificado│────►│ Completado  │
└─────────┘     └───────────┘     └─────────────┘
     │                │
     │                ▼
     │          ┌───────────┐
     └─────────►│ Pospuesto │
                └───────────┘
                      │
                      ▼
                ┌───────────┐
                │  Vencido  │
                └───────────┘
```

---

## 🔄 Flujos de Usuario

### Flujo Principal: Crear Recordatorio

```
┌──────────────────────────────────────────────────────────────────┐
│                        INICIO                                     │
└───────────────────────────┬──────────────────────────────────────┘
                            ▼
┌──────────────────────────────────────────────────────────────────┐
│  1. Usuario toca botón de micrófono (FAB grande)                 │
└───────────────────────────┬──────────────────────────────────────┘
                            ▼
┌──────────────────────────────────────────────────────────────────┐
│  2. Graba mensaje de voz                                          │
│     • Feedback visual: ondas de audio                            │
│     • Feedback háptico: vibración al iniciar                     │
└───────────────────────────┬──────────────────────────────────────┘
                            ▼
┌──────────────────────────────────────────────────────────────────┐
│  3. Suelta o toca de nuevo para detener                          │
└───────────────────────────┬──────────────────────────────────────┘
                            ▼
┌──────────────────────────────────────────────────────────────────┐
│  4. Procesamiento (2-3 segundos)                                  │
│     • Transcripción (Speech-to-Text)                             │
│     • Análisis con IA (LLM)                                       │
│     • Detección de patrones                                       │
└───────────────────────────┬──────────────────────────────────────┘
                            ▼
               ┌────────────┴────────────┐
               ▼                         ▼
┌─────────────────────────┐   ┌─────────────────────────┐
│  5A. Sin patrón          │   │  5B. Patrón detectado   │
│  Mostrar preview         │   │  Mostrar sugerencia     │
│  [Confirmar] [Editar]    │   │  de recurrencia         │
└────────────┬────────────┘   └────────────┬────────────┘
             │                              │
             └──────────────┬───────────────┘
                            ▼
┌──────────────────────────────────────────────────────────────────┐
│  6. Guardar recordatorio + Programar notificación                │
└───────────────────────────┬──────────────────────────────────────┘
                            ▼
┌──────────────────────────────────────────────────────────────────┐
│  7. Confirmación por voz: "Recordatorio guardado para las 3 PM"  │
└──────────────────────────────────────────────────────────────────┘
```

### Flujo: Consultar por Voz

```
┌──────────────────────────────────────────────────────────────────┐
│  1. Usuario toca micrófono + pregunta                            │
│     "¿Dónde dejé mis llaves?"                                    │
└───────────────────────────┬──────────────────────────────────────┘
                            ▼
┌──────────────────────────────────────────────────────────────────┐
│  2. Sistema detecta que es una CONSULTA, no un recordatorio      │
└───────────────────────────┬──────────────────────────────────────┘
                            ▼
┌──────────────────────────────────────────────────────────────────┐
│  3. Busca en notas/ubicaciones guardadas                         │
└───────────────────────────┬──────────────────────────────────────┘
                            ▼
               ┌────────────┴────────────┐
               ▼                         ▼
┌─────────────────────────┐   ┌─────────────────────────┐
│  4A. Encontrado          │   │  4B. No encontrado      │
│  Responde por voz +      │   │  "No tengo registro     │
│  muestra en pantalla     │   │   de dónde dejaste      │
└─────────────────────────┘   │   tus llaves"            │
                              └─────────────────────────┘
```

### Flujo: Notificación de Recordatorio

```
┌──────────────────────────────────────────────────────────────────┐
│  🔔 Notificación aparece                                          │
│  "💊 Tomar pastillas para la presión"                            │
└───────────────────────────┬──────────────────────────────────────┘
                            ▼
┌──────────────────────────────────────────────────────────────────┐
│  Usuario puede:                                                   │
│  • [✓ Listo] - Marcar como completado                            │
│  • [⏰ 15 min] - Posponer 15 minutos                              │
│  • [⏰ 1 hora] - Posponer 1 hora                                  │
│  • [Ignorar] - Se repetirá según configuración                   │
└───────────────────────────┬──────────────────────────────────────┘
                            ▼
┌──────────────────────────────────────────────────────────────────┐
│  Si es medicamento y no se confirma:                              │
│  • Repetir alerta cada X minutos (configurable)                   │
│  • Opcional: Alertar a contacto de emergencia                    │
└──────────────────────────────────────────────────────────────────┘
```

---

## 🏗️ Arquitectura Técnica

### Stack Tecnológico

| Capa | Tecnología |
|------|------------|
| **Frontend** | Flutter (iOS + Android) |
| **Estado** | flutter_bloc (Cubit) |
| **Backend** | Firebase / Supabase (por definir) |
| **IA - Transcripción** | OpenAI Whisper API |
| **IA - Clasificación** | Google Gemini / OpenAI GPT |
| **Base de datos local** | SQLite (sqflite) |
| **Notificaciones** | flutter_local_notifications |

### Arquitectura de Servicios

```
┌─────────────────────────────────────────────────────────────────┐
│                       FLUTTER APP                                │
├─────────────────────────────────────────────────────────────────┤
│  UI Layer → BLoC/Cubit → Use Cases → Repositories               │
└───────────────────────────┬─────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                    BACKEND (Firebase/Supabase)                   │
├──────────────────┬──────────────────┬───────────────────────────┤
│   Auth Service   │   Database       │   Cloud Functions         │
│   (usuarios)     │   (recordatorios)│   (API personalizada)     │
└──────────────────┴──────────────────┴───────────────┬───────────┘
                                                      │
                                                      ▼
                                        ┌─────────────────────────┐
                                        │   Servicios de IA       │
                                        ├─────────────────────────┤
                                        │  • OpenAI Whisper (STT) │
                                        │  • Gemini/GPT (LLM)     │
                                        └─────────────────────────┘
```

### Cloud Functions / Edge Functions

Las funciones serverless permiten:

1. **Proteger API keys** - Las claves de IA nunca están en el cliente
2. **Lógica personalizada** - Control total sobre prompts y procesamiento
3. **Rate limiting** - Proteger contra abusos
4. **Logging y analytics** - Monitorear uso y errores

```typescript
// Ejemplo de endpoint personalizado
POST /api/process-reminder

Request:
{
  "audioUrl": "https://storage.../audio.m4a",
  "userId": "user_123",
  "existingReminders": [...] // Para detección de patrones
}

Response:
{
  "transcription": "Tomar pastillas a las 3pm",
  "reminder": {
    "title": "Tomar pastillas para la presión",
    "type": "medicine",
    "scheduledAt": "2025-12-09T15:00:00",
    "importance": "high"
  },
  "patternDetected": {
    "found": true,
    "similarReminder": "reminder_456",
    "suggestion": "recurring",
    "suggestedFrequency": "daily"
  }
}
```

---

## 🚀 Instalación

### Prerrequisitos

- Flutter SDK >= 3.10.0
- Dart >= 3.0.0
- Android Studio / Xcode
- Cuenta Firebase o Supabase (para backend)

### Pasos

```bash
# Clonar repositorio
git clone https://github.com/tacuchi/let-me-know.git
cd let-me-know

# Instalar dependencias
flutter pub get

# Configurar variables de entorno
cp .env.example .env
# Editar .env con tus API keys

# Ejecutar
flutter run
```

### Variables de Entorno

```bash
# .env
WHISPER_API_KEY=sk-...
GEMINI_API_KEY=AIza...
FIREBASE_PROJECT_ID=let-me-know-xxx
```

---

## 🗺️ Roadmap

### Fase 1: MVP (En desarrollo)
- [x] Estructura de proyecto (Clean Architecture)
- [x] Navegación y pantallas base
- [x] Sistema de diseño accesible
- [ ] Grabación de audio
- [ ] Integración Speech-to-Text
- [ ] Integración LLM para clasificación
- [ ] Almacenamiento local (SQLite)
- [ ] Notificaciones locales

### Fase 2: Inteligencia
- [ ] Detección de patrones (recordatorios recurrentes)
- [ ] Notas de ubicación consultables por voz
- [ ] Respuestas por voz (Text-to-Speech)
- [ ] Configuración de volumen de voz

### Fase 3: Sincronización
- [ ] Backend con Firebase/Supabase
- [ ] Autenticación de usuarios
- [ ] Sincronización entre dispositivos
- [ ] Contactos de emergencia

### Fase 4: Mejoras
- [ ] Widget de pantalla de inicio
- [ ] Apple Watch / Wear OS
- [ ] Modo offline mejorado
- [ ] Estadísticas de adherencia (medicamentos)

---

## 📄 Licencia

Este proyecto está bajo la licencia MIT. Ver [LICENSE](LICENSE) para más detalles.

---

## 🤝 Contribuir

Las contribuciones son bienvenidas. Por favor, lee [CONTRIBUTING.md](CONTRIBUTING.md) antes de enviar un PR.

---

<p align="center">
  Hecho con ❤️ para ayudar a quienes más queremos
</p>
