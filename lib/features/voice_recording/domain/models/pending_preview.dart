import 'package:equatable/equatable.dart';

import '../../../../services/assistant/models/assistant_response.dart';

/// Un preview de batch pendiente de confirmar.
/// 
/// Representa un batch que aún no ha sido creado - solo tenemos el resumen
/// del LLM. Al "Finalizar", se enviará [originalRequest] al endpoint /process
/// para crear los items reales.
class PendingPreview extends Equatable {
  /// ID local para tracking.
  final String id;

  /// Resumen del batch (ej: "60 recordatorios de Losartán").
  final String summary;

  /// Label del grupo (ej: "Tratamiento Losartán").
  final String groupLabel;

  /// Cantidad estimada de items que se crearán.
  final int estimatedCount;

  /// Frecuencia (ej: "cada 12 horas").
  final String frequency;

  /// Rango de fechas (ej: "4 feb - 6 mar 2026").
  final String dateRange;

  /// Transcripción original para re-enviar a /process al confirmar.
  final String originalRequest;

  /// Texto hablado por TTS al mostrar el preview.
  final String spokenResponse;

  final DateTime addedAt;

  const PendingPreview({
    required this.id,
    required this.summary,
    required this.groupLabel,
    required this.estimatedCount,
    required this.frequency,
    required this.dateRange,
    required this.originalRequest,
    required this.spokenResponse,
    required this.addedAt,
  });

  /// Crea un PendingPreview desde PreviewData del LLM.
  factory PendingPreview.fromPreviewData({
    required String id,
    required PreviewData data,
    required String spokenResponse,
  }) {
    return PendingPreview(
      id: id,
      summary: data.summary,
      groupLabel: data.groupLabel,
      estimatedCount: data.estimatedCount,
      frequency: data.frequency,
      dateRange: data.dateRange,
      originalRequest: data.originalRequest,
      spokenResponse: spokenResponse,
      addedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        summary,
        groupLabel,
        estimatedCount,
        frequency,
        dateRange,
        originalRequest,
        spokenResponse,
        addedAt,
      ];
}
