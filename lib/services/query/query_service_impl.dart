import '../../features/reminders/domain/entities/reminder.dart';
import '../../features/reminders/domain/entities/reminder_status.dart';
import '../../features/reminders/domain/repositories/reminder_repository.dart';
import '../transcription/transcription_analyzer.dart';
import 'query_service.dart';

/// Implementación del servicio de consultas.
///
/// Usa [TranscriptionAnalyzer] para analizar las consultas de voz,
/// permitiendo intercambiar la implementación (local vs LLM).
class QueryServiceImpl implements QueryService {
  final ReminderRepository _repository;
  final TranscriptionAnalyzer _analyzer;

  QueryServiceImpl(this._repository, this._analyzer);

  @override
  Future<QueryResult> processQuery(String transcription) async {
    final text = transcription.trim();
    if (text.isEmpty) {
      return const QueryResult(
        type: QueryType.notUnderstood,
        response: 'No escuché nada. ¿Puedes repetir?',
      );
    }

    // Analizar la transcripción usando el analizador (local o LLM)
    final analysis = await _analyzer.analyzeQuery(text);

    // Si es un comando de creación, no es una consulta
    if (analysis.isCommand) {
      return const QueryResult(
        type: QueryType.notAQuery,
        response: 'Esto parece un recordatorio, no una consulta.',
      );
    }

    // Obtener alertas próximas para incluir en la respuesta
    final upcomingAlerts = await getUpcomingAlerts();

    // Procesar según el tipo de consulta detectado
    switch (analysis.intent) {
      case TranscriptionIntent.queryLocation:
        return _processLocationQuery(analysis, upcomingAlerts);
      case TranscriptionIntent.queryReminders:
        return _processReminderQuery(analysis, upcomingAlerts);
      case TranscriptionIntent.querySchedule:
        return _processScheduleQuery(analysis, upcomingAlerts);
      default:
        return QueryResult(
          type: QueryType.notUnderstood,
          response: 'No entendí tu pregunta. Puedes preguntar cosas como "¿Dónde dejé mis llaves?", "¿A qué hora me tocan las pastillas?" o "¿Qué tengo pendiente?"',
          upcomingAlerts: upcomingAlerts.isNotEmpty ? upcomingAlerts : null,
        );
    }
  }

  Future<QueryResult> _processLocationQuery(
    QueryAnalysis analysis,
    List<Reminder> upcomingAlerts,
  ) async {
    final searchObject = analysis.searchObject;

    if (searchObject == null || searchObject.isEmpty) {
      return QueryResult(
        type: QueryType.locationQuery,
        response: 'No entendí qué objeto estás buscando. Intenta decir "¿Dónde dejé mis llaves?"',
        upcomingAlerts: upcomingAlerts.isNotEmpty ? upcomingAlerts : null,
      );
    }

    // Buscar en notas
    final notes = await _repository.searchNotes(searchObject);

    if (notes.isEmpty) {
      return QueryResult(
        type: QueryType.locationQuery,
        response: 'No tengo registro de dónde dejaste "$searchObject".',
        upcomingAlerts: upcomingAlerts.isNotEmpty ? upcomingAlerts : null,
      );
    }

    // Encontramos coincidencias
    final bestMatch = notes.first;
    final response = _buildLocationResponse(bestMatch, searchObject);

    return QueryResult(
      type: QueryType.locationQuery,
      response: response,
      relatedItems: notes,
      upcomingAlerts: upcomingAlerts.isNotEmpty ? upcomingAlerts : null,
    );
  }

  String _buildLocationResponse(Reminder note, String searchObject) {
    if (note.location != null && note.location!.isNotEmpty) {
      final object = note.object ?? searchObject;
      return '$object está en ${note.location}.';
    }

    // Fallback a la descripción
    return note.description.isNotEmpty
        ? note.description
        : 'Encontré una nota sobre "$searchObject" pero no tiene ubicación específica.';
  }

