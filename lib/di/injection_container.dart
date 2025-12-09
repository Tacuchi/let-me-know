import 'package:get_it/get_it.dart';

/// Instancia global del contenedor de inyección de dependencias
final getIt = GetIt.instance;

/// Configura todas las dependencias de la aplicación
/// Debe llamarse antes de runApp()
Future<void> configureDependencies() async {
  // ============================================================
  // SERVICES (Externos)
  // ============================================================
  // TODO: Agregar servicios externos (speech_to_text, notifications, etc.)

  // ============================================================
  // DATA SOURCES
  // ============================================================
  // TODO: Agregar data sources locales y remotos

  // ============================================================
  // REPOSITORIES
  // ============================================================
  // TODO: Agregar implementaciones de repositorios

  // ============================================================
  // USE CASES
  // ============================================================
  // TODO: Agregar casos de uso

  // ============================================================
  // CUBITS / BLOCS
  // ============================================================
  // TODO: Agregar cubits y blocs
}

/// Resetea el contenedor (útil para testing)
Future<void> resetDependencies() async {
  await getIt.reset();
}

