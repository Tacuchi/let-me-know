# Plan de Implementación: Creación Real desde Voz

**Proyecto**: Let Me Know  
**Prioridad**: 🔴 Alta  
**Estimación**: 2-3 horas  
**Dependencias**: Ninguna (puede ejecutarse en paralelo)

---

## 🎯 Objetivo

Reemplazar los datos MOCK en la creación de recordatorios por voz con extracción básica de información desde la transcripción.

## 🐛 Problema Actual

En `lib/features/voice_recording/presentation/pages/voice_recording_page.dart` líneas 583-596:

```dart
final reminder = Reminder(
  id: const Uuid().v4(),
  title: 'Tomar pastillas',  // ❌ MOCK
  description: _transcription ?? '',
  scheduledAt: DateTime.now().add(const Duration(hours: 12)),  // ❌ MOCK
  type: ReminderType.medication,  // ❌ MOCK
  status: ReminderStatus.pending,
  importance: ReminderImportance.high,  // ❌ MOCK
  source: ReminderSource.voice,
  createdAt: DateTime.now(),
);
```

Solo `description` usa la transcripción real. El resto son valores fijos.

---

## 📋 Tareas

### 1. Crear servicio de parsing de texto

**Archivo nuevo**: `lib/services/text_parser/text_parser_service.dart`

```dart
abstract class TextParserService {
  /// Extrae información del texto de voz
  ParsedReminder parse(String transcription);
}

class ParsedReminder {
  final String title;
  final ReminderType type;
  final DateTime? scheduledAt;
  final ReminderImportance importance;
  
  const ParsedReminder({
    required this.title,
    required this.type,
    this.scheduledAt,
    required this.importance,
  });
}
```

---

### 2. Implementar extracción básica

**Archivo nuevo**: `lib/services/text_parser/text_parser_service_impl.dart`

Implementar lógica de extracción:

#### 2.1 Extraer título
- Usar la transcripción completa, truncada a 50 caracteres
- Capitalizar primera letra

#### 2.2 Detectar tipo por palabras clave

| Palabra Clave | Tipo |
|---------------|------|
| `pastilla`, `medicina`, `medicamento`, `dosis`, `tomar` | `medication` |
| `doctor`, `cita`, `hospital`, `consulta`, `médico` | `appointment` |
| `llamar`, `llamada`, `teléfono`, `contactar` | `call` |
| `comprar`, `tienda`, `supermercado`, `compras` | `shopping` |
| `reunión`, `junta`, `meeting` | `event` |
| `dejé`, `guardé`, `puse`, `está en` | `location` |
| (default) | `task` |

#### 2.3 Extraer hora/fecha con regex

Patrones a detectar:
- `a las X` / `a las X:XX` → Hora específica hoy
- `mañana` → Mañana a las 9:00 AM
- `en X horas` / `en X minutos` → Relativo
- `lunes`, `martes`, etc. → Próximo día de la semana
- Si no hay patrón → `null` (sin notificación programada)

#### 2.4 Asignar importancia según tipo

| Tipo | Importancia |
|------|-------------|
| `medication`, `appointment` | `high` |
| `call`, `event` | `medium` |
| `task`, `shopping`, `location` | `low` |

---

### 3. Registrar en inyección de dependencias

**Archivo**: `lib/di/injection_container.dart`

```dart
// Agregar import
import 'package:let_me_know/services/text_parser/text_parser_service.dart';
import 'package:let_me_know/services/text_parser/text_parser_service_impl.dart';

// En configureDependencies()
getIt.registerLazySingleton<TextParserService>(
  () => TextParserServiceImpl(),
);
```

---

### 4. Integrar en VoiceRecordingPage

**Archivo**: `lib/features/voice_recording/presentation/pages/voice_recording_page.dart`

Modificar `_showSuccessAndClose()`:

```dart
Future<void> _showSuccessAndClose() async {
  final repository = getIt<ReminderRepository>();
  final parser = getIt<TextParserService>();
  
  // Parsear la transcripción
  final parsed = parser.parse(_transcription ?? '');
  
  final reminder = Reminder(
    id: const Uuid().v4(),
    title: parsed.title,  // ✅ Extraído
    description: _transcription ?? '',
    scheduledAt: parsed.scheduledAt,  // ✅ Extraído
    type: parsed.type,  // ✅ Extraído
    status: ReminderStatus.pending,
    importance: parsed.importance,  // ✅ Extraído
    source: ReminderSource.voice,
    hasNotification: parsed.scheduledAt != null,
    createdAt: DateTime.now(),
  );
  
  await repository.save(reminder);
  // ... resto del código
}
```

---

### 5. (Opcional) Agregar preview editable

Antes de guardar, mostrar los campos extraídos y permitir edición:

- Título (TextField)
- Tipo (Dropdown)
- Fecha/Hora (DateTimePicker)
- Importancia (Chips)

*Esta tarea es opcional y puede dejarse para una iteración futura.*

---

## ✅ Criterios de Aceptación

- [ ] Al grabar "tomar pastillas a las 3", se crea recordatorio con:
  - Título: "Tomar pastillas a las 3"
  - Tipo: `medication`
  - Hora: 15:00 del día actual
  - Importancia: `high`

- [ ] Al grabar "llamar al doctor mañana", se crea recordatorio con:
  - Título: "Llamar al doctor mañana"
  - Tipo: `appointment` o `call`
  - Hora: Mañana 9:00 AM
  - Importancia: `high` o `medium`

- [ ] Al grabar "comprar leche", se crea recordatorio con:
  - Título: "Comprar leche"
  - Tipo: `shopping`
  - Hora: `null` (sin programar)
  - Importancia: `low`

- [ ] `flutter analyze` sin errores
- [ ] App funciona correctamente en emulador

---

## 📁 Archivos a Crear/Modificar

| Archivo | Acción |
|---------|--------|
| `lib/services/text_parser/text_parser_service.dart` | **NUEVO** |
| `lib/services/text_parser/text_parser_service_impl.dart` | **NUEVO** |
| `lib/di/injection_container.dart` | MODIFICAR |
| `lib/features/voice_recording/presentation/pages/voice_recording_page.dart` | MODIFICAR |

---

## ⚠️ Notas Importantes

1. **No usar IA en este plan** - La integración con Gemini es una tarea separada
2. **Regex en español** - Considerar variantes (ej: "a las tres" vs "a las 3")
3. **Fallback seguro** - Si no se detecta nada, usar valores por defecto razonables
4. **Sin dependencias nuevas** - No agregar paquetes a `pubspec.yaml`

---

*Plan creado: 24 de diciembre de 2025*
