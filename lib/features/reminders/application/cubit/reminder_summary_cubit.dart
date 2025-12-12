import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/reminder_status.dart';
import '../../domain/repositories/reminder_repository.dart';
import 'reminder_summary_state.dart';

/// Cubit para métricas de la pantalla de inicio ("Resumen de hoy").
///
/// Observa recordatorios de hoy y calcula contadores.
class ReminderSummaryCubit extends Cubit<ReminderSummaryState> {
  final ReminderRepository _repository;

  StreamSubscription? _sub;

  ReminderSummaryCubit(this._repository)
    : super(const ReminderSummaryLoading());

  void start() {
    if (_sub != null) return;

    emit(const ReminderSummaryLoading());

    _sub = _repository.watchForToday().listen(
      (items) {
        final pending = items
            .where((r) => r.status == ReminderStatus.pending)
            .length;
        final overdue = items
            .where((r) => r.status == ReminderStatus.overdue || r.isOverdue)
            .length;
        final completed = items
            .where((r) => r.status == ReminderStatus.completed)
            .length;

        emit(
          ReminderSummaryLoaded(
            pending: pending,
            overdue: overdue,
            completed: completed,
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
