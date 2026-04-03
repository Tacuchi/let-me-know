import '../../features/groups/domain/repositories/group_repository.dart';
import '../../features/reminders/domain/entities/reminder.dart';
import '../../features/reminders/domain/entities/reminder_status.dart';
import '../../features/reminders/domain/entities/reminder_type.dart';
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
  /// Solo incluye recordatorios activos (pending/overdue) y notas de ubicación.
  /// Los recordatorios agrupados se compactan en un único representante por grupo.
  Future<List<MemoryItem>> _buildMemory() async {
    try {
      final reminders = await _reminderRepository.getAll();
      final groups = await _groupRepository.getAll();

      final groupLabels = {
        for (final group in groups) group.id: group.label,
      };

      // Filter: only active reminders + location notes
      final filtered = reminders
          .where((r) => r.status.isActive || r.type == ReminderType.location)
          .toList();

      // Separate grouped vs individual
      final grouped = <String, List<Reminder>>{};
      final individual = <Reminder>[];

      for (final r in filtered) {
        if (r.recurrenceGroupId != null) {
          grouped.putIfAbsent(r.recurrenceGroupId!, () => []).add(r);
        } else {
          individual.add(r);
        }
      }

      final result = <MemoryItem>[];

      // Add individual items
      for (final r in individual) {
        final label = r.recurrenceGroupId != null
            ? groupLabels[r.recurrenceGroupId]
            : null;
        result.add(MemoryItem.fromReminder(r, groupLabel: label));
      }

      // Add one representative per group
      for (final entry in grouped.entries) {
        final groupId = entry.key;
        final items = entry.value;
        final label = groupLabels[groupId];

        // Collect distinct medication names (titles)
        final titles = items.map((r) => r.title).toSet().toList();
        final compactTitle = '${titles.join(', ')} (${items.length} items)';

        // Find nearest scheduledAt
        final scheduled = items
            .where((r) => r.scheduledAt != null)
            .toList()
          ..sort((a, b) => a.scheduledAt!.compareTo(b.scheduledAt!));
        final nearestScheduled =
            scheduled.isNotEmpty ? scheduled.first.scheduledAt : null;

        result.add(MemoryItem.groupRepresentative(
          id: items.first.id,
          compactTitle: compactTitle,
          baseReminder: items.first,
          nearestScheduledAt: nearestScheduled,
          groupId: groupId,
          groupLabel: label,
        ));
      }

      return result;
    } catch (_) {
      return [];
    }
  }
}
