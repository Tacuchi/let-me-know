import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/drift/app_database.dart';
import '../../domain/entities/action_history_entry.dart';
import '../../domain/repositories/action_history_repository.dart';

class ActionHistoryRepositoryDriftImpl implements ActionHistoryRepository {
  final AppDatabase _db;
  static const _uuid = Uuid();

  ActionHistoryRepositoryDriftImpl(this._db);

  ActionHistoryEntry _toEntity(ActionHistoryRow row) {
    return ActionHistoryEntry(
      id: row.id,
      action: HistoryAction.values.byName(row.action),
      reminderId: row.reminderId,
      reminderTitle: row.reminderTitle,
      groupId: row.groupId,
      groupLabel: row.groupLabel,
      actionAt: DateTime.fromMillisecondsSinceEpoch(row.actionAtMs),
    );
  }

  ActionHistoryCompanion _toCompanion(ActionHistoryEntry entry) {
    return ActionHistoryCompanion(
      id: Value(entry.id),
      action: Value(entry.action.name),
      reminderId: Value(entry.reminderId),
      reminderTitle: Value(entry.reminderTitle),
      groupId: Value(entry.groupId),
      groupLabel: Value(entry.groupLabel),
      actionAtMs: Value(entry.actionAt.millisecondsSinceEpoch),
    );
  }

  @override
  Future<List<ActionHistoryEntry>> getRecent({int limit = 50}) async {
    final rows = await (_db.select(_db.actionHistory)
          ..orderBy([(t) => OrderingTerm.desc(t.actionAtMs)])
          ..limit(limit))
        .get();
    return rows.map(_toEntity).toList();
  }

  @override
  Future<void> record(ActionHistoryEntry entry) async {
    final entryWithId = entry.id.isEmpty
        ? ActionHistoryEntry(
            id: _uuid.v4(),
            action: entry.action,
            reminderId: entry.reminderId,
            reminderTitle: entry.reminderTitle,
            groupId: entry.groupId,
            groupLabel: entry.groupLabel,
            actionAt: entry.actionAt,
          )
        : entry;
    await _db.into(_db.actionHistory).insert(_toCompanion(entryWithId));
  }

  @override
  Future<void> cleanup({int olderThanDays = 30}) async {
    final cutoff = DateTime.now().subtract(Duration(days: olderThanDays));
    final cutoffMs = cutoff.millisecondsSinceEpoch;
    await (_db.delete(_db.actionHistory)
          ..where((t) => t.actionAtMs.isSmallerThanValue(cutoffMs)))
        .go();
  }
}
