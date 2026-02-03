import '../../features/reminders/domain/repositories/reminder_repository.dart';
import 'assistant_api_client.dart';
import 'models/assistant_request.dart';
import 'models/assistant_response.dart';
import 'models/memory_item.dart';
import 'voice_assistant_service.dart';

/// Implementación del servicio de asistente de voz.
class VoiceAssistantServiceImpl implements VoiceAssistantService {
  final AssistantApiClient _apiClient;
  final ReminderRepository _reminderRepository;

  VoiceAssistantServiceImpl(this._apiClient, this._reminderRepository);

  @override
  Future<AssistantResponse> process(String transcription) async {
    final memory = await _buildMemory();
    final request = AssistantRequest(
      transcription: transcription,
      currentTime: DateTime.now().toUtc().toIso8601String(),
      locale: 'es',
      memory: memory,
    );

    return _apiClient.process(request);
  }

  @override
  Future<bool> isAvailable() => _apiClient.healthCheck();

  /// Construye la memoria a partir de los recordatorios existentes.
  Future<List<MemoryItem>> _buildMemory() async {
    try {
      final reminders = await _reminderRepository.getAll();
      return reminders.map(MemoryItem.fromReminder).toList();
    } catch (_) {
      return [];
    }
  }
}
