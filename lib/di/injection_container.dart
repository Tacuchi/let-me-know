import 'package:get_it/get_it.dart';

import 'package:let_me_know/core/database/drift/app_database.dart';
import 'package:let_me_know/features/history/application/cubit/history_cubit.dart';
import 'package:let_me_know/features/reminders/application/cubit/reminder_list_cubit.dart';
import 'package:let_me_know/features/reminders/application/cubit/reminder_summary_cubit.dart';
import 'package:let_me_know/features/reminders/domain/repositories/reminder_repository.dart';
import 'package:let_me_know/features/reminders/infrastructure/repositories/reminder_repository_drift_impl.dart';

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
  // Base de datos local (Drift sobre SQLite)
  getIt.registerLazySingleton<AppDatabase>(() => AppDatabase());

  // ============================================================
  // REPOSITORIES
  // ============================================================
  getIt.registerLazySingleton<ReminderRepository>(
    () => ReminderRepositoryDriftImpl(getIt()),
  );

  // ============================================================
  // USE CASES
  // ============================================================
  // TODO: Agregar casos de uso

  // ============================================================
  // CUBITS / BLOCS
  // ============================================================
  getIt.registerFactory(() => ReminderListCubit(getIt()));
  getIt.registerFactory(() => ReminderSummaryCubit(getIt()));
  getIt.registerFactory(() => HistoryCubit(getIt()));

  // Pre-calentar la base de datos para detectar errores temprano.
  // (Opcional pero útil en desarrollo)
  await getIt<AppDatabase>().customSelect('SELECT 1').getSingle();
}

/// Resetea el contenedor (útil para testing)
Future<void> resetDependencies() async {
  await getIt.reset();
}
