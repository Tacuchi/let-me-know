import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/reminder_repository.dart';
import 'reminder_list_state.dart';

class ReminderListCubit extends Cubit<ReminderListState> {
  final ReminderRepository _repository;

  StreamSubscription? _sub;
  ReminderListFilter _filter = ReminderListFilter.all;

  ReminderListCubit(this._repository) : super(const ReminderListLoading());

  void start() {
    if (_sub != null) return;

    emit(const ReminderListLoading());
    unawaited(refresh());

    _sub = _repository.watchAll().listen(
      (items) {
        emit(ReminderListLoaded(all: items, filter: _filter));
      },
      onError: (_) {
        emit(
          const ReminderListError('No se pudieron cargar los recordatorios'),
        );
      },
    );
  }

  void setFilter(ReminderListFilter filter) {
    _filter = filter;

    final current = state;
    if (current is ReminderListLoaded) {
      emit(ReminderListLoaded(all: current.all, filter: _filter));
    }
  }

  Future<void> refresh() async {
    try {
      final items = await _repository.getAll();
      emit(ReminderListLoaded(all: items, filter: _filter));
    } catch (_) {
      emit(const ReminderListError('No se pudieron cargar los recordatorios'));
    }
  }

  Future<void> markAsCompleted(String id) async {
    try {
      await _repository.markAsCompleted(id);
      await refresh();
    } catch (_) {
      emit(const ReminderListError('No se pudo completar el recordatorio'));
    }
  }

  Future<void> delete(String id) async {
    try {
      await _repository.delete(id);
      await refresh();
    } catch (_) {
      emit(const ReminderListError('No se pudo eliminar el recordatorio'));
    }
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    _sub = null;
    return super.close();
  }
}
