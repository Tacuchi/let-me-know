import 'dart:async';

import 'package:let_me_know/core/extensions/date_extensions.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/database/database_helper.dart';
import '../../domain/entities/reminder_status.dart';
import '../models/reminder_model.dart';

/// Data source local para recordatorios usando SQLite (sqflite).
///
/// Esta capa NO expone entidades de dominio, solo modelos de infraestructura.
class LocalReminderDataSource {
  final DatabaseHelper _dbHelper;

  StreamController<List<ReminderModel>>? _allController;

  LocalReminderDataSource(this._dbHelper);

  Future<List<ReminderModel>> getAll() async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      ReminderModel.tableName,
      orderBy: '${ReminderModel.colScheduledAt} ASC',
    );
    return rows.map(ReminderModel.fromMap).toList(growable: false);
  }

  Future<ReminderModel?> getById(String id) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      ReminderModel.tableName,
      where: '${ReminderModel.colId} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return ReminderModel.fromMap(rows.first);
  }

  Future<List<ReminderModel>> getForToday() async {
    final now = DateTime.now();
    final start = now.startOfDay;
    final endExclusive = start.add(const Duration(days: 1));

    final db = await _dbHelper.database;
    final rows = await db.query(
      ReminderModel.tableName,
      where:
          '${ReminderModel.colScheduledAt} >= ? AND ${ReminderModel.colScheduledAt} < ?',
      whereArgs: [
        start.millisecondsSinceEpoch,
        endExclusive.millisecondsSinceEpoch,
      ],
      orderBy: '${ReminderModel.colScheduledAt} ASC',
    );
    return rows.map(ReminderModel.fromMap).toList(growable: false);
  }

  Future<List<ReminderModel>> getByStatus(ReminderStatus status) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      ReminderModel.tableName,
      where: '${ReminderModel.colStatus} = ?',
      whereArgs: [status.name],
      orderBy: '${ReminderModel.colScheduledAt} ASC',
    );
    return rows.map(ReminderModel.fromMap).toList(growable: false);
  }

  Future<void> upsert(ReminderModel model) async {
    final db = await _dbHelper.database;
    await db.insert(
      ReminderModel.tableName,
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await _refreshAllIfNeeded();
  }

  Future<void> delete(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      ReminderModel.tableName,
      where: '${ReminderModel.colId} = ?',
      whereArgs: [id],
    );
    await _refreshAllIfNeeded();
  }

  Future<void> markAsCompleted(String id) async {
    final db = await _dbHelper.database;
    await db.update(
      ReminderModel.tableName,
      {
        ReminderModel.colStatus: ReminderStatus.completed.name,
        ReminderModel.colCompletedAt: DateTime.now().millisecondsSinceEpoch,
      },
      where: '${ReminderModel.colId} = ?',
      whereArgs: [id],
    );
    await _refreshAllIfNeeded();
  }

  /// Stream reactivo de todos los recordatorios.
  ///
  /// sqflite no es reactivo por defecto, así que emitimos un refresh
  /// cada vez que hay una mutación (insert/update/delete).
  Stream<List<ReminderModel>> watchAll() {
    _allController ??= StreamController<List<ReminderModel>>.broadcast(
      onListen: () {
        unawaited(_emitAll());
      },
    );

    return _allController!.stream;
  }

  /// Stream reactivo de recordatorios de hoy.
  Stream<List<ReminderModel>> watchForToday() {
    return watchAll().map((all) {
      final now = DateTime.now();
      final start = now.startOfDay;
      final endExclusive = start.add(const Duration(days: 1));

      return all
          .where(
            (r) =>
                !r.scheduledAt.isBefore(start) &&
                r.scheduledAt.isBefore(endExclusive),
          )
          .toList(growable: false);
    });
  }

  Future<void> dispose() async {
    await _allController?.close();
    _allController = null;
  }

  Future<void> _refreshAllIfNeeded() async {
    if (_allController == null) return;
    await _emitAll();
  }

  Future<void> _emitAll() async {
    final controller = _allController;
    if (controller == null) return;

    try {
      final items = await getAll();
      if (controller.isClosed) return;
      controller.add(items);
    } catch (e, st) {
      if (controller.isClosed) return;
      controller.addError(e, st);
    }
  }
}
