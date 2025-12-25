# Plan de Implementación: Consultas por Voz y Gestión de Notas

**Proyecto**: Let Me Know  
**Prioridad**: 🔴 Alta  
**Estimación**: 4-6 horas  
**Dependencias**: Plan de creación desde voz (completado)

---

## 🎯 Objetivo

Implementar un sistema de consultas por voz que permita al usuario:
1. Ver y gestionar notas de ubicación separadas de recordatorios con alarma
2. Consultar información por voz ("¿Dónde dejé mis llaves?")
3. Recibir alertas proactivas de recordatorios próximos

---

## 📋 Contexto del Problema

### Dos tipos de items conceptualmente distintos

| Concepto | Ejemplo | Tiene alarma | Consultable |
|----------|---------|--------------|-------------|
| **Recordatorio** | "Tomar pastillas a las 3pm" | ✅ Sí | ❌ No |
| **Nota** | "Dejé las llaves en la cómoda" | ❌ No | ✅ Sí |

### Estado actual
- Ambos se almacenan en tabla `reminders` con `type = location` para notas
- Notas tienen `scheduledAt = null` y `importance = info`
- No hay UI dedicada para ver/consultar notas
- No hay funcionalidad de consulta por voz

---

## 📋 Tareas

### Fase 1: Filtro de Notas en UI (1-2 horas)

#### 1.1 Agregar filtro "Notas" en ReminderListPage

**Archivo**: `lib/features/reminders/application/cubit/reminder_list_state.dart`

```dart
enum ReminderListFilter { all, today, pending, completed, notes }

extension ReminderListFilterX on ReminderListFilter {
  String get label => switch (this) {
    ReminderListFilter.all => 'Todos',
    ReminderListFilter.today => 'Hoy',
    ReminderListFilter.pending => 'Pendientes',
    ReminderListFilter.completed => 'Completados',
    ReminderListFilter.notes => 'Notas',
  };
}
```

#### 1.2 Actualizar getter `filtered` para manejar notas

- Filtro `notes`: Solo items con `type == ReminderType.location`
- Filtro `pending`: Excluir `type == ReminderType.location` (notas no son "pendientes")
- Filtro `today`: Excluir notas (no tienen fecha)

#### 1.3 Actualizar ReminderCard para notas

- Mostrar icono 📍 y etiqueta "Nota" en lugar de hora
- No mostrar indicador de "vencido" para notas
- Acción de swipe: solo eliminar (no "completar")

---

### Fase 2: Servicio de Consultas (2-3 horas)

#### 2.1 Crear QueryService

**Archivo nuevo**: `lib/services/query/query_service.dart`

```dart
abstract class QueryService {
  /// Procesa una consulta de voz y retorna una respuesta
  Future<QueryResult> processQuery(String transcription);
}

class QueryResult {
  final QueryType type;
  final String response;
  final List<Reminder>? relatedItems;
  final List<Reminder>? upcomingAlerts; // Recordatorios en próximas 2 horas

  const QueryResult({
    required this.type,
    required this.response,
    this.relatedItems,
    this.upcomingAlerts,
  });
}

enum QueryType {
  locationQuery,    // "¿Dónde dejé...?"
  reminderQuery,    // "¿Qué tengo pendiente?"
  upcomingAlert,    // Alerta proactiva
  notUnderstood,    // No se pudo procesar
}
```

#### 2.2 Implementar QueryServiceImpl

**Archivo nuevo**: `lib/services/query/query_service_impl.dart`

Lógica de detección:
1. Detectar si es consulta vs comando de creación
2. Identificar tipo de consulta:
   - Palabras clave ubicación: "dónde", "dónde dejé", "dónde está", "dónde puse"
   - Palabras clave pendientes: "qué tengo", "pendiente", "recordatorios"
3. Buscar en repositorio según tipo
4. Generar respuesta en lenguaje natural
5. Incluir alertas de recordatorios próximos (< 2 horas)

**Patrones de consulta:**
| Entrada | Tipo | Búsqueda |
|---------|------|----------|
| "¿Dónde dejé mis llaves?" | `locationQuery` | Buscar en notas por "llaves" |
| "¿Dónde está el control?" | `locationQuery` | Buscar en notas por "control" |
| "¿Qué tengo pendiente?" | `reminderQuery` | Listar pendientes |
| "¿Qué recordatorios tengo hoy?" | `reminderQuery` | Listar para hoy |

#### 2.3 Agregar métodos al repositorio

**Archivo**: `lib/features/reminders/domain/repositories/reminder_repository.dart`

```dart
/// Busca notas de ubicación por objeto
Future<List<Reminder>> searchNotes(String objectQuery);

/// Obtiene recordatorios que se activarán pronto
Future<List<Reminder>> getUpcomingAlerts({Duration within = const Duration(hours: 2)});
```

