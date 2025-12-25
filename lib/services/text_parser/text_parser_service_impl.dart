import '../../features/reminders/domain/entities/reminder_importance.dart';
import '../../features/reminders/domain/entities/reminder_type.dart';
import 'text_parser_service.dart';

class TextParserServiceImpl implements TextParserService {
  // Palabras clave por tipo de recordatorio (orden importa: location primero para priorizar)
  static const _typeKeywords = <ReminderType, List<String>>{
    // Location primero para detectar "dejé", "guardé" antes que otros tipos
    ReminderType.location: [
      'dejé',
      'deje',
      'dejando',
      'guardé',
      'guarde',
      'guardando',
      'puse',
      'poniendo',
      'está en',
      'esta en',
      'están en',
      'estan en',
      'lo tengo en',
      'la tengo en',
      'los tengo en',
      'las tengo en',
      'bajo la',
      'encima de',
      'dentro de',
      'sobre la',
      'sobre el',
    ],
    ReminderType.medication: [
      'pastilla',
      'pastillas',
      'medicina',
      'medicamento',
      'medicamentos',
      'dosis',
      'medicación',
      'remedio',
      'tomar pastilla',
      'tomar medicina',
      'tomar medicamento',
    ],
    ReminderType.appointment: [
      'doctor',
      'doctora',
      'cita',
      'hospital',
      'consulta',
      'médico',
      'medico',
      'dentista',
      'clínica',
      'clinica',
    ],
    ReminderType.call: [
      'llamar',
      'llamada',
      'teléfono',
      'telefono',
      'contactar',
      'marcar',
      'telefonear',
    ],
    ReminderType.shopping: [
      'comprar',
      'tienda',
      'supermercado',
      'compras',
      'mercado',
    ],
    ReminderType.event: [
      'reunión',
      'reunion',
      'junta',
      'meeting',
      'evento',
      'fiesta',
      'cumpleaños',
    ],
  };

  // Importancia por tipo (según requerimientos funcionales)
  static const _importanceByType = <ReminderType, ReminderImportance>{
    ReminderType.medication: ReminderImportance.high,
    ReminderType.appointment: ReminderImportance.high,
    ReminderType.call: ReminderImportance.medium,
    ReminderType.event: ReminderImportance.medium,
    ReminderType.task: ReminderImportance.medium,
    ReminderType.shopping: ReminderImportance.low,
    ReminderType.location: ReminderImportance.info, // Nota sin notificación
  };

  // Días de la semana en español
  static const _weekDays = {
    'lunes': DateTime.monday,
    'martes': DateTime.tuesday,
    'miércoles': DateTime.wednesday,
    'miercoles': DateTime.wednesday,
    'jueves': DateTime.thursday,
    'viernes': DateTime.friday,
    'sábado': DateTime.saturday,
    'sabado': DateTime.saturday,
    'domingo': DateTime.sunday,
  };

  // Números en texto
  static const _numberWords = {
    'un': 1,
    'una': 1,
    'uno': 1,
    'dos': 2,
    'tres': 3,
    'cuatro': 4,
    'cinco': 5,
    'seis': 6,
    'siete': 7,
    'ocho': 8,
    'nueve': 9,
    'diez': 10,
    'once': 11,
    'doce': 12,
    'quince': 15,
    'veinte': 20,
    'treinta': 30,
    'cuarenta': 40,
    'media': 30, // "media hora"
  };

  @override
  ParsedReminder parse(String transcription) {
    final text = transcription.trim();
    if (text.isEmpty) {
      return const ParsedReminder(
        title: 'Recordatorio',
        type: ReminderType.task,
        importance: ReminderImportance.medium,
      );
    }

    final lowerText = text.toLowerCase();
    final title = _extractTitle(text);
    
    // Extraer fecha PRIMERO - si hay tiempo relativo, NO es una nota de ubicación
    final scheduledAt = _extractDateTime(lowerText);
    final hasRelativeTime = _hasRelativeTimePattern(lowerText);
    
    // Detectar tipo (pero si hay tiempo relativo, excluir location)
    final type = _detectType(lowerText, excludeLocation: hasRelativeTime);
    final importance = _importanceByType[type] ?? ReminderImportance.medium;

    // Para tipo location, no programar fecha y extraer object/location
    if (type == ReminderType.location) {
      final (object, location) = _extractObjectAndLocation(lowerText);
      return ParsedReminder(
        title: title,
        type: type,
        scheduledAt: null, // Notas de ubicación no tienen hora
        importance: importance,
        object: object,
        location: location,
      );
    }

    return ParsedReminder(
      title: title,
      type: type,
      scheduledAt: scheduledAt,
      importance: importance,
    );
  }

