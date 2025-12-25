import '../../features/reminders/domain/entities/reminder_importance.dart';
import '../../features/reminders/domain/entities/reminder_type.dart';
import 'transcription_analyzer.dart';

/// Implementación local del analizador de transcripciones usando regex.
///
/// Esta implementación no requiere conexión a internet y funciona offline.
/// Para mejorar la precisión, se puede reemplazar por [LlmTranscriptionAnalyzer]
/// que use Gemini, GPT u otro LLM.
class LocalTranscriptionAnalyzer implements TranscriptionAnalyzer {
  // ============================================================
  // CONFIGURACIÓN DE PALABRAS CLAVE
  // ============================================================

  /// Palabras clave que indican tipo de recordatorio
  static const _typeKeywords = <ReminderType, List<String>>{
    // Location primero para priorizar detección de notas
    ReminderType.location: [
      'dejé', 'deje', 'dejando',
      'guardé', 'guarde', 'guardando',
      'puse', 'poniendo',
      'está en', 'esta en', 'están en', 'estan en',
      'lo tengo en', 'la tengo en', 'los tengo en', 'las tengo en',
      'bajo la', 'bajo el', 'encima de', 'dentro de', 'sobre la', 'sobre el',
    ],
    ReminderType.medication: [
      'pastilla', 'pastillas', 'medicina', 'medicamento', 'medicamentos',
      'dosis', 'medicación', 'remedio', 'tomar pastilla', 'tomar medicina',
    ],
    ReminderType.appointment: [
      'doctor', 'doctora', 'cita', 'hospital', 'consulta',
      'médico', 'medico', 'dentista', 'clínica', 'clinica',
    ],
    ReminderType.call: [
      'llamar', 'llamada', 'teléfono', 'telefono', 'contactar', 'marcar',
    ],
    ReminderType.shopping: [
      'comprar', 'tienda', 'supermercado', 'compras', 'mercado',
    ],
    ReminderType.event: [
      'reunión', 'reunion', 'junta', 'meeting', 'evento', 'fiesta', 'cumpleaños',
    ],
  };

  /// Importancia por tipo de recordatorio
  static const _importanceByType = <ReminderType, ReminderImportance>{
    ReminderType.medication: ReminderImportance.high,
    ReminderType.appointment: ReminderImportance.high,
    ReminderType.call: ReminderImportance.medium,
    ReminderType.event: ReminderImportance.medium,
    ReminderType.task: ReminderImportance.medium,
    ReminderType.shopping: ReminderImportance.low,
    ReminderType.location: ReminderImportance.info,
  };

  /// Palabras que indican una pregunta/consulta
  static const _queryIndicators = [
    'dónde', 'donde', 'qué', 'que', 'cuál', 'cual',
    'cuándo', 'cuando', 'cuántos', 'cuantos', 'cómo', 'como',
  ];

  /// Patrones de consulta de ubicación
  static const _locationQueryPatterns = [
    'dónde dejé', 'donde deje', 'dónde está', 'donde esta',
    'dónde puse', 'donde puse', 'dónde guardé', 'donde guarde',
    'dónde tengo', 'donde tengo',
  ];

  /// Patrones de consulta de horario/tiempo
  static const _scheduleQueryPatterns = [
    'a qué hora', 'a que hora',
    'cuándo', 'cuando',
    'qué hora', 'que hora',
    'a qué tiempo', 'a que tiempo',
    'en qué momento', 'en que momento',
  ];

  /// Palabras clave para buscar tipos de recordatorio en consultas
  static const _scheduleSubjectKeywords = <String, String>{
    'pastilla': 'medication', 'pastillas': 'medication',
    'medicina': 'medication', 'medicamento': 'medication',
    'medicación': 'medication', 'dosis': 'medication',
    'cita': 'appointment', 'doctor': 'appointment', 'médico': 'appointment',
    'reunión': 'event', 'reunion': 'event', 'evento': 'event', 'junta': 'event',
    'llamada': 'call', 'llamar': 'call',
    'compra': 'shopping', 'compras': 'shopping',
  };

  /// Días de la semana para extracción de fechas
  static const _weekDays = {
    'lunes': DateTime.monday, 'martes': DateTime.tuesday,
    'miércoles': DateTime.wednesday, 'miercoles': DateTime.wednesday,
    'jueves': DateTime.thursday, 'viernes': DateTime.friday,
    'sábado': DateTime.saturday, 'sabado': DateTime.saturday,
    'domingo': DateTime.sunday,
  };

