import 'package:equatable/equatable.dart';

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

  const ReminderSummaryLoaded({
    required this.pending,
    required this.overdue,
    required this.completed,
  });

  @override
  List<Object?> get props => [pending, overdue, completed];
}

final class ReminderSummaryError extends ReminderSummaryState {
  final String message;

  const ReminderSummaryError(this.message);

  @override
  List<Object?> get props => [message];
}
