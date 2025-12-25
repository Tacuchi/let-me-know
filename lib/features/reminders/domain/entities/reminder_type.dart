import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Tipos de recordatorio detectados por el parser
/// Cada tipo tiene asociado un ícono, color y características específicas
enum ReminderType {
  /// Medicamentos, pastillas - Alta prioridad, notificación crítica
  medication,

  /// Citas médicas, doctores - Alta prioridad
  appointment,

  /// Llamadas telefónicas - Prioridad media
  call,

  /// Compras, lista de compras - Prioridad baja
  shopping,

  /// Tareas generales - Prioridad media
  task,

  /// Eventos, reuniones, celebraciones - Prioridad media
  event,

  /// Nota de ubicación / objeto (sin fecha, sin notificación)
  location,
}

/// Extensión para obtener información visual y semántica del tipo de recordatorio
extension ReminderTypeExtension on ReminderType {
  /// Si este tipo representa una nota (sin fecha/alarma)
  bool get isNote => this == ReminderType.location;

  /// Nombre legible del tipo
  String get displayName {
    return switch (this) {
      ReminderType.medication => 'Medicamento',
      ReminderType.appointment => 'Cita',
      ReminderType.call => 'Llamada',
      ReminderType.shopping => 'Compras',
      ReminderType.task => 'Tarea',
      ReminderType.event => 'Evento',
      ReminderType.location => 'Nota',
    };
  }

  /// Etiqueta corta del tipo (alias de displayName)
  String get label => displayName;

  /// Emoji asociado al tipo
  String get emoji {
    return switch (this) {
      ReminderType.medication => '💊',
      ReminderType.appointment => '📅',
      ReminderType.call => '📞',
      ReminderType.shopping => '🛒',
      ReminderType.task => '✅',
      ReminderType.event => '🎉',
      ReminderType.location => '📌',
    };
  }

  /// Ícono Material asociado al tipo (centralizado para todas las vistas)
  IconData get icon {
    return switch (this) {
      ReminderType.medication => Icons.medication_rounded,
      ReminderType.appointment => Icons.calendar_month_rounded,
      ReminderType.call => Icons.call_rounded,
      ReminderType.shopping => Icons.shopping_bag_rounded,
      ReminderType.task => Icons.check_circle_outline_rounded,
      ReminderType.event => Icons.celebration_rounded,
      ReminderType.location => Icons.push_pin_rounded,
    };
  }

  /// Color asociado al tipo (centralizado para todas las vistas)
  Color get color {
    return switch (this) {
      ReminderType.medication => AppColors.reminderMedication,
      ReminderType.appointment => AppColors.reminderAppointment,
      ReminderType.call => AppColors.reminderCall,
      ReminderType.shopping => AppColors.reminderShopping,
      ReminderType.task => AppColors.reminderTask,
      ReminderType.event => AppColors.reminderEvent,
      ReminderType.location => AppColors.reminderLocation,
    };
  }

  /// Color de fondo suave para el tipo (15% opacidad)
  Color get backgroundColor => color.withValues(alpha: 0.15);
}
