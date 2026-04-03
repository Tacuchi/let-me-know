/// Definición de rutas de la aplicación
/// Centraliza los paths y nombres para evitar errores de typos
abstract final class AppRoutes {
  // Paths
  static const String home = '/';
  static const String reminders = '/reminders';
  static const String reminderDetail = '/reminders/:id';
  static const String alarm = '/alarm/:id';
  static const String settings = '/settings';
  static const String designShowcase = '/design-showcase';

  // Names (para navegación nombrada)
  static const String chatName = 'chat';
  static const String remindersName = 'reminders';
  static const String reminderDetailName = 'reminder-detail';
  static const String alarmName = 'alarm';
  static const String settingsName = 'settings';
  static const String designShowcaseName = 'design-showcase';
}