  /// Números en texto
  static const _numberWords = {
    'una': 1, 'uno': 1, 'dos': 2, 'tres': 3, 'cuatro': 4, 'cinco': 5,
    'seis': 6, 'siete': 7, 'ocho': 8, 'nueve': 9, 'diez': 10,
    'once': 11, 'doce': 12,
  };

  // ============================================================
  // IMPLEMENTACIÓN DE LA INTERFAZ
  // ============================================================

  @override
  Future<TranscriptionIntent> detectIntent(String transcription) async {
    final text = transcription.toLowerCase().trim();
    if (text.isEmpty) return TranscriptionIntent.unknown;

    // Verificar si es consulta
    if (_isQueryText(text)) {
      if (_isLocationQueryText(text)) {
        return TranscriptionIntent.queryLocation;
      }
      // Consultas de horario tienen prioridad sobre consultas generales
      if (_isScheduleQueryText(text)) {
        return TranscriptionIntent.querySchedule;
      }
      if (_isReminderQueryText(text)) {
        return TranscriptionIntent.queryReminders;
      }
      return TranscriptionIntent.unknown;
    }

    // Es un comando de creación
    return TranscriptionIntent.createReminder;
  }

  @override
  Future<CommandAnalysis> analyzeCommand(String transcription) async {
    final text = transcription.trim();
    if (text.isEmpty) {
      return const CommandAnalysis(
        title: 'Recordatorio',
        type: ReminderType.task,
        importance: ReminderImportance.medium,
      );
    }

    final lowerText = text.toLowerCase();
    final type = _detectType(lowerText);
    final importance = _importanceByType[type] ?? ReminderImportance.medium;
    final title = _extractTitle(text);

    // Para notas de ubicación
    if (type == ReminderType.location) {
      final (object, location) = _extractObjectAndLocation(lowerText);
      return CommandAnalysis(
        title: title,
        type: type,
        scheduledAt: null,
        importance: importance,
        object: object,
        location: location,
      );
    }

    // Para recordatorios con hora
    final scheduledAt = _extractDateTime(lowerText);
    return CommandAnalysis(
      title: title,
      type: type,
      scheduledAt: scheduledAt,
      importance: importance,
    );
  }

  @override
  Future<QueryAnalysis> analyzeQuery(String transcription) async {
    final text = transcription.trim();
    final lowerText = text.toLowerCase();

    final intent = await detectIntent(text);

    String? searchObject;
    String? timeFilter;
    String? reminderTypeFilter;
    String? subjectKeyword;

    switch (intent) {
      case TranscriptionIntent.queryLocation:
        searchObject = _extractSearchObject(lowerText);
        break;
      case TranscriptionIntent.queryReminders:
        timeFilter = _extractTimeFilter(lowerText);
        break;
      case TranscriptionIntent.querySchedule:
        timeFilter = _extractTimeFilter(lowerText);
        final (type, keyword) = _extractScheduleSubject(lowerText);
        reminderTypeFilter = type;
        subjectKeyword = keyword;
        break;
      default:
        break;
    }

    return QueryAnalysis(
      intent: intent,
      searchObject: searchObject,
      timeFilter: timeFilter,
      reminderTypeFilter: reminderTypeFilter,
      subjectKeyword: subjectKeyword,
      normalizedText: text,
    );
  }

  // ============================================================
  // DETECCIÓN DE INTENCIÓN
  // ============================================================

  bool _isQueryText(String lowerText) {
    // Tiene signo de interrogación
    if (lowerText.contains('?') || lowerText.contains('¿')) {
      return true;
    }

    // Empieza con palabra interrogativa
    for (final indicator in _queryIndicators) {
      if (lowerText.startsWith(indicator)) {
        return true;
      }
    }

    // Contiene patrón de consulta
    for (final pattern in _locationQueryPatterns) {
      if (lowerText.contains(pattern)) {
        return true;
      }
    }

    // Consultas de pendientes
    if (lowerText.contains('qué tengo') || lowerText.contains('que tengo') ||
        lowerText.contains('qué recordatorios') || lowerText.contains('que recordatorios')) {
      return true;
    }

    return false;
  }

