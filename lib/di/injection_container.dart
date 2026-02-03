import 'package:get_it/get_it.dart';

import 'package:let_me_know/core/database/drift/app_database.dart';
import 'package:let_me_know/features/history/application/cubit/history_cubit.dart';
import 'package:let_me_know/features/notes/application/cubit/notes_cubit.dart';
import 'package:let_me_know/features/reminders/application/cubit/reminder_detail_cubit.dart';
import 'package:let_me_know/features/reminders/application/cubit/reminder_list_cubit.dart';
import 'package:let_me_know/features/reminders/application/cubit/reminder_summary_cubit.dart';
import 'package:let_me_know/features/reminders/domain/repositories/reminder_repository.dart';
import 'package:let_me_know/features/reminders/infrastructure/repositories/reminder_repository_drift_impl.dart';
import 'package:let_me_know/services/assistant/assistant_api_client.dart';
import 'package:let_me_know/services/assistant/voice_assistant_service.dart';
import 'package:let_me_know/services/assistant/voice_assistant_service_impl.dart';
import 'package:let_me_know/services/notifications/notification_service.dart';
import 'package:let_me_know/services/notifications/notification_service_impl.dart';
import 'package:let_me_know/services/query/query_service.dart';
import 'package:let_me_know/services/query/query_service_impl.dart';
import 'package:let_me_know/services/speech_to_text/speech_to_text_service.dart';
import 'package:let_me_know/services/speech_to_text/speech_to_text_service_impl.dart';
import 'package:let_me_know/services/transcription/transcription_analyzer.dart';
import 'package:let_me_know/services/transcription/local_transcription_analyzer.dart';
import 'package:let_me_know/services/tts/tts_service.dart';
import 'package:let_me_know/services/tts/tts_service_impl.dart';
import 'package:let_me_know/core/services/feedback_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // Core / External
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  getIt.registerLazySingleton<FeedbackService>(
    () => FeedbackService(getIt()),
  );

  // Services
  getIt.registerLazySingleton<NotificationService>(
    () => NotificationServiceImpl(),
  );
  getIt.registerLazySingleton<SpeechToTextService>(
    () => SpeechToTextServiceImpl(),
  );

  // Transcription Analyzer - intercambiable por LLM en el futuro
  // Para usar LLM: reemplazar LocalTranscriptionAnalyzer por LlmTranscriptionAnalyzer
  getIt.registerLazySingleton<TranscriptionAnalyzer>(
    () => LocalTranscriptionAnalyzer(),
  );

  // Text-to-Speech Service
  getIt.registerLazySingleton<TtsService>(
    () => TtsServiceImpl(),
  );

  // Data Sources
  getIt.registerLazySingleton<AppDatabase>(() => AppDatabase());

  // Repositories
  getIt.registerLazySingleton<ReminderRepository>(
    () => ReminderRepositoryDriftImpl(getIt()),
  );

  // Voice Assistant (Backend LLM) - depende de ReminderRepository
  getIt.registerLazySingleton<AssistantApiClient>(
    () => AssistantApiClient(),
  );
  getIt.registerLazySingleton<VoiceAssistantService>(
    () => VoiceAssistantServiceImpl(
      getIt<AssistantApiClient>(),
      getIt<ReminderRepository>(),
    ),
  );

  // Query Service
  getIt.registerLazySingleton<QueryService>(
    () => QueryServiceImpl(getIt<ReminderRepository>(), getIt<TranscriptionAnalyzer>()),
  );

  // Cubits
  getIt.registerFactory(() => ReminderListCubit(getIt()));
  getIt.registerFactory(() => ReminderSummaryCubit(getIt()));
  getIt.registerFactory(() => ReminderDetailCubit(getIt()));
  getIt.registerFactory(() => HistoryCubit(getIt()));
  getIt.registerFactory(() => NotesCubit(getIt()));

  await getIt<AppDatabase>().customSelect('SELECT 1').getSingle();
}

Future<void> resetDependencies() async {
  await getIt.reset();
}
