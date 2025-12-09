# 📋 Requerimientos Funcionales

**Versión**: 1.0  
**Fecha**: 9 de diciembre de 2025  
**Producto**: Let Me Know - Asistente de recordatorios por voz  

---

## 📋 Índice

1. [Visión del Producto](#visión-del-producto)
2. [Usuarios Objetivo](#usuarios-objetivo)
3. [Funcionalidades Core](#funcionalidades-core)
4. [Casos de Uso Detallados](#casos-de-uso-detallados)
5. [Tipos de Recordatorios](#tipos-de-recordatorios)
6. [Flujos de Usuario](#flujos-de-usuario)
7. [Requerimientos de IA](#requerimientos-de-ia)
8. [Requerimientos No Funcionales](#requerimientos-no-funcionales)

---

## 🎯 Visión del Producto

**Let Me Know** es una aplicación móvil que permite crear, gestionar y consultar recordatorios usando únicamente la voz, con inteligencia artificial que aprende patrones y responde preguntas de forma natural.

### Problema que Resuelve

Los adultos mayores frecuentemente:
- Olvidan tomar medicamentos a tiempo
- Pierden objetos y no recuerdan dónde los dejaron
- Tienen dificultad con interfaces complejas de aplicaciones

### Propuesta de Valor

| Problema | Solución |
|----------|----------|
| Interfaces complejas | Interacción 100% por voz |
| Olvidar medicamentos | Alertas inteligentes con repetición |
| Perder objetos | Notas de ubicación consultables |
| Recordatorios repetitivos | Detección automática de patrones |

---

## 👥 Usuarios Objetivo

### Persona Principal: Adulto Mayor (65+ años)

| Característica | Descripción |
|----------------|-------------|
| **Edad** | 65-85 años |
| **Tecnología** | Uso básico de smartphone |
| **Necesidades** | Recordar medicamentos, citas, ubicación de objetos |
| **Limitaciones** | Posible dificultad visual, motora o auditiva |
| **Motivación** | Mantener independencia y autonomía |

### Persona Secundaria: Cuidador/Familiar

| Característica | Descripción |
|----------------|-------------|
| **Rol** | Hijo/a, nieto/a, cuidador profesional |
| **Necesidades** | Monitorear adherencia a medicamentos |
| **Funcionalidad** | Recibir alertas si no se confirman recordatorios críticos |

---

## ✨ Funcionalidades Core

### F1: Creación de Recordatorios por Voz

**Descripción**: El usuario graba un mensaje de voz natural y el sistema extrae automáticamente la información del recordatorio.

**Criterios de Aceptación**:
- [ ] El usuario puede iniciar grabación con un solo toque
- [ ] El sistema transcribe el audio en menos de 3 segundos
- [ ] La IA extrae: título, tipo, fecha/hora, importancia
- [ ] El usuario puede editar antes de confirmar
- [ ] Se programa notificación automáticamente

---

### F2: Detección Inteligente de Patrones

**Descripción**: El sistema identifica recordatorios similares y sugiere crear recordatorios recurrentes.

**Criterios de Aceptación**:
- [ ] Detecta recordatorios con mismo contenido en diferentes horarios
- [ ] Sugiere frecuencia basada en el patrón (diario, semanal, etc.)
- [ ] Permite configurar: frecuencia, horarios, fecha inicio/fin
- [ ] El usuario puede aceptar, modificar o rechazar la sugerencia

---

### F3: Notas de Ubicación Consultables

**Descripción**: Guardar información sin tiempo de expiración que puede consultarse por voz.

**Criterios de Aceptación**:
- [ ] Detecta automáticamente cuando es una nota de ubicación
- [ ] No programa notificación para este tipo
- [ ] Permite consultar por voz: "¿Dónde dejé mis llaves?"
- [ ] Responde con audio (Text-to-Speech)
- [ ] Volumen de respuesta configurable

---

### F4: Notificaciones Inteligentes

**Descripción**: Sistema de alertas configurable con repetición y escalamiento.

**Criterios de Aceptación**:
- [ ] Notificación en la hora programada
- [ ] Opciones: Completar, Posponer (15min, 1h, mañana)
- [ ] Repetición automática si no se confirma (configurable)
- [ ] Horario silencioso nocturno
- [ ] Alerta a contacto de emergencia (opcional, solo medicamentos)

---

### F5: Interfaz Accesible

**Descripción**: Diseño optimizado para usuarios con dificultades visuales o motoras.

**Criterios de Aceptación**:
- [ ] Texto grande configurable (Normal, Grande, Muy grande, Extra grande)
- [ ] Contraste alto (WCAG 2.1 AA mínimo)
- [ ] Touch targets mínimo 48x48px
- [ ] Feedback háptico en todas las acciones
- [ ] Guías de voz opcionales (TalkBack/VoiceOver compatible)

---

## 📖 Casos de Uso Detallados

### CU-01: Recordatorio con Tiempo Específico

**Actor**: Usuario  
**Precondición**: App abierta, micrófono disponible  
**Trigger**: Usuario quiere recordar algo a una hora específica

**Entrada de voz**:
> *"Tengo que tomar mis pastillas para la presión a las 3 pm"*

**Flujo Principal**:

```
1. Usuario toca botón de micrófono
2. Sistema inicia grabación (feedback visual + háptico)
3. Usuario dice el recordatorio
4. Usuario suelta/toca para detener
5. Sistema procesa:
   ├── Transcripción: "Tengo que tomar mis pastillas..."
   ├── Tipo detectado: 💊 Medicamento
   ├── Título extraído: "Tomar pastillas para la presión"
   ├── Hora extraída: 15:00
   └── Importancia asignada: Alta
6. Sistema muestra preview al usuario
7. Usuario confirma
8. Sistema guarda recordatorio + programa notificación
9. Sistema confirma por voz: "Recordatorio guardado para las 3 PM"
```

**Resultado**:

| Campo | Valor |
|-------|-------|
| Título | Tomar pastillas para la presión |
| Tipo | 💊 Medicamento |
| Hora | 15:00 |
| Fecha | Hoy |
| Notificación | ✅ Activa |
| Importancia | 🔴 Alta |
| Recurrencia | Ninguna |

---

### CU-02: Detección de Patrón Recurrente

**Actor**: Usuario  
**Precondición**: Existe un recordatorio similar previo  
**Trigger**: Usuario crea recordatorio similar a uno existente

**Entrada de voz**:
> *"Tengo que tomar mis pastillas para la presión a las 9 pm"*

**Contexto**: Ya existe "Tomar pastillas para la presión a las 3 pm"

**Flujo Principal**:

```
1. Usuario crea nuevo recordatorio (flujo CU-01 pasos 1-5)
2. Sistema detecta patrón:
   ├── Recordatorio similar: "Pastillas presión 3pm"
   ├── Mismo contenido, diferente hora
   └── Patrón sugerido: 2 veces al día
3. Sistema muestra sugerencia:
   "Parece que tomas este medicamento 2 veces al día.
    ¿Quieres crear un recordatorio recurrente?"
4. Usuario acepta
5. Sistema muestra configuración de recurrencia:
   ├── Frecuencia: Diario
   ├── Horarios: [3:00 PM, 9:00 PM]
   ├── Desde: Hoy
   ├── Hasta: Sin fecha fin
   └── Importancia: Alta
6. Usuario ajusta si necesario y confirma
7. Sistema:
   ├── Convierte recordatorio individual a recurrente
   ├── Programa notificaciones para ambos horarios
   └── Confirma por voz
```

**Pantalla de Configuración de Recurrencia**:

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
│  │  [✓] 3:00 PM                              [+ Añadir]    │    │
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
│  └─────────────────────────────────────────────────────────┘    │
│                                                                  │
│         [Cancelar]              [✓ Guardar]                     │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

**Patrones Detectables**:

| Patrón | Ejemplo | Sugerencia |
|--------|---------|------------|
| Mismo medicamento, múltiples horas | Pastillas 8am, 2pm, 8pm | Recurrencia diaria, 3 tomas |
| Misma actividad semanal | "Llamar a mamá" cada domingo | Recurrencia semanal |
| Citas periódicas | Doctor cada 3 meses | Recordatorio trimestral |
| Compras repetidas | Comprar leche (3 veces) | Sugerir lista de compras |

---

### CU-03: Nota de Ubicación (Sin Tiempo)

**Actor**: Usuario  
**Precondición**: App abierta  
**Trigger**: Usuario quiere recordar dónde dejó algo

**Entrada de voz**:
> *"Estoy dejando mis llaves encima de la cómoda de la habitación principal"*

**Flujo Principal**:

```
1. Usuario crea recordatorio (flujo CU-01 pasos 1-4)
2. Sistema analiza y detecta:
   ├── Tipo: 📍 Ubicación/Nota
   ├── Objeto: "Llaves"
   ├── Ubicación: "Cómoda de la habitación principal"
   ├── Tiempo: No aplica
   └── Notificación: No requerida
3. Sistema muestra preview:
   "Voy a guardar que dejaste tus llaves
    en la cómoda de la habitación principal"
4. Usuario confirma
5. Sistema guarda nota indexada para búsqueda
6. Confirma: "Listo, lo recordaré"
```

**Resultado**:

| Campo | Valor |
|-------|-------|
| Tipo | 📍 Ubicación/Nota |
| Objeto | Llaves |
| Ubicación | Cómoda de la habitación principal |
| Notificación | ❌ No aplica |
| Consultable | ✅ Sí |

---

### CU-04: Consulta por Voz

**Actor**: Usuario  
**Precondición**: Existe al menos una nota de ubicación guardada  
**Trigger**: Usuario quiere encontrar algo

**Entrada de voz**:
> *"¿Dónde dejé mis llaves?"*

**Flujo Principal**:

```
1. Usuario toca micrófono y pregunta
2. Sistema detecta tipo de entrada: CONSULTA (no recordatorio)
3. Sistema busca en notas de ubicación:
   ├── Objeto buscado: "llaves"
   └── Coincidencia encontrada: "Llaves en cómoda..."
4. Sistema responde por voz (volumen configurable):
   "Dejaste tus llaves encima de la cómoda
    de la habitación principal"
5. Sistema muestra resultado en pantalla
```

**Flujo Alternativo - No Encontrado**:

```
3. Sistema busca pero no encuentra coincidencia
4. Sistema responde:
   "No tengo registro de dónde dejaste tus llaves"
5. Opcionalmente sugiere: "¿Quieres guardar una nota ahora?"
```

**Ejemplos de Consultas**:

| Nota Guardada | Consulta | Respuesta |
|---------------|----------|-----------|
| "Dejé el control en el cajón de la cocina" | "¿Dónde está el control?" | "El control está en el cajón de la cocina" |
| "La clave del WiFi es casa123" | "¿Cuál es la contraseña del WiFi?" | "La contraseña del WiFi es casa123" |
| "María cumple el 15 de marzo" | "¿Cuándo cumple años María?" | "María cumple años el 15 de marzo" |
| "Doctor López, consultorio 405" | "¿Dónde atiende el doctor López?" | "El doctor López está en el consultorio 405" |

---

## 📦 Tipos de Recordatorios

### Clasificación Automática por IA

| Tipo | Ícono | Palabras Clave | Comportamiento | Importancia |
|------|-------|----------------|----------------|-------------|
| **Medicamento** | 💊 | pastilla, medicina, tratamiento, dosis | Repetir si no confirma | 🔴 Alta |
| **Cita Médica** | 🏥 | doctor, cita, hospital, consulta | Recordar 1 día + 1 hora antes | 🔴 Alta |
| **Llamada** | 📞 | llamar, telefonear, contactar | Mostrar botón llamada rápida | 🟡 Media |
| **Compras** | 🛒 | comprar, tienda, supermercado | Agrupar en lista | 🟢 Baja |
| **Tarea** | 📝 | hacer, terminar, completar | Recordatorio estándar | 🟡 Media |
| **Evento** | 📅 | reunión, cumpleaños, fiesta | Fecha y hora específica | 🟡 Media |
| **Ubicación/Nota** | 📍 | dejé, guardé, puse, está en | Sin notificación, consultable | ⚪ Info |

### Estados de un Recordatorio

```
         ┌─────────────────────────────────────────────┐
         │                                             │
         ▼                                             │
    ┌─────────┐                                        │
    │  Activo │◄──────────────────────────────────┐    │
    └────┬────┘                                   │    │
         │                                        │    │
         │ (llega la hora)                        │    │
         ▼                                        │    │
    ┌───────────┐    (posponer)    ┌───────────┐  │    │
    │ Notificado│────────────────►│ Pospuesto │──┘    │
    └─────┬─────┘                  └───────────┘       │
          │                                           │
          │ (confirmar)                               │
          ▼                                           │
    ┌─────────────┐                                   │
    │ Completado  │                                   │
    └─────────────┘                                   │
          │                                           │
          │ (si es recurrente)                        │
          └───────────────────────────────────────────┘

    Estado especial:
    ┌───────────┐
    │  Vencido  │  ← Si pasa el tiempo sin confirmar
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
│  1. Toca botón de micrófono (FAB grande, 88x88px)                │
└───────────────────────────┬──────────────────────────────────────┘
                            ▼
┌──────────────────────────────────────────────────────────────────┐
│  2. Graba mensaje de voz                                          │
│     • Visual: Ondas de audio animadas                            │
│     • Háptico: Vibración al iniciar                              │
│     • Audio: Beep opcional al iniciar                            │
└───────────────────────────┬──────────────────────────────────────┘
                            ▼
┌──────────────────────────────────────────────────────────────────┐
│  3. Detiene grabación (toca de nuevo o suelta)                   │
└───────────────────────────┬──────────────────────────────────────┘
                            ▼
┌──────────────────────────────────────────────────────────────────┐
│  4. Procesamiento (2-3 segundos)                                  │
│     • Transcripción (Speech-to-Text)                             │
│     • Análisis con IA (clasificación)                            │
│     • Detección de patrones                                       │
└───────────────────────────┬──────────────────────────────────────┘
                            ▼
               ┌────────────┴────────────┐
               ▼                         ▼
┌─────────────────────────┐   ┌─────────────────────────┐
│  5A. Recordatorio        │   │  5B. Consulta           │
│  └► Mostrar preview      │   │  └► Buscar y responder  │
│  └► Detectar patrones    │   │      por voz            │
└────────────┬────────────┘   └─────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────────────────────────────┐
│  6. Usuario revisa y puede:                                      │
│     • [✓ Confirmar] → Guardar como está                         │
│     • [✏️ Editar] → Modificar campos                             │
│     • [🎤 Regrabar] → Volver a empezar                          │
│     • [✕ Cancelar] → Descartar                                  │
└───────────────────────────┬─────────────────────────────────────┘
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│  7. Sistema guarda + programa notificación                       │
└───────────────────────────┬─────────────────────────────────────┘
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│  8. Confirmación por voz: "Recordatorio guardado para las 3 PM" │
└─────────────────────────────────────────────────────────────────┘
```

### Flujo: Notificación de Recordatorio

```
┌─────────────────────────────────────────────────────────────────┐
│  🔔 NOTIFICACIÓN                                                 │
│  ─────────────────────────────────────────────────────────────  │
│  💊 Tomar pastillas para la presión                             │
│  Ahora · Alta prioridad                                          │
│                                                                  │
│  [✓ Listo]   [⏰ 15 min]   [⏰ 1 hora]                          │
└─────────────────────────────────────────────────────────────────┘
                            │
              ┌─────────────┼─────────────┐
              ▼             ▼             ▼
        ┌─────────┐   ┌──────────┐   ┌──────────┐
        │  Listo  │   │ Posponer │   │ Ignorar  │
        └────┬────┘   └────┬─────┘   └────┬─────┘
             │             │              │
             ▼             ▼              ▼
        Completado    Reprogramar    Repetir en X min
                                     (si es medicamento)
```

---

## 🤖 Requerimientos de IA

### R-AI-01: Transcripción de Voz

| Aspecto | Requerimiento |
|---------|---------------|
| **Idioma** | Español (México, España, Latam) |
| **Precisión** | > 95% en condiciones normales |
| **Latencia** | < 3 segundos para audio < 30s |
| **Ruido** | Tolerante a ruido ambiente moderado |
| **Acentos** | Soporte para variantes del español |

### R-AI-02: Clasificación de Recordatorios

**Entrada**: Texto transcrito  
**Salida**: JSON estructurado

```json
{
  "title": "Tomar pastillas para la presión",
  "type": "medicine",
  "datetime": "2025-12-09T15:00:00",
  "importance": "high",
  "isQuery": false,
  "confidence": 0.95
}
```

### R-AI-03: Detección de Patrones

**Entrada**: Recordatorio nuevo + recordatorios existentes  
**Salida**: Sugerencia de patrón

```json
{
  "patternFound": true,
  "similarReminderId": "reminder_123",
  "patternType": "daily_multiple",
  "suggestedFrequency": "daily",
  "suggestedTimes": ["15:00", "21:00"],
  "confidence": 0.87
}
```

### R-AI-04: Búsqueda Semántica

**Entrada**: Consulta en lenguaje natural  
**Salida**: Notas relevantes ordenadas por relevancia

```json
{
  "query": "¿Dónde dejé mis llaves?",
  "isQuery": true,
  "searchTerms": ["llaves", "ubicación"],
  "results": [
    {
      "noteId": "note_456",
      "relevance": 0.92,
      "response": "Dejaste tus llaves encima de la cómoda de la habitación principal"
    }
  ]
}
```

---

## 📐 Requerimientos No Funcionales

### RNF-01: Rendimiento

| Métrica | Objetivo |
|---------|----------|
| Tiempo de carga inicial | < 2 segundos |
| Tiempo de transcripción | < 3 segundos |
| Tiempo de respuesta UI | < 100ms |
| Consumo de batería | < 5% en uso activo/hora |

### RNF-02: Disponibilidad

| Aspecto | Requerimiento |
|---------|---------------|
| Uptime backend | 99.5% |
| Funcionamiento offline | Recordatorios locales funcionan sin internet |
| Degradación elegante | Si IA no disponible, permitir entrada manual |

### RNF-03: Accesibilidad (WCAG 2.1 AA)

| Criterio | Implementación |
|----------|----------------|
| Contraste mínimo | 4.5:1 (texto normal), 3:1 (texto grande) |
| Touch targets | Mínimo 48x48px |
| Texto escalable | Hasta 200% sin pérdida de funcionalidad |
| Screen readers | Compatible con TalkBack y VoiceOver |
| Tiempo de respuesta | No hay límites de tiempo en acciones |

### RNF-04: Seguridad

| Aspecto | Implementación |
|---------|----------------|
| Datos en tránsito | HTTPS/TLS 1.3 |
| Datos en reposo | Cifrado SQLite opcional |
| API keys | Almacenadas en backend, nunca en cliente |
| Autenticación | JWT con refresh tokens |
| Datos de salud | No se envían a terceros sin consentimiento |

### RNF-05: Privacidad

| Dato | Tratamiento |
|------|-------------|
| Audio de voz | Procesado y descartado (no almacenado) |
| Transcripciones | Almacenadas localmente + cloud (opcional) |
| Contenido recordatorios | Cifrado en cloud |
| Analytics | Solo métricas agregadas, no contenido |

---

## 📎 Anexos

### A. Prompt de Clasificación (LLM)

```
Analiza el siguiente mensaje de voz transcrito y extrae información estructurada para crear un recordatorio.

Texto: "{transcripción}"

Recordatorios existentes del usuario (para detectar patrones):
{recordatorios_existentes}

Responde ÚNICAMENTE con JSON válido:
{
  "isQuery": boolean,           // true si es una pregunta/consulta
  "title": "string",            // título corto (máx 50 chars)
  "type": "medicine|appointment|call|shopping|task|event|location",
  "datetime": "ISO 8601 | null",
  "importance": "high|medium|low",
  "object": "string | null",    // para tipo location
  "location": "string | null",  // para tipo location
  "patternDetected": {
    "found": boolean,
    "similarReminderId": "string | null",
    "suggestedFrequency": "daily|weekly|monthly | null",
    "suggestedTimes": ["HH:mm"] | null
  },
  "confidence": 0.0-1.0
}

Reglas:
- medicine: pastillas, medicamento, dosis, tratamiento → importancia HIGH
- appointment: cita, doctor, hospital → importancia HIGH  
- location: "dejé", "guardé", "puse", "está en" → sin datetime
- Si es pregunta ("dónde", "cuál", "cuándo") → isQuery: true
```

### B. Glosario

| Término | Definición |
|---------|------------|
| **Recordatorio** | Nota con fecha/hora que genera notificación |
| **Nota de ubicación** | Información consultable sin tiempo asociado |
| **Patrón** | Secuencia repetitiva detectada por IA |
| **Recurrencia** | Recordatorio que se repite con frecuencia fija |
| **STT** | Speech-to-Text (voz a texto) |
| **TTS** | Text-to-Speech (texto a voz) |
| **LLM** | Large Language Model (modelo de IA) |

---

*Documento vivo - Actualizar conforme evolucionen los requerimientos*
