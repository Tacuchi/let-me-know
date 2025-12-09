/// Definición de rutas de la aplicación
/// Centraliza los paths y nombres para evitar errores de typos
abstract final class AppRoutes {
  // Paths
  static const String home = '/';
  static const String reminders = '/reminders';
  static const String reminderDetail = '/reminders/:id';
  static const String record = '/record';
  static const String history = '/history';
  static const String settings = '/settings';

  // Names (para navegación nombrada)
  static const String homeName = 'home';
  static const String remindersName = 'reminders';
  static const String reminderDetailName = 'reminder-detail';
  static const String recordName = 'record';
  static const String historyName = 'history';
  static const String settingsName = 'settings';
}