  String _extractTitle(String text) {
    // Capitalizar primera letra y truncar a 60 caracteres
    final trimmed = text.trim();
    if (trimmed.isEmpty) return 'Recordatorio';

    final capitalized = trimmed[0].toUpperCase() + trimmed.substring(1);
    if (capitalized.length <= 60) return capitalized;

    // Truncar en el último espacio antes de 60 caracteres
    final truncated = capitalized.substring(0, 60);
    final lastSpace = truncated.lastIndexOf(' ');
    if (lastSpace > 30) {
      return '${truncated.substring(0, lastSpace)}...';
    }
    return '$truncated...';
  }

  /// Verifica si el texto contiene un patrón de tiempo relativo
  bool _hasRelativeTimePattern(String lowerText) {
    final relativePattern = RegExp(
      r'en (\d+|un|una|uno|dos|tres|cuatro|cinco|diez|quince|veinte|treinta) (hora|horas|minuto|minutos|min|mins|segundo|segundos|seg)',
    );
    return relativePattern.hasMatch(lowerText);
  }

  ReminderType _detectType(String lowerText, {bool excludeLocation = false}) {
    for (final entry in _typeKeywords.entries) {
      // Si hay tiempo relativo, no clasificar como location
      if (excludeLocation && entry.key == ReminderType.location) {
        continue;
      }
      for (final keyword in entry.value) {
        if (lowerText.contains(keyword)) {
          return entry.key;
        }
      }
    }
    return ReminderType.task;
  }

  DateTime? _extractDateTime(String lowerText) {
    final now = DateTime.now();

    // Patrón: "a las X" o "a las X:XX"
    final timePattern = RegExp(r'a las? (\d{1,2})(?::(\d{2}))?(?:\s*(am|pm|de la mañana|de la tarde|de la noche))?');
    final timeMatch = timePattern.firstMatch(lowerText);
    if (timeMatch != null) {
      var hour = int.parse(timeMatch.group(1)!);
      final minutes = timeMatch.group(2) != null ? int.parse(timeMatch.group(2)!) : 0;
      final period = timeMatch.group(3);

      // Ajustar AM/PM
      if (period != null) {
        if ((period == 'pm' || period == 'de la tarde' || period == 'de la noche') && hour < 12) {
          hour += 12;
        } else if ((period == 'am' || period == 'de la mañana') && hour == 12) {
          hour = 0;
        }
      } else if (hour <= 6) {
        // Si no especifica y es <= 6, asumir PM
        hour += 12;
      }

      var scheduled = DateTime(now.year, now.month, now.day, hour, minutes);
      // Si ya pasó, programar para mañana
      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }
      return scheduled;
    }

