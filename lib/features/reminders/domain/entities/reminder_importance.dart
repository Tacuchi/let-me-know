/// Importancia/prioridad del recordatorio.
///
/// Se usará para notificaciones inteligentes y UI.
enum ReminderImportance { high, medium, low, info }

extension ReminderImportanceX on ReminderImportance {
  String get label {
    return switch (this) {
      ReminderImportance.high => 'Alta',
      ReminderImportance.medium => 'Media',
      ReminderImportance.low => 'Baja',
      ReminderImportance.info => 'Info',
    };
  }
}
