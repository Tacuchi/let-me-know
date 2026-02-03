import 'package:drift/drift.dart';

import '../../../../core/database/drift/app_database.dart';
import '../../domain/entities/reminder_group.dart';
import '../../domain/repositories/group_repository.dart';

class GroupRepositoryDriftImpl implements GroupRepository {
  final AppDatabase _db;

  GroupRepositoryDriftImpl(this._db);

  ReminderGroup _toEntity(ReminderGroupRow row) {
    return ReminderGroup(
      id: row.id,
      label: row.label,
      type: row.type,
      itemCount: row.itemCount,
      createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAtMs),
    );
  }

  ReminderGroupsCompanion _toCompanion(ReminderGroup group) {
    return ReminderGroupsCompanion(
      id: Value(group.id),
      label: Value(group.label),
      type: Value(group.type),
      itemCount: Value(group.itemCount),
      createdAtMs: Value(group.createdAt.millisecondsSinceEpoch),
    );
  }

  @override
  Future<List<ReminderGroup>> getAll() async {
    final rows = await (_db.select(_db.reminderGroups)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAtMs)]))
        .get();
    return rows.map(_toEntity).toList();
  }

  @override
  Future<ReminderGroup?> getById(String id) async {
    final row = await (_db.select(_db.reminderGroups)
          ..where((t) => t.id.equals(id))
          ..limit(1))
        .getSingleOrNull();
    return row != null ? _toEntity(row) : null;
  }

  @override
  Future<void> save(ReminderGroup group) async {
    await _db.into(_db.reminderGroups).insertOnConflictUpdate(_toCompanion(group));
  }

  @override
  Future<void> updateLabel(String id, String newLabel) async {
    await (_db.update(_db.reminderGroups)..where((t) => t.id.equals(id)))
        .write(ReminderGroupsCompanion(label: Value(newLabel)));
  }

  @override
  Future<void> delete(String id) async {
    await (_db.delete(_db.reminderGroups)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<void> incrementItemCount(String id) async {
    final group = await getById(id);
    if (group != null) {
      await (_db.update(_db.reminderGroups)..where((t) => t.id.equals(id)))
          .write(ReminderGroupsCompanion(itemCount: Value(group.itemCount + 1)));
    }
  }

  @override
  Future<void> decrementItemCount(String id) async {
    final group = await getById(id);
    if (group != null && group.itemCount > 0) {
      await (_db.update(_db.reminderGroups)..where((t) => t.id.equals(id)))
          .write(ReminderGroupsCompanion(itemCount: Value(group.itemCount - 1)));
    }
  }

  @override
  Stream<List<ReminderGroup>> watchAll() {
    return (_db.select(_db.reminderGroups)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAtMs)]))
        .watch()
        .map((rows) => rows.map(_toEntity).toList());
  }
}
