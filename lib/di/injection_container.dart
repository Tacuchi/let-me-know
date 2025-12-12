import 'package:get_it/get_it.dart';

import 'package:let_me_know/core/database/drift/app_database.dart';
import 'package:let_me_know/features/history/application/cubit/history_cubit.dart';
import 'package:let_me_know/features/reminders/application/cubit/reminder_list_cubit.dart';
import 'package:let_me_know/features/reminders/application/cubit/reminder_summary_cubit.dart';
import 'package:let_me_know/features/reminders/domain/repositories/reminder_repository.dart';
import 'package:let_me_know/features/reminders/infrastructure/repositories/reminder_repository_drift_impl.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // Data Sources
  getIt.registerLazySingleton<AppDatabase>(() => AppDatabase());

  // Repositories
  getIt.registerLazySingleton<ReminderRepository>(
    () => ReminderRepositoryDriftImpl(getIt()),
  );

  // Cubits
  getIt.registerFactory(() => ReminderListCubit(getIt()));
  getIt.registerFactory(() => ReminderSummaryCubit(getIt()));
  getIt.registerFactory(() => HistoryCubit(getIt()));

  await getIt<AppDatabase>().customSelect('SELECT 1').getSingle();
}

Future<void> resetDependencies() async {
  await getIt.reset();
}
