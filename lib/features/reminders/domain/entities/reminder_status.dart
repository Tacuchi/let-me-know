/// Estado de un recordatorio
enum ReminderStatus {
  /// Recordatorio pendiente de completar
  pending,

  /// Recordatorio completado
  completed,

  /// Recordatorio cancelado
  cancelled,

  /// Recordatorio vencido (pasó la fecha/hora sin completarse)
  overdue,
}

/// Extensión para obtener información del estado
extension ReminderStatusExtension on ReminderStatus {
  /// Nombre legible del estado
  String get displayName {
    return switch (this) {
      ReminderStatus.pending => 'Pendiente',
      ReminderStatus.completed => 'Completado',
      ReminderStatus.cancelled => 'Cancelado',
      ReminderStatus.overdue => 'Vencido',
    };
  }

  /// Etiqueta corta del estado
  String get label => displayName;

  /// Verifica si el recordatorio está activo (pendiente o vencido)
  bool get isActive =>
      this == ReminderStatus.pending || this == ReminderStatus.overdue;

  /// Verifica si el recordatorio está terminado (completado o cancelado)
  bool get isDone =>
      this == ReminderStatus.completed || this == ReminderStatus.cancelled;
}
