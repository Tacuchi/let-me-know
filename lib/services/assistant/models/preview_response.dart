import 'assistant_response.dart';

/// Respuesta del endpoint /preview que puede contener múltiples previews.
class PreviewResponse {
  final List<PreviewItem> previews;
  final String spokenResponse;

  const PreviewResponse({
    required this.previews,
    required this.spokenResponse,
  });

  factory PreviewResponse.fromJson(Map<String, dynamic> json) {
    final previewsList = (json['previews'] as List<dynamic>?) ?? [];
    return PreviewResponse(
      previews: previewsList
          .map((e) => PreviewItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      spokenResponse: json['spokenResponse'] as String? ?? '',
    );
  }

  /// Verifica si todos los previews son de tipo PREVIEW_BATCH.
  bool get hasPreviewBatches =>
      previews.any((p) => p.action == AssistantAction.previewBatch);

  /// Verifica si algún preview necesita clarificación.
  bool get needsClarification =>
      previews.any((p) => p.action == AssistantAction.clarificationNeeded);

  /// Verifica si es NO_ACTION (item individual).
  bool get isNoAction =>
      previews.length == 1 && previews.first.action == AssistantAction.noAction;

  /// Obtiene solo los previews de batch.
  List<PreviewItem> get batchPreviews =>
      previews.where((p) => p.action == AssistantAction.previewBatch).toList();
}

/// Item individual de preview.
class PreviewItem {
  final AssistantAction action;
  final dynamic data;

  const PreviewItem({
    required this.action,
    required this.data,
  });

  factory PreviewItem.fromJson(Map<String, dynamic> json) {
    final actionStr = json['action'] as String;
    final action = _parseAction(actionStr);
    final data = _parseData(action, json['data']);

    return PreviewItem(action: action, data: data);
  }

  /// Datos tipados para PREVIEW_BATCH.
  PreviewData? get previewData =>
      action == AssistantAction.previewBatch ? data as PreviewData : null;

  /// Datos tipados para CLARIFICATION_NEEDED.
  ClarificationData? get clarificationData =>
      action == AssistantAction.clarificationNeeded
          ? data as ClarificationData
          : null;

  /// Datos tipados para NO_ACTION.
  NoActionData? get noActionData =>
      action == AssistantAction.noAction ? data as NoActionData : null;

  static AssistantAction _parseAction(String action) {
    return switch (action) {
      'PREVIEW_BATCH' => AssistantAction.previewBatch,
      'CLARIFICATION_NEEDED' => AssistantAction.clarificationNeeded,
      'NO_ACTION' => AssistantAction.noAction,
      _ => AssistantAction.noAction,
    };
  }

  static dynamic _parseData(AssistantAction action, dynamic json) {
    if (json == null) return null;
    final map = json as Map<String, dynamic>;

    return switch (action) {
      AssistantAction.previewBatch => PreviewData.fromJson(map),
      AssistantAction.clarificationNeeded => ClarificationData.fromJson(map),
      AssistantAction.noAction => NoActionData.fromJson(map),
      _ => null,
    };
  }
}
