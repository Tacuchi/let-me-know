import 'package:intl/intl.dart';

/// Extensiones para DateTime que facilitan el formateo y comparación
extension DateExtensions on DateTime {
  /// Formatea la fecha como "Lunes, 9 de Diciembre"
  String get formattedLong {
    final formatter = DateFormat("EEEE, d 'de' MMMM", 'es_ES');
    return formatter.format(this);
  }

  /// Formatea la fecha como "9 dic"
  String get formattedShort {
    final formatter = DateFormat('d MMM', 'es_ES');
    return formatter.format(this);
  }

  /// Formatea la hora como "8:00:30 AM" (con segundos si no son cero)
  String get formattedTime {
    final formatter = second == 0
        ? DateFormat('h:mm a', 'es_ES')
        : DateFormat('h:mm:ss a', 'es_ES');
    return formatter.format(this);
  }

  /// Formatea como "Hoy, 8:00 AM" o "Mañana, 8:00 AM" o "9 dic, 8:00 AM"
  String get formattedRelative {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final date = DateTime(year, month, day);

    if (date == today) {
      return 'Hoy, $formattedTime';
    } else if (date == tomorrow) {
      return 'Mañana, $formattedTime';
    } else {
      return '$formattedShort, $formattedTime';
    }
  }

  /// Verifica si la fecha es hoy
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Verifica si la fecha es mañana
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  /// Verifica si la fecha ya pasó
  bool get isPast => isBefore(DateTime.now());

  /// Verifica si la fecha es en el futuro
  bool get isFuture => isAfter(DateTime.now());

  /// Retorna el inicio del día (00:00:00)
  DateTime get startOfDay => DateTime(year, month, day);

  /// Retorna el fin del día (23:59:59)
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59);

  /// Diferencia en horas desde ahora
  int get hoursFromNow => difference(DateTime.now()).inHours;

  /// Diferencia en minutos desde ahora
  int get minutesFromNow => difference(DateTime.now()).inMinutes;
}