  bool _isLocationQueryText(String lowerText) {
    return lowerText.contains('dónde') || lowerText.contains('donde');
  }

  bool _isReminderQueryText(String lowerText) {
    return lowerText.contains('qué tengo') || lowerText.contains('que tengo') ||
        lowerText.contains('pendiente') || lowerText.contains('recordatorio');
  }

  bool _isScheduleQueryText(String lowerText) {
    // Verificar patrones de consulta de horario
    for (final pattern in _scheduleQueryPatterns) {
      if (lowerText.contains(pattern)) {
        return true;
      }
    }

    // Consultas que mencionan tiempo + sujeto específico
    final hasTimeWord = lowerText.contains('hora') ||
        lowerText.contains('cuándo') || lowerText.contains('cuando') ||
        lowerText.contains('momento') || lowerText.contains('tiempo');

    if (hasTimeWord) {
      // Verificar si menciona algún sujeto de recordatorio
      for (final keyword in _scheduleSubjectKeywords.keys) {
        if (lowerText.contains(keyword)) {
          return true;
        }
      }
    }

    // Patrones específicos: "qué [sujeto] tengo", "cuáles [sujeto]"
    if ((lowerText.contains('qué ') || lowerText.contains('que ') ||
        lowerText.contains('cuáles') || lowerText.contains('cuales')) &&
        (lowerText.contains('falta') || lowerText.contains('tomar') ||
         lowerText.contains('tengo para'))) {
      return true;
    }

    return false;
  }

  // ============================================================
  // EXTRACCIÓN DE DATOS - COMANDOS
  // ============================================================

  ReminderType _detectType(String lowerText) {
    for (final entry in _typeKeywords.entries) {
      for (final keyword in entry.value) {
        if (lowerText.contains(keyword)) {
          return entry.key;
        }
      }
    }
    return ReminderType.task;
  }

  String _extractTitle(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return 'Recordatorio';

    final capitalized = trimmed[0].toUpperCase() + trimmed.substring(1);
    if (capitalized.length <= 60) return capitalized;

    final truncated = capitalized.substring(0, 60);
    final lastSpace = truncated.lastIndexOf(' ');
    if (lastSpace > 30) {
      return '${truncated.substring(0, lastSpace)}...';
    }
    return '$truncated...';
  }

  (String?, String?) _extractObjectAndLocation(String lowerText) {
    final patterns = [
      // "dejé/dejando/guardé/puse [objeto] en/bajo/sobre [ubicación]"
      RegExp(r'(?:dejé|deje|dejando|guardé|guarde|guardando|puse|poniendo|estoy dejando|estoy guardando|estoy poniendo)\s+(?:el|la|los|las|mis|mi)?\s*([\w\s]+?)\s+(?:en|bajo|encima de|dentro de|sobre)\s+(.+)'),
      // "[objeto] está en [ubicación]"
      RegExp(r'(?:el|la|los|las|mis|mi)?\s*([\w\s]+?)\s+(?:está|esta|están|estan)\s+(?:en|bajo|encima de|dentro de|sobre)\s+(.+)'),
      // "lo/la tengo en [ubicación]"
      RegExp(r'(?:lo|la|los|las)\s+tengo\s+(?:en|bajo|encima de|dentro de|sobre)\s+(.+)'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(lowerText);
      if (match != null) {
        if (match.groupCount >= 2) {
          return (_cleanText(match.group(1)), _cleanText(match.group(2)));
        } else if (match.groupCount == 1) {
          return (null, _cleanText(match.group(1)));
        }
      }
    }

    return (null, null);
  }

  DateTime? _extractDateTime(String lowerText) {
    final now = DateTime.now();

    // "a las X" o "a las X:XX"
    final timePattern = RegExp(r'a las? (\d{1,2})(?::(\d{2}))?(?:\s*(am|pm|de la mañana|de la tarde|de la noche))?');
    final timeMatch = timePattern.firstMatch(lowerText);
    if (timeMatch != null) {
      var hour = int.parse(timeMatch.group(1)!);
      final minutes = timeMatch.group(2) != null ? int.parse(timeMatch.group(2)!) : 0;
      final period = timeMatch.group(3);

      hour = _adjustHourForPeriod(hour, period);

      var scheduled = DateTime(now.year, now.month, now.day, hour, minutes);
      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }
      return scheduled;
    }

    // Hora en texto "a las tres"
    final textTimePattern = RegExp(r'a las? (una|uno|dos|tres|cuatro|cinco|seis|siete|ocho|nueve|diez|once|doce)(?:\s*(de la mañana|de la tarde|de la noche))?');
    final textTimeMatch = textTimePattern.firstMatch(lowerText);
    if (textTimeMatch != null) {
      var hour = _numberWords[textTimeMatch.group(1)] ?? 12;
      hour = _adjustHourForPeriod(hour, textTimeMatch.group(2));

      var scheduled = DateTime(now.year, now.month, now.day, hour, 0);
      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }
      return scheduled;
    }

