import 'package:equatable/equatable.dart';

import '../../../reminders/domain/entities/reminder.dart';

sealed class HistoryState extends Equatable {
  const HistoryState();

  @override
  List<Object?> get props => const [];
}

final class HistoryLoading extends HistoryState {
  const HistoryLoading();
}

final class HistoryLoaded extends HistoryState {
  /// Recordatorios completados (ordenados desc por completedAt).
  final List<Reminder> completed;

  /// Cantidad completada en el mes actual.
  final int completedThisMonth;

  /// Total completados.
  final int completedTotal;

  const HistoryLoaded({
    required this.completed,
    required this.completedThisMonth,
    required this.completedTotal,
  });

  @override
  List<Object?> get props => [completed, completedThisMonth, completedTotal];
}

final class HistoryError extends HistoryState {
  final String message;

  const HistoryError(this.message);

  @override
  List<Object?> get props => [message];
}
