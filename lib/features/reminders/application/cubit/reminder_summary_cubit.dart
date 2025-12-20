import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../domain/entities/reminder.dart';
import '../../domain/entities/reminder_status.dart';
import '../../domain/repositories/reminder_repository.dart';
import 'reminder_summary_state.dart';

class ReminderSummaryCubit extends Cubit<ReminderSummaryState> {
  final ReminderRepository _repository;

  StreamSubscription? _sub;

  ReminderSummaryCubit(this._repository)
    : super(const ReminderSummaryLoading());

  void start() {
    if (_sub != null) return;

    emit(const ReminderSummaryLoading());

    _sub = CombineLatestStream.combine2<List<Reminder>, List<Reminder>,
        ({List<Reminder> today, List<Reminder> upcoming})>(
      _repository.watchForToday(),
      _repository.watchUpcoming(limit: 5),
      (today, upcoming) => (today: today, upcoming: upcoming),
    ).listen(
      (data) {
        final pending = data.today
            .where((r) => r.status == ReminderStatus.pending)
            .length;
        final overdue = data.today
            .where((r) => r.status == ReminderStatus.overdue || r.isOverdue)
            .length;
        final completed = data.today
            .where((r) => r.status == ReminderStatus.completed)
            .length;

        emit(
          ReminderSummaryLoaded(
            pending: pending,
            overdue: overdue,
            completed: completed,
            upcoming: data.upcoming,
          ),
        );
      },
      onError: (_) {
        emit(const ReminderSummaryError('No se pudo cargar el resumen de hoy'));
      },
    );
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    _sub = null;
    return super.close();
  }
}