    // "mañana"
    if (lowerText.contains('mañana') && !lowerText.contains('de la mañana')) {
      return DateTime(now.year, now.month, now.day + 1, 9, 0);
    }

    // "pasado mañana"
    if (lowerText.contains('pasado mañana')) {
      return DateTime(now.year, now.month, now.day + 2, 9, 0);
    }

    // "en X horas/minutos"
    final relativePattern = RegExp(r'en (\d+|una|uno|dos|tres|cuatro|cinco) (hora|horas|minuto|minutos)');
    final relativeMatch = relativePattern.firstMatch(lowerText);
    if (relativeMatch != null) {
      final amountStr = relativeMatch.group(1)!;
      final amount = _numberWords[amountStr] ?? int.tryParse(amountStr) ?? 1;
      final unit = relativeMatch.group(2)!;

      return unit.startsWith('hora')
          ? now.add(Duration(hours: amount))
          : now.add(Duration(minutes: amount));
    }

    // Día de la semana
    for (final entry in _weekDays.entries) {
      if (lowerText.contains(entry.key)) {
        var daysUntil = entry.value - now.weekday;
        if (daysUntil <= 0) daysUntil += 7;
        return DateTime(now.year, now.month, now.day + daysUntil, 9, 0);
      }
    }

    return null;
  }

  int _adjustHourForPeriod(int hour, String? period) {
    if (period != null) {
      if ((period == 'pm' || period == 'de la tarde' || period == 'de la noche') && hour < 12) {
        return hour + 12;
      } else if ((period == 'am' || period == 'de la mañana') && hour == 12) {
        return 0;
      }
    } else if (hour <= 6) {
      return hour + 12;
    }
    return hour;
  }

  // ============================================================
  // EXTRACCIÓN DE DATOS - CONSULTAS
  // ============================================================

  String? _extractSearchObject(String lowerText) {
    final patterns = [
      RegExp(r'(?:dónde|donde)\s+(?:dejé|deje|puse|guardé|guarde|tengo)\s+(?:el|la|los|las|mis|mi)?\s*(.+?)(?:\?|$)'),
      RegExp(r'(?:dónde|donde)\s+(?:está|esta|están|estan)\s+(?:el|la|los|las|mis|mi)?\s*(.+?)(?:\?|$)'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(lowerText);
      if (match != null && match.groupCount >= 1) {
        final extracted = match.group(1)?.trim();
        if (extracted != null && extracted.isNotEmpty) {
          return extracted
              .replaceAll(RegExp(r'\s+$'), '')
              .replaceAll(RegExp(r'^(el|la|los|las|mis|mi)\s+'), '');
        }
      }
    }

    return null;
  }

  String? _extractTimeFilter(String lowerText) {
    if (lowerText.contains('hoy')) return 'today';
    if (lowerText.contains('mañana') && !lowerText.contains('de la mañana')) return 'tomorrow';
    if (lowerText.contains('semana')) return 'week';
    return 'today'; // Por defecto buscar para hoy
  }

  /// Extrae el tipo de recordatorio y palabra clave de una consulta de horario
  (String?, String?) _extractScheduleSubject(String lowerText) {
    for (final entry in _scheduleSubjectKeywords.entries) {
      if (lowerText.contains(entry.key)) {
        return (entry.value, entry.key);
      }
    }
    return (null, null);
  }

  // ============================================================
  // UTILIDADES
  // ============================================================

  String? _cleanText(String? text) {
    if (text == null) return null;
    final cleaned = text.trim();
    if (cleaned.isEmpty) return null;
    return cleaned[0].toUpperCase() + cleaned.substring(1);
  }
}
