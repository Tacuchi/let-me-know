import 'package:equatable/equatable.dart';

import '../../domain/entities/reminder.dart';

sealed class ReminderSummaryState extends Equatable {
  const ReminderSummaryState();

  @override
  List<Object?> get props => const [];
}

final class ReminderSummaryLoading extends ReminderSummaryState {
  const ReminderSummaryLoading();
}

final class ReminderSummaryLoaded extends ReminderSummaryState {
  final int pending;
  final int overdue;
  final int completed;
  final List<Reminder> upcoming;

  /// Recordatorios que vencen en las próximas 2 horas.
  final List<Reminder> imminentAlerts;

  const ReminderSummaryLoaded({
    required this.pending,
    required this.overdue,
    required this.completed,
    this.upcoming = const [],
    this.imminentAlerts = const [],
  });

  @override
  List<Object?> get props => [pending, overdue, completed, upcoming, imminentAlerts];
}

final class ReminderSummaryError extends ReminderSummaryState {
  final String message;

  const ReminderSummaryError(this.message);

  @override
  List<Object?> get props => [message];
}
