import 'package:equatable/equatable.dart';

import '../../domain/entities/reminder.dart';

sealed class ReminderDetailState extends Equatable {
  const ReminderDetailState();

  @override
  List<Object?> get props => [];
}

final class ReminderDetailInitial extends ReminderDetailState {
  const ReminderDetailInitial();
}

final class ReminderDetailLoading extends ReminderDetailState {
  const ReminderDetailLoading();
}

final class ReminderDetailLoaded extends ReminderDetailState {
  final Reminder reminder;

  const ReminderDetailLoaded(this.reminder);

  @override
  List<Object?> get props => [reminder];
}

final class ReminderDetailNotFound extends ReminderDetailState {
  const ReminderDetailNotFound();
}

final class ReminderDetailError extends ReminderDetailState {
  final String message;

  const ReminderDetailError(this.message);

  @override
  List<Object?> get props => [message];
}

final class ReminderDetailDeleted extends ReminderDetailState {
  const ReminderDetailDeleted();
}

final class ReminderDetailCompleted extends ReminderDetailState {
  const ReminderDetailCompleted();
}

final class ReminderDetailSnoozed extends ReminderDetailState {
  final DateTime newTime;

  const ReminderDetailSnoozed(this.newTime);

  @override
  List<Object?> get props => [newTime];
}
