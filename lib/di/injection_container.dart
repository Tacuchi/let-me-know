import 'package:get_it/get_it.dart';

import 'package:let_me_know/core/database/database_helper.dart';
import 'package:let_me_know/features/history/application/cubit/history_cubit.dart';
import 'package:let_me_know/features/reminders/application/cubit/reminder_list_cubit.dart';
import 'package:let_me_know/features/reminders/application/cubit/reminder_summary_cubit.dart';
import 'package:let_me_know/features/reminders/domain/repositories/reminder_repository.dart';
import 'package:let_me_know/features/reminders/infrastructure/datasources/local_reminder_datasource.dart';
import 'package:let_me_know/features/reminders/infrastructure/repositories/reminder_repository_impl.dart';

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
  // Base de datos local (SQLite)
  getIt.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper());

  // Recordatorios (SQLite)
  getIt.registerLazySingleton<LocalReminderDataSource>(
    () => LocalReminderDataSource(getIt()),
  );

  // ============================================================
  // REPOSITORIES
  // ============================================================
  getIt.registerLazySingleton<ReminderRepository>(
    () => ReminderRepositoryImpl(getIt()),
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
  await getIt<DatabaseHelper>().database;
}

/// Resetea el contenedor (útil para testing)
Future<void> resetDependencies() async {
  await getIt.reset();
}
