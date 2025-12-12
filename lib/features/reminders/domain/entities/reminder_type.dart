/// Tipos de recordatorio detectados por el LLM
/// Cada tipo tiene asociado un ícono y color
enum ReminderType {
  /// Medicamentos, pastillas
  medication,

  /// Citas médicas, doctores
  appointment,

  /// Llamadas telefónicas
  call,

  /// Compras, lista de compras
  shopping,

  /// Tareas generales
  task,

  /// Eventos, reuniones
  event,

  /// Nota de ubicación / objeto (sin fecha)
  location,
}

/// Extensión para obtener información del tipo de recordatorio
extension ReminderTypeExtension on ReminderType {
  /// Nombre legible del tipo
  String get displayName {
    return switch (this) {
      ReminderType.medication => 'Medicamento',
      ReminderType.appointment => 'Cita médica',
      ReminderType.call => 'Llamada',
      ReminderType.shopping => 'Compras',
      ReminderType.task => 'Tarea',
      ReminderType.event => 'Evento',
      ReminderType.location => 'Ubicación',
    };
  }

  /// Etiqueta corta del tipo (alias de displayName)
  String get label => displayName;

  /// Emoji asociado al tipo
  String get emoji {
    return switch (this) {
      ReminderType.medication => '💊',
      ReminderType.appointment => '🏥',
      ReminderType.call => '📞',
      ReminderType.shopping => '🛒',
      ReminderType.task => '📝',
      ReminderType.event => '📅',
      ReminderType.location => '📍',
    };
  }
}
