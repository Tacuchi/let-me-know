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

  String get displayName => label;
}
