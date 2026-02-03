import '../entities/reminder_group.dart';

abstract class GroupRepository {
  Future<List<ReminderGroup>> getAll();
  Future<ReminderGroup?> getById(String id);
  Future<void> save(ReminderGroup group);
  Future<void> updateLabel(String id, String newLabel);
  Future<void> delete(String id);
  Future<void> incrementItemCount(String id);
  Future<void> decrementItemCount(String id);
  Stream<List<ReminderGroup>> watchAll();
}