  Future<QueryResult> _processReminderQuery(
    QueryAnalysis analysis,
    List<Reminder> upcomingAlerts,
  ) async {
    List<Reminder> reminders;
    String responsePrefix;

    // Usar el filtro de tiempo del análisis
    if (analysis.timeFilter == 'today') {
      reminders = await _repository.getForToday();
      reminders = reminders
          .where((r) => r.status == ReminderStatus.pending)
          .toList();
      responsePrefix = 'Para hoy';
    } else {
      reminders = await _repository.getByStatus(ReminderStatus.pending);
      responsePrefix = 'Pendientes';
    }

    if (reminders.isEmpty) {
      return QueryResult(
        type: QueryType.reminderQuery,
        response: '$responsePrefix: No tienes recordatorios pendientes.',
        upcomingAlerts: upcomingAlerts.isNotEmpty ? upcomingAlerts : null,
      );
    }

    final response = _buildReminderListResponse(reminders, responsePrefix);

    return QueryResult(
      type: QueryType.reminderQuery,
      response: response,
      relatedItems: reminders,
      upcomingAlerts: upcomingAlerts.isNotEmpty ? upcomingAlerts : null,
    );
  }

  String _buildReminderListResponse(List<Reminder> reminders, String prefix) {
    if (reminders.length == 1) {
      return '$prefix: Tienes 1 recordatorio - "${reminders.first.title}"';
    }

    final count = reminders.length;
    final firstThree = reminders.take(3).map((r) => r.title).join(', ');

    if (count <= 3) {
      return '$prefix: Tienes $count recordatorios - $firstThree';
    }

    return '$prefix: Tienes $count recordatorios. Los próximos son: $firstThree...';
  }

  /// Procesa consultas de horario: "¿A qué hora me tocan las pastillas?"
  Future<QueryResult> _processScheduleQuery(
    QueryAnalysis analysis,
    List<Reminder> upcomingAlerts,
  ) async {
    // Obtener recordatorios según filtro de tiempo
    List<Reminder> reminders;
    String timePeriod;

    switch (analysis.timeFilter) {
      case 'tomorrow':
        reminders = await _repository.getForTomorrow();
        timePeriod = 'mañana';
        break;
      case 'week':
        reminders = await _repository.getForWeek();
        timePeriod = 'esta semana';
        break;
      default:
        reminders = await _repository.getForToday();
        timePeriod = 'hoy';
    }

    // Filtrar por estado pendiente
    reminders = reminders.where((r) => r.status == ReminderStatus.pending).toList();

    // Filtrar por tipo si se especificó
    if (analysis.reminderTypeFilter != null) {
      reminders = reminders.where((r) => r.type.name == analysis.reminderTypeFilter).toList();
    }

    // Filtrar por palabra clave si se especificó
    if (analysis.subjectKeyword != null && reminders.isNotEmpty) {
      final keyword = analysis.subjectKeyword!.toLowerCase();
      final filtered = reminders.where((r) =>
          r.title.toLowerCase().contains(keyword) ||
          r.description.toLowerCase().contains(keyword)).toList();
      if (filtered.isNotEmpty) {
        reminders = filtered;
      }
    }

    if (reminders.isEmpty) {
      final subject = analysis.subjectKeyword ?? 'recordatorios';
      return QueryResult(
        type: QueryType.scheduleQuery,
        response: 'No tienes $subject programados para $timePeriod.',
        upcomingAlerts: upcomingAlerts.isNotEmpty ? upcomingAlerts : null,
      );
    }

    // Construir respuesta con horarios
    final response = _buildScheduleResponse(reminders, analysis.subjectKeyword, timePeriod);

    return QueryResult(
      type: QueryType.scheduleQuery,
      response: response,
      relatedItems: reminders,
      upcomingAlerts: upcomingAlerts.isNotEmpty ? upcomingAlerts : null,
    );
  }

  String _buildScheduleResponse(List<Reminder> reminders, String? subject, String timePeriod) {
    final subjectName = subject ?? 'recordatorios';

    if (reminders.length == 1) {
      final r = reminders.first;
      final timeStr = _formatTime(r.scheduledAt);
      return 'Tienes "${r.title}" $timeStr.';
    }

    // Múltiples recordatorios
    final buffer = StringBuffer();
    buffer.write('Tienes ${reminders.length} $subjectName para $timePeriod:\n');

    for (final r in reminders.take(5)) {
      final timeStr = _formatTime(r.scheduledAt);
      buffer.write('• ${r.title} - $timeStr\n');
    }

    if (reminders.length > 5) {
      buffer.write('... y ${reminders.length - 5} más');
    }

    return buffer.toString().trim();
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return 'sin hora';
    final hour = dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return 'a las $displayHour:$minute $period';
  }

  @override
  Future<List<Reminder>> getUpcomingAlerts({
    Duration within = const Duration(hours: 2),
  }) async {
    return _repository.getUpcomingAlerts(within: within);
  }
}
