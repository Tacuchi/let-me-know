import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/reminder_repository.dart';
import 'reminder_detail_state.dart';

class ReminderDetailCubit extends Cubit<ReminderDetailState> {
  final ReminderRepository _repository;
  String? _currentId;

  ReminderDetailCubit(this._repository) : super(const ReminderDetailInitial());

  Future<void> load(String id) async {
    _currentId = id;
    emit(const ReminderDetailLoading());

    try {
      final reminder = await _repository.getById(id);
      if (reminder == null) {
        emit(const ReminderDetailNotFound());
      } else {
        emit(ReminderDetailLoaded(reminder));
      }
    } catch (e) {
      emit(ReminderDetailError('No se pudo cargar el recordatorio'));
    }
  }

  Future<void> reload() async {
    if (_currentId != null) {
      await load(_currentId!);
    }
  }

  Future<void> markAsCompleted() async {
    if (_currentId == null) return;

    try {
      await _repository.markAsCompleted(_currentId!);
      emit(const ReminderDetailCompleted());
    } catch (e) {
      emit(ReminderDetailError('No se pudo completar el recordatorio'));
    }
  }

  Future<void> snooze(Duration duration) async {
    if (_currentId == null) return;

    try {
      await _repository.snooze(_currentId!, duration);
      final newTime = DateTime.now().add(duration);
      emit(ReminderDetailSnoozed(newTime));
    } catch (e) {
      emit(ReminderDetailError('No se pudo posponer el recordatorio'));
    }
  }

  Future<void> delete() async {
    if (_currentId == null) return;

    try {
      await _repository.delete(_currentId!);
      emit(const ReminderDetailDeleted());
    } catch (e) {
      emit(ReminderDetailError('No se pudo eliminar el recordatorio'));
    }
  }
}
