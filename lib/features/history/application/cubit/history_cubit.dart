import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../reminders/domain/entities/reminder_status.dart';
import '../../../reminders/domain/entities/reminder_type.dart';
import '../../../reminders/domain/repositories/reminder_repository.dart';
import 'history_state.dart';

class HistoryCubit extends Cubit<HistoryState> {
  final ReminderRepository _repository;

  StreamSubscription? _sub;
  HistoryPeriodFilter _periodFilter = HistoryPeriodFilter.all;
  ReminderType? _typeFilter;

  HistoryCubit(this._repository) : super(const HistoryLoading());

  void start() {
    if (_sub != null) return;

    emit(const HistoryLoading());
    unawaited(refresh());

    _sub = _repository.watchAll().listen(
      (_) => unawaited(refresh()),
      onError: (_) =>
          emit(const HistoryError('No se pudo cargar el historial')),
    );
  }

  void setPeriodFilter(HistoryPeriodFilter filter) {
    _periodFilter = filter;
    final current = state;
    if (current is HistoryLoaded) {
      emit(current.copyWith(periodFilter: filter));
    }
  }

  void setTypeFilter(ReminderType? type) {
    _typeFilter = type;
    final current = state;
    if (current is HistoryLoaded) {
      if (type == null) {
        emit(current.copyWith(clearTypeFilter: true));
      } else {
        emit(current.copyWith(typeFilter: type));
      }
    }
  }

  void clearFilters() {
    _periodFilter = HistoryPeriodFilter.all;
    _typeFilter = null;
    final current = state;
    if (current is HistoryLoaded) {
      emit(current.copyWith(
        periodFilter: HistoryPeriodFilter.all,
        clearTypeFilter: true,
      ));
    }
  }

  Future<void> refresh() async {
    try {
      final all = await _repository.getAll();
      final completed =
          all
              .where((r) => r.status == ReminderStatus.completed)
              .toList(growable: false)
            ..sort(
              (a, b) =>
                  (b.completedAt ?? DateTime.fromMillisecondsSinceEpoch(0))
                      .compareTo(
                        a.completedAt ?? DateTime.fromMillisecondsSinceEpoch(0),
                      ),
            );

      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month);
      final startOfNextMonth = DateTime(now.year, now.month + 1);

      final completedThisMonth = completed.where((r) {
        final at = r.completedAt;
        if (at == null) return false;
        return !at.isBefore(startOfMonth) && at.isBefore(startOfNextMonth);
      }).length;

      emit(
        HistoryLoaded(
          all: completed,
          completedThisMonth: completedThisMonth,
          completedTotal: completed.length,
          periodFilter: _periodFilter,
          typeFilter: _typeFilter,
        ),
      );
    } catch (_) {
      emit(const HistoryError('No se pudo cargar el historial'));
    }
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    _sub = null;
    return super.close();
  }
}