---

### Fase 3: UI de Consulta por Voz (1-2 horas) ✅ COMPLETADA

#### 3.1 Implementación con PageView tipo TikTok

**Solución implementada**: Refactorizado `VoiceRecordingPage` con dos modos deslizables verticalmente:

**Archivos nuevos**:
- `lib/features/voice_recording/presentation/widgets/voice_command_mode.dart` - Modo crear (naranja)
- `lib/features/voice_recording/presentation/widgets/voice_query_mode.dart` - Modo consultar (violeta)

**Archivo modificado**: `lib/features/voice_recording/presentation/pages/voice_recording_page.dart`

**Características**:
- PageView vertical (scroll arriba/abajo)
- Página 0: Modo Comando (crear recordatorios) - colores originales
- Página 1: Modo Consulta (preguntas) - colores violeta (#7C4DFF)
- Indicador de página lateral
- Hint visual "Desliza para..." en cada modo
- AppBar dinámico que cambia título y colores según modo
- Feedback háptico al cambiar de página

**Flujo modo consulta**:
1. Usuario desliza hacia arriba para cambiar a modo consulta
2. Toca botón de búsqueda (lupa) para hablar
3. Sistema usa QueryService para procesar
4. Muestra respuesta con items relacionados y alertas próximas

---

### Fase 4: Alertas Proactivas (1 hora) ✅ COMPLETADA

#### 4.1 Mostrar alertas al abrir consulta

**Implementación**: Modificado `VoiceQueryMode` para cargar alertas automáticamente.

**Lógica**:
- `didUpdateWidget`: Detecta cuando el modo se activa (`isActive` cambia a true)
- `_loadUpcomingAlerts()`: Llama a `QueryService.getUpcomingAlerts()`
- Banner amarillo se muestra encima del prompt de pregunta
- Muestra hasta 3 alertas con hora, y "y X más..." si hay más

#### 4.2 Incluir en respuesta de consulta

**Ya implementado** en Fase 2: `QueryResult` incluye `upcomingAlerts` y se muestra en `_buildResultView()`

---

## 📁 Archivos a Crear/Modificar

| Archivo | Acción |
|---------|--------|
| `lib/services/query/query_service.dart` | **NUEVO** |
| `lib/services/query/query_service_impl.dart` | **NUEVO** |
| `lib/features/voice_query/presentation/pages/voice_query_page.dart` | **NUEVO** |
| `lib/features/reminders/application/cubit/reminder_list_state.dart` | MODIFICAR |
| `lib/features/reminders/domain/repositories/reminder_repository.dart` | MODIFICAR |
| `lib/features/reminders/infrastructure/repositories/reminder_repository_drift_impl.dart` | MODIFICAR |
| `lib/services/text_parser/text_parser_service.dart` | MODIFICAR |
| `lib/services/text_parser/text_parser_service_impl.dart` | MODIFICAR |
| `lib/di/injection_container.dart` | MODIFICAR |
| `lib/router/app_router.dart` | MODIFICAR |
| `lib/router/app_routes.dart` | MODIFICAR |
| `lib/features/home/presentation/pages/home_page.dart` | MODIFICAR |
| `lib/core/widgets/reminder_card.dart` | MODIFICAR |

---

## ✅ Criterios de Aceptación

### Filtro de Notas
- [x] Existe filtro "Notas" en ReminderListPage
- [x] Filtro "Pendientes" no muestra notas de ubicación
- [x] Las notas muestran icono 📍 y no muestran hora
- [x] Swipe en notas solo permite eliminar, no completar

### Consultas por Voz
- [x] Al preguntar "¿Dónde dejé mis llaves?" se busca en notas y muestra resultado
- [x] Si no hay coincidencia, responde "No tengo registro de dónde dejaste tus llaves"
- [x] Al preguntar "¿Qué tengo pendiente?" lista recordatorios pendientes

### Alertas Proactivas
- [x] Al abrir consulta, si hay recordatorios < 2 horas, muestra alerta
- [x] La alerta permite ver los recordatorios próximos

### General
- [x] `flutter analyze` sin errores
- [ ] App funciona correctamente (pendiente pruebas manuales)

---

## 🔮 Mejoras Futuras (No incluidas en este plan)

1. **Integración LLM (Gemini)**: Mejorar comprensión de consultas con IA
2. **Respuesta por voz (TTS)**: Leer respuesta en voz alta
3. **Búsqueda semántica**: Encontrar notas aunque no coincidan palabras exactas
4. **Consultas complejas**: "¿Cuándo es mi próxima cita con el doctor?"

---

*Plan creado: 24 de diciembre de 2025*