    // Patrón: hora en texto "a las tres", "a las doce"
    final textTimePattern = RegExp(r'a las? (una|uno|dos|tres|cuatro|cinco|seis|siete|ocho|nueve|diez|once|doce)(?:\s*(de la mañana|de la tarde|de la noche))?');
    final textTimeMatch = textTimePattern.firstMatch(lowerText);
    if (textTimeMatch != null) {
      var hour = _numberWords[textTimeMatch.group(1)] ?? 12;
      final period = textTimeMatch.group(2);

      if (period == 'de la tarde' || period == 'de la noche') {
        if (hour < 12) hour += 12;
      } else if (period == 'de la mañana' && hour == 12) {
        hour = 0;
      } else if (hour <= 6) {
        hour += 12;
      }

      var scheduled = DateTime(now.year, now.month, now.day, hour, 0);
      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }
      return scheduled;
    }

    // Patrón: "mañana"
    if (lowerText.contains('mañana') && !lowerText.contains('de la mañana')) {
      return DateTime(now.year, now.month, now.day + 1, 9, 0);
    }

    // Patrón: "pasado mañana"
    if (lowerText.contains('pasado mañana')) {
      return DateTime(now.year, now.month, now.day + 2, 9, 0);
    }

    // Patrón: "en X horas" o "en X minutos" (incluye variaciones comunes)
    final relativePattern = RegExp(
      r'en (\d+|un|una|uno|dos|tres|cuatro|cinco|diez|quince|veinte|treinta) (hora|horas|minuto|minutos|min|mins)',
    );
    final relativeMatch = relativePattern.firstMatch(lowerText);
    if (relativeMatch != null) {
      final amountStr = relativeMatch.group(1)!;
      final amount = _numberWords[amountStr] ?? int.tryParse(amountStr) ?? 1;
      final unit = relativeMatch.group(2)!;

      if (unit.startsWith('hora')) {
        return now.add(Duration(hours: amount));
      } else {
        return now.add(Duration(minutes: amount));
      }
    }

    // Patrón: día de la semana
    for (final entry in _weekDays.entries) {
      if (lowerText.contains(entry.key)) {
        var daysUntil = entry.value - now.weekday;
        if (daysUntil <= 0) daysUntil += 7;
        return DateTime(now.year, now.month, now.day + daysUntil, 9, 0);
      }
    }

    // Sin patrón detectado
    return null;
  }

  /// Extrae objeto y ubicación de una nota de ubicación
  /// Ej: "dejé las llaves en la cómoda" -> ("llaves", "la cómoda")
  (String?, String?) _extractObjectAndLocation(String lowerText) {
    // Patrones para extraer objeto y ubicación
    final patterns = [
      // "dejé/dejando/guardé/guardando/puse/poniendo [objeto] en/bajo/sobre [ubicación]"
      RegExp(r'(?:dejé|deje|dejando|guardé|guarde|guardando|puse|poniendo|estoy dejando|estoy guardando|estoy poniendo)\s+(?:el|la|los|las|mis|mi)?\s*([\w\s]+?)\s+(?:en|bajo|encima de|dentro de|sobre)\s+(.+)'),
      // "[objeto] está en [ubicación]"
      RegExp(r'(?:el|la|los|las|mis|mi)?\s*([\w\s]+?)\s+(?:está|esta|están|estan)\s+(?:en|bajo|encima de|dentro de|sobre)\s+(.+)'),
      // "lo/la tengo en [ubicación]" (objeto implícito)
      RegExp(r'(?:lo|la|los|las)\s+tengo\s+(?:en|bajo|encima de|dentro de|sobre)\s+(.+)'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(lowerText);
      if (match != null) {
        if (match.groupCount >= 2) {
          final object = _cleanExtractedText(match.group(1));
          final location = _cleanExtractedText(match.group(2));
          return (object, location);
        } else if (match.groupCount == 1) {
          // Solo ubicación (objeto implícito)
          final location = _cleanExtractedText(match.group(1));
          return (null, location);
        }
      }
    }

    return (null, null);
  }

  String? _cleanExtractedText(String? text) {
    if (text == null) return null;
    final cleaned = text.trim();
    if (cleaned.isEmpty) return null;
    // Capitalizar primera letra
    return cleaned[0].toUpperCase() + cleaned.substring(1);
  }

  // Palabras interrogativas que indican una consulta
  static const _queryIndicators = [
    'dónde',
    'donde',
    'qué',
    'que',
    'cuál',
    'cual',
    'cuándo',
    'cuando',
    'cuántos',
    'cuantos',
    'cómo',
    'como',
  ];

  // Patrones de consulta de ubicación
  static const _locationQueryPatterns = [
    'dónde dejé',
    'donde deje',
    'dónde está',
    'donde esta',
    'dónde puse',
    'donde puse',
    'dónde guardé',
    'donde guarde',
    'dónde tengo',
    'donde tengo',
  ];

  @override
  bool isQuery(String transcription) {
    final lowerText = transcription.toLowerCase().trim();
    if (lowerText.isEmpty) return false;

    // Verificar si contiene signo de interrogación
    if (lowerText.contains('?') || lowerText.contains('¿')) {
      return true;
    }

    // Verificar si empieza con palabra interrogativa
    for (final indicator in _queryIndicators) {
      if (lowerText.startsWith(indicator)) {
        return true;
      }
    }

    // Verificar patrones de consulta de ubicación
    for (final pattern in _locationQueryPatterns) {
      if (lowerText.contains(pattern)) {
        return true;
      }
    }

    // Verificar consultas de pendientes
    if (lowerText.contains('qué tengo') ||
        lowerText.contains('que tengo') ||
        lowerText.contains('qué recordatorios') ||
        lowerText.contains('que recordatorios') ||
        lowerText.contains('qué pendiente') ||
        lowerText.contains('que pendiente')) {
      return true;
    }

    return false;
  }

  @override
  String? extractSearchObject(String query) {
    final lowerText = query.toLowerCase().trim();

    // Patrones para extraer el objeto buscado
    final patterns = [
      // "¿Dónde dejé/puse/guardé [mis/el/la] [objeto]?"
      RegExp(r'(?:dónde|donde)\s+(?:dejé|deje|puse|guardé|guarde|tengo)\s+(?:el|la|los|las|mis|mi)?\s*(.+?)(?:\?|$)'),
      // "¿Dónde está/están [el/la] [objeto]?"
      RegExp(r'(?:dónde|donde)\s+(?:está|esta|están|estan)\s+(?:el|la|los|las|mis|mi)?\s*(.+?)(?:\?|$)'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(lowerText);
      if (match != null && match.groupCount >= 1) {
        final extracted = match.group(1)?.trim();
        if (extracted != null && extracted.isNotEmpty) {
          // Limpiar artículos finales
          return extracted
              .replaceAll(RegExp(r'\s+$'), '')
              .replaceAll(RegExp(r'^(el|la|los|las|mis|mi)\s+'), '');
        }
      }
    }

    return null;
  }
}
