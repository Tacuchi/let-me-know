import '../../features/groups/domain/repositories/group_repository.dart';
import '../../features/reminders/domain/repositories/reminder_repository.dart';
import 'assistant_api_client.dart';
import 'models/assistant_request.dart';
import 'models/assistant_response.dart';
import 'models/memory_item.dart';
import 'models/preview_request.dart';
import 'models/preview_response.dart';
import 'voice_assistant_service.dart';

/// Implementación del servicio de asistente de voz.
class VoiceAssistantServiceImpl implements VoiceAssistantService {
  final AssistantApiClient _apiClient;
  final ReminderRepository _reminderRepository;
  final GroupRepository _groupRepository;

  VoiceAssistantServiceImpl(
    this._apiClient,
    this._reminderRepository,
    this._groupRepository,
  );

  @override
  Future<AssistantResponse> process(
    String transcription, {
    List<Map<String, dynamic>> sessionItems = const [],
    List<Map<String, String>> conversationHistory = const [],
  }) async {
    final memory = await _buildMemory();
    final request = AssistantRequest(
      transcription: transcription,
      currentTime: _getLocalTime(),
      locale: 'es',
      memory: memory,
      sessionItems: sessionItems,
      conversationHistory: conversationHistory,
    );

    return _apiClient.process(request);
  }

  String _getLocalTime() {
    return DateTime.now().toIso8601String().split('.').first;
  }

  @override
  Future<PreviewResponse> preview(
    String transcription, {
    List<Map<String, String>> conversationHistory = const [],
  }) async {
    final request = PreviewRequest(
      transcription: transcription,
      currentTime: _getLocalTime(),
      locale: 'es',
      conversationHistory: conversationHistory,
    );

    return _apiClient.preview(request);
  }

  @override
  Future<bool> isAvailable() => _apiClient.healthCheck();

  /// Construye la memoria a partir de los recordatorios existentes.
  Future<List<MemoryItem>> _buildMemory() async {
    try {
      final reminders = await _reminderRepository.getAll();
      final groups = await _groupRepository.getAll();
      
      // Crear un mapa de groupId -> groupLabel
      final groupLabels = {
        for (final group in groups) group.id: group.label,
      };
      
      return reminders.map((r) {
        final label = r.recurrenceGroupId != null
            ? groupLabels[r.recurrenceGroupId]
            : null;
        return MemoryItem.fromReminder(r, groupLabel: label);
      }).toList();
    } catch (_) {
      return [];
    }
  }
}
