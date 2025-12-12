// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $RemindersTable extends Reminders
    with TableInfo<$RemindersTable, ReminderRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RemindersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scheduledAtMsMeta = const VerificationMeta(
    'scheduledAtMs',
  );
  @override
  late final GeneratedColumn<int> scheduledAtMs = GeneratedColumn<int>(
    'scheduled_at_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _importanceMeta = const VerificationMeta(
    'importance',
  );
  @override
  late final GeneratedColumn<String> importance = GeneratedColumn<String>(
    'importance',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('medium'),
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('manual'),
  );
  static const VerificationMeta _objectMeta = const VerificationMeta('object');
  @override
  late final GeneratedColumn<String> object = GeneratedColumn<String>(
    'object',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hasNotificationMeta = const VerificationMeta(
    'hasNotification',
  );
  @override
  late final GeneratedColumn<bool> hasNotification = GeneratedColumn<bool>(
    'has_notification',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_notification" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _notificationIdMeta = const VerificationMeta(
    'notificationId',
  );
  @override
  late final GeneratedColumn<int> notificationId = GeneratedColumn<int>(
    'notification_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastNotifiedAtMsMeta = const VerificationMeta(
    'lastNotifiedAtMs',
  );
  @override
  late final GeneratedColumn<int> lastNotifiedAtMs = GeneratedColumn<int>(
    'last_notified_at_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _snoozedUntilMsMeta = const VerificationMeta(
    'snoozedUntilMs',
  );
  @override
  late final GeneratedColumn<int> snoozedUntilMs = GeneratedColumn<int>(
    'snoozed_until_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recurrenceGroupIdMeta = const VerificationMeta(
    'recurrenceGroupId',
  );
  @override
  late final GeneratedColumn<String> recurrenceGroupId =
      GeneratedColumn<String>(
        'recurrence_group_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _recurrenceRuleMeta = const VerificationMeta(
    'recurrenceRule',
  );
  @override
  late final GeneratedColumn<String> recurrenceRule = GeneratedColumn<String>(
    'recurrence_rule',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMsMeta = const VerificationMeta(
    'createdAtMs',
  );
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
    'created_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedAtMsMeta = const VerificationMeta(
    'completedAtMs',
  );
  @override
  late final GeneratedColumn<int> completedAtMs = GeneratedColumn<int>(
    'completed_at_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    description,
    scheduledAtMs,
    type,
    status,
    importance,
    source,
    object,
    location,
    hasNotification,
    notificationId,
    lastNotifiedAtMs,
    snoozedUntilMs,
    recurrenceGroupId,
    recurrenceRule,
    createdAtMs,
    updatedAtMs,
    completedAtMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminders';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReminderRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('scheduled_at_ms')) {
      context.handle(
        _scheduledAtMsMeta,
        scheduledAtMs.isAcceptableOrUnknown(
          data['scheduled_at_ms']!,
          _scheduledAtMsMeta,
        ),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('importance')) {
      context.handle(
        _importanceMeta,
        importance.isAcceptableOrUnknown(data['importance']!, _importanceMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('object')) {
      context.handle(
        _objectMeta,
        object.isAcceptableOrUnknown(data['object']!, _objectMeta),
      );
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('has_notification')) {
      context.handle(
        _hasNotificationMeta,
        hasNotification.isAcceptableOrUnknown(
          data['has_notification']!,
          _hasNotificationMeta,
        ),
      );
    }
    if (data.containsKey('notification_id')) {
      context.handle(
        _notificationIdMeta,
        notificationId.isAcceptableOrUnknown(
          data['notification_id']!,
          _notificationIdMeta,
        ),
      );
    }
    if (data.containsKey('last_notified_at_ms')) {
      context.handle(
        _lastNotifiedAtMsMeta,
        lastNotifiedAtMs.isAcceptableOrUnknown(
          data['last_notified_at_ms']!,
          _lastNotifiedAtMsMeta,
        ),
      );
    }
    if (data.containsKey('snoozed_until_ms')) {
      context.handle(
        _snoozedUntilMsMeta,
        snoozedUntilMs.isAcceptableOrUnknown(
          data['snoozed_until_ms']!,
          _snoozedUntilMsMeta,
        ),
      );
    }
    if (data.containsKey('recurrence_group_id')) {
      context.handle(
        _recurrenceGroupIdMeta,
        recurrenceGroupId.isAcceptableOrUnknown(
          data['recurrence_group_id']!,
          _recurrenceGroupIdMeta,
        ),
      );
    }
    if (data.containsKey('recurrence_rule')) {
      context.handle(
        _recurrenceRuleMeta,
        recurrenceRule.isAcceptableOrUnknown(
          data['recurrence_rule']!,
          _recurrenceRuleMeta,
        ),
      );
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
        _createdAtMsMeta,
        createdAtMs.isAcceptableOrUnknown(
          data['created_at_ms']!,
          _createdAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    }
    if (data.containsKey('completed_at_ms')) {
      context.handle(
        _completedAtMsMeta,
        completedAtMs.isAcceptableOrUnknown(
          data['completed_at_ms']!,
          _completedAtMsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReminderRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReminderRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      scheduledAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}scheduled_at_ms'],
      ),
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      importance: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}importance'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      object: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}object'],
      ),
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      ),
      hasNotification: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_notification'],
      )!,
      notificationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}notification_id'],
      ),
      lastNotifiedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_notified_at_ms'],
      ),
      snoozedUntilMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}snoozed_until_ms'],
      ),
      recurrenceGroupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurrence_group_id'],
      ),
      recurrenceRule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurrence_rule'],
      ),
      createdAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_ms'],
      )!,
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      ),
      completedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_at_ms'],
      ),
    );
  }

  @override
  $RemindersTable createAlias(String alias) {
    return $RemindersTable(attachedDatabase, alias);
  }
}

class ReminderRow extends DataClass implements Insertable<ReminderRow> {
  final String id;
  final String title;
  final String description;

  /// Fecha/hora programada.
  /// - null para notas tipo ubicación.
  final int? scheduledAtMs;

  /// Enum name (ReminderType).
  final String type;

  /// Enum name (ReminderStatus).
  final String status;

  /// Enum name (ReminderImportance). Default: medium.
  final String importance;

  /// manual | voice
  final String source;

  /// Metadatos para notas de ubicación (type == 'location')
  final String? object;
  final String? location;

  /// Notificaciones
  final bool hasNotification;
  final int? notificationId;
  final int? lastNotifiedAtMs;
  final int? snoozedUntilMs;

  /// Recurrencia (mínimo viable, para no bloquear objetivo final)
  final String? recurrenceGroupId;
  final String? recurrenceRule;

  /// Auditoría
  final int createdAtMs;
  final int? updatedAtMs;
  final int? completedAtMs;
  const ReminderRow({
    required this.id,
    required this.title,
    required this.description,
    this.scheduledAtMs,
    required this.type,
    required this.status,
    required this.importance,
    required this.source,
    this.object,
    this.location,
    required this.hasNotification,
    this.notificationId,
    this.lastNotifiedAtMs,
    this.snoozedUntilMs,
    this.recurrenceGroupId,
    this.recurrenceRule,
    required this.createdAtMs,
    this.updatedAtMs,
    this.completedAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    if (!nullToAbsent || scheduledAtMs != null) {
      map['scheduled_at_ms'] = Variable<int>(scheduledAtMs);
    }
    map['type'] = Variable<String>(type);
    map['status'] = Variable<String>(status);
    map['importance'] = Variable<String>(importance);
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || object != null) {
      map['object'] = Variable<String>(object);
    }
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    map['has_notification'] = Variable<bool>(hasNotification);
    if (!nullToAbsent || notificationId != null) {
      map['notification_id'] = Variable<int>(notificationId);
    }
    if (!nullToAbsent || lastNotifiedAtMs != null) {
      map['last_notified_at_ms'] = Variable<int>(lastNotifiedAtMs);
    }
    if (!nullToAbsent || snoozedUntilMs != null) {
      map['snoozed_until_ms'] = Variable<int>(snoozedUntilMs);
    }
    if (!nullToAbsent || recurrenceGroupId != null) {
      map['recurrence_group_id'] = Variable<String>(recurrenceGroupId);
    }
    if (!nullToAbsent || recurrenceRule != null) {
      map['recurrence_rule'] = Variable<String>(recurrenceRule);
    }
    map['created_at_ms'] = Variable<int>(createdAtMs);
    if (!nullToAbsent || updatedAtMs != null) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs);
    }
    if (!nullToAbsent || completedAtMs != null) {
      map['completed_at_ms'] = Variable<int>(completedAtMs);
    }
    return map;
  }

  RemindersCompanion toCompanion(bool nullToAbsent) {
    return RemindersCompanion(
      id: Value(id),
      title: Value(title),
      description: Value(description),
      scheduledAtMs: scheduledAtMs == null && nullToAbsent
          ? const Value.absent()
          : Value(scheduledAtMs),
      type: Value(type),
      status: Value(status),
      importance: Value(importance),
      source: Value(source),
      object: object == null && nullToAbsent
          ? const Value.absent()
          : Value(object),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      hasNotification: Value(hasNotification),
      notificationId: notificationId == null && nullToAbsent
          ? const Value.absent()
          : Value(notificationId),
      lastNotifiedAtMs: lastNotifiedAtMs == null && nullToAbsent
          ? const Value.absent()
          : Value(lastNotifiedAtMs),
      snoozedUntilMs: snoozedUntilMs == null && nullToAbsent
          ? const Value.absent()
          : Value(snoozedUntilMs),
      recurrenceGroupId: recurrenceGroupId == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceGroupId),
      recurrenceRule: recurrenceRule == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceRule),
      createdAtMs: Value(createdAtMs),
      updatedAtMs: updatedAtMs == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAtMs),
      completedAtMs: completedAtMs == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAtMs),
    );
  }

  factory ReminderRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReminderRow(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      scheduledAtMs: serializer.fromJson<int?>(json['scheduledAtMs']),
      type: serializer.fromJson<String>(json['type']),
      status: serializer.fromJson<String>(json['status']),
      importance: serializer.fromJson<String>(json['importance']),
      source: serializer.fromJson<String>(json['source']),
      object: serializer.fromJson<String?>(json['object']),
      location: serializer.fromJson<String?>(json['location']),
      hasNotification: serializer.fromJson<bool>(json['hasNotification']),
      notificationId: serializer.fromJson<int?>(json['notificationId']),
      lastNotifiedAtMs: serializer.fromJson<int?>(json['lastNotifiedAtMs']),
      snoozedUntilMs: serializer.fromJson<int?>(json['snoozedUntilMs']),
      recurrenceGroupId: serializer.fromJson<String?>(
        json['recurrenceGroupId'],
      ),
      recurrenceRule: serializer.fromJson<String?>(json['recurrenceRule']),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
      updatedAtMs: serializer.fromJson<int?>(json['updatedAtMs']),
      completedAtMs: serializer.fromJson<int?>(json['completedAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'scheduledAtMs': serializer.toJson<int?>(scheduledAtMs),
      'type': serializer.toJson<String>(type),
      'status': serializer.toJson<String>(status),
      'importance': serializer.toJson<String>(importance),
      'source': serializer.toJson<String>(source),
      'object': serializer.toJson<String?>(object),
      'location': serializer.toJson<String?>(location),
      'hasNotification': serializer.toJson<bool>(hasNotification),
      'notificationId': serializer.toJson<int?>(notificationId),
      'lastNotifiedAtMs': serializer.toJson<int?>(lastNotifiedAtMs),
      'snoozedUntilMs': serializer.toJson<int?>(snoozedUntilMs),
      'recurrenceGroupId': serializer.toJson<String?>(recurrenceGroupId),
      'recurrenceRule': serializer.toJson<String?>(recurrenceRule),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
      'updatedAtMs': serializer.toJson<int?>(updatedAtMs),
      'completedAtMs': serializer.toJson<int?>(completedAtMs),
    };
  }

  ReminderRow copyWith({
    String? id,
    String? title,
    String? description,
    Value<int?> scheduledAtMs = const Value.absent(),
    String? type,
    String? status,
    String? importance,
    String? source,
    Value<String?> object = const Value.absent(),
    Value<String?> location = const Value.absent(),
    bool? hasNotification,
    Value<int?> notificationId = const Value.absent(),
    Value<int?> lastNotifiedAtMs = const Value.absent(),
    Value<int?> snoozedUntilMs = const Value.absent(),
    Value<String?> recurrenceGroupId = const Value.absent(),
    Value<String?> recurrenceRule = const Value.absent(),
    int? createdAtMs,
    Value<int?> updatedAtMs = const Value.absent(),
    Value<int?> completedAtMs = const Value.absent(),
  }) => ReminderRow(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    scheduledAtMs: scheduledAtMs.present
        ? scheduledAtMs.value
        : this.scheduledAtMs,
    type: type ?? this.type,
    status: status ?? this.status,
    importance: importance ?? this.importance,
    source: source ?? this.source,
    object: object.present ? object.value : this.object,
    location: location.present ? location.value : this.location,
    hasNotification: hasNotification ?? this.hasNotification,
    notificationId: notificationId.present
        ? notificationId.value
        : this.notificationId,
    lastNotifiedAtMs: lastNotifiedAtMs.present
        ? lastNotifiedAtMs.value
        : this.lastNotifiedAtMs,
    snoozedUntilMs: snoozedUntilMs.present
        ? snoozedUntilMs.value
        : this.snoozedUntilMs,
    recurrenceGroupId: recurrenceGroupId.present
        ? recurrenceGroupId.value
        : this.recurrenceGroupId,
    recurrenceRule: recurrenceRule.present
        ? recurrenceRule.value
        : this.recurrenceRule,
    createdAtMs: createdAtMs ?? this.createdAtMs,
    updatedAtMs: updatedAtMs.present ? updatedAtMs.value : this.updatedAtMs,
    completedAtMs: completedAtMs.present
        ? completedAtMs.value
        : this.completedAtMs,
  );
  ReminderRow copyWithCompanion(RemindersCompanion data) {
    return ReminderRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      scheduledAtMs: data.scheduledAtMs.present
          ? data.scheduledAtMs.value
          : this.scheduledAtMs,
      type: data.type.present ? data.type.value : this.type,
      status: data.status.present ? data.status.value : this.status,
      importance: data.importance.present
          ? data.importance.value
          : this.importance,
      source: data.source.present ? data.source.value : this.source,
      object: data.object.present ? data.object.value : this.object,
      location: data.location.present ? data.location.value : this.location,
      hasNotification: data.hasNotification.present
          ? data.hasNotification.value
          : this.hasNotification,
      notificationId: data.notificationId.present
          ? data.notificationId.value
          : this.notificationId,
      lastNotifiedAtMs: data.lastNotifiedAtMs.present
          ? data.lastNotifiedAtMs.value
          : this.lastNotifiedAtMs,
      snoozedUntilMs: data.snoozedUntilMs.present
          ? data.snoozedUntilMs.value
          : this.snoozedUntilMs,
      recurrenceGroupId: data.recurrenceGroupId.present
          ? data.recurrenceGroupId.value
          : this.recurrenceGroupId,
      recurrenceRule: data.recurrenceRule.present
          ? data.recurrenceRule.value
          : this.recurrenceRule,
      createdAtMs: data.createdAtMs.present
          ? data.createdAtMs.value
          : this.createdAtMs,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
      completedAtMs: data.completedAtMs.present
          ? data.completedAtMs.value
          : this.completedAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReminderRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('scheduledAtMs: $scheduledAtMs, ')
          ..write('type: $type, ')
          ..write('status: $status, ')
          ..write('importance: $importance, ')
          ..write('source: $source, ')
          ..write('object: $object, ')
          ..write('location: $location, ')
          ..write('hasNotification: $hasNotification, ')
          ..write('notificationId: $notificationId, ')
          ..write('lastNotifiedAtMs: $lastNotifiedAtMs, ')
          ..write('snoozedUntilMs: $snoozedUntilMs, ')
          ..write('recurrenceGroupId: $recurrenceGroupId, ')
          ..write('recurrenceRule: $recurrenceRule, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('completedAtMs: $completedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    scheduledAtMs,
    type,
    status,
    importance,
    source,
    object,
    location,
    hasNotification,
    notificationId,
    lastNotifiedAtMs,
    snoozedUntilMs,
    recurrenceGroupId,
    recurrenceRule,
    createdAtMs,
    updatedAtMs,
    completedAtMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReminderRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.scheduledAtMs == this.scheduledAtMs &&
          other.type == this.type &&
          other.status == this.status &&
          other.importance == this.importance &&
          other.source == this.source &&
          other.object == this.object &&
          other.location == this.location &&
          other.hasNotification == this.hasNotification &&
          other.notificationId == this.notificationId &&
          other.lastNotifiedAtMs == this.lastNotifiedAtMs &&
          other.snoozedUntilMs == this.snoozedUntilMs &&
          other.recurrenceGroupId == this.recurrenceGroupId &&
          other.recurrenceRule == this.recurrenceRule &&
          other.createdAtMs == this.createdAtMs &&
          other.updatedAtMs == this.updatedAtMs &&
          other.completedAtMs == this.completedAtMs);
}

class RemindersCompanion extends UpdateCompanion<ReminderRow> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> description;
  final Value<int?> scheduledAtMs;
  final Value<String> type;
  final Value<String> status;
  final Value<String> importance;
  final Value<String> source;
  final Value<String?> object;
  final Value<String?> location;
  final Value<bool> hasNotification;
  final Value<int?> notificationId;
  final Value<int?> lastNotifiedAtMs;
  final Value<int?> snoozedUntilMs;
  final Value<String?> recurrenceGroupId;
  final Value<String?> recurrenceRule;
  final Value<int> createdAtMs;
  final Value<int?> updatedAtMs;
  final Value<int?> completedAtMs;
  final Value<int> rowid;
  const RemindersCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.scheduledAtMs = const Value.absent(),
    this.type = const Value.absent(),
    this.status = const Value.absent(),
    this.importance = const Value.absent(),
    this.source = const Value.absent(),
    this.object = const Value.absent(),
    this.location = const Value.absent(),
    this.hasNotification = const Value.absent(),
    this.notificationId = const Value.absent(),
    this.lastNotifiedAtMs = const Value.absent(),
    this.snoozedUntilMs = const Value.absent(),
    this.recurrenceGroupId = const Value.absent(),
    this.recurrenceRule = const Value.absent(),
    this.createdAtMs = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.completedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RemindersCompanion.insert({
    required String id,
    required String title,
    required String description,
    this.scheduledAtMs = const Value.absent(),
    required String type,
    required String status,
    this.importance = const Value.absent(),
    this.source = const Value.absent(),
    this.object = const Value.absent(),
    this.location = const Value.absent(),
    this.hasNotification = const Value.absent(),
    this.notificationId = const Value.absent(),
    this.lastNotifiedAtMs = const Value.absent(),
    this.snoozedUntilMs = const Value.absent(),
    this.recurrenceGroupId = const Value.absent(),
    this.recurrenceRule = const Value.absent(),
    required int createdAtMs,
    this.updatedAtMs = const Value.absent(),
    this.completedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       description = Value(description),
       type = Value(type),
       status = Value(status),
       createdAtMs = Value(createdAtMs);
  static Insertable<ReminderRow> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<int>? scheduledAtMs,
    Expression<String>? type,
    Expression<String>? status,
    Expression<String>? importance,
    Expression<String>? source,
    Expression<String>? object,
    Expression<String>? location,
    Expression<bool>? hasNotification,
    Expression<int>? notificationId,
    Expression<int>? lastNotifiedAtMs,
    Expression<int>? snoozedUntilMs,
    Expression<String>? recurrenceGroupId,
    Expression<String>? recurrenceRule,
    Expression<int>? createdAtMs,
    Expression<int>? updatedAtMs,
    Expression<int>? completedAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (scheduledAtMs != null) 'scheduled_at_ms': scheduledAtMs,
      if (type != null) 'type': type,
      if (status != null) 'status': status,
      if (importance != null) 'importance': importance,
      if (source != null) 'source': source,
      if (object != null) 'object': object,
      if (location != null) 'location': location,
      if (hasNotification != null) 'has_notification': hasNotification,
      if (notificationId != null) 'notification_id': notificationId,
      if (lastNotifiedAtMs != null) 'last_notified_at_ms': lastNotifiedAtMs,
      if (snoozedUntilMs != null) 'snoozed_until_ms': snoozedUntilMs,
      if (recurrenceGroupId != null) 'recurrence_group_id': recurrenceGroupId,
      if (recurrenceRule != null) 'recurrence_rule': recurrenceRule,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (completedAtMs != null) 'completed_at_ms': completedAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RemindersCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? description,
    Value<int?>? scheduledAtMs,
    Value<String>? type,
    Value<String>? status,
    Value<String>? importance,
    Value<String>? source,
    Value<String?>? object,
    Value<String?>? location,
    Value<bool>? hasNotification,
    Value<int?>? notificationId,
    Value<int?>? lastNotifiedAtMs,
    Value<int?>? snoozedUntilMs,
    Value<String?>? recurrenceGroupId,
    Value<String?>? recurrenceRule,
    Value<int>? createdAtMs,
    Value<int?>? updatedAtMs,
    Value<int?>? completedAtMs,
    Value<int>? rowid,
  }) {
    return RemindersCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      scheduledAtMs: scheduledAtMs ?? this.scheduledAtMs,
      type: type ?? this.type,
      status: status ?? this.status,
      importance: importance ?? this.importance,
      source: source ?? this.source,
      object: object ?? this.object,
      location: location ?? this.location,
      hasNotification: hasNotification ?? this.hasNotification,
      notificationId: notificationId ?? this.notificationId,
      lastNotifiedAtMs: lastNotifiedAtMs ?? this.lastNotifiedAtMs,
      snoozedUntilMs: snoozedUntilMs ?? this.snoozedUntilMs,
      recurrenceGroupId: recurrenceGroupId ?? this.recurrenceGroupId,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      completedAtMs: completedAtMs ?? this.completedAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (scheduledAtMs.present) {
      map['scheduled_at_ms'] = Variable<int>(scheduledAtMs.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (importance.present) {
      map['importance'] = Variable<String>(importance.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (object.present) {
      map['object'] = Variable<String>(object.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (hasNotification.present) {
      map['has_notification'] = Variable<bool>(hasNotification.value);
    }
    if (notificationId.present) {
      map['notification_id'] = Variable<int>(notificationId.value);
    }
    if (lastNotifiedAtMs.present) {
      map['last_notified_at_ms'] = Variable<int>(lastNotifiedAtMs.value);
    }
    if (snoozedUntilMs.present) {
      map['snoozed_until_ms'] = Variable<int>(snoozedUntilMs.value);
    }
    if (recurrenceGroupId.present) {
      map['recurrence_group_id'] = Variable<String>(recurrenceGroupId.value);
    }
    if (recurrenceRule.present) {
      map['recurrence_rule'] = Variable<String>(recurrenceRule.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (completedAtMs.present) {
      map['completed_at_ms'] = Variable<int>(completedAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RemindersCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('scheduledAtMs: $scheduledAtMs, ')
          ..write('type: $type, ')
          ..write('status: $status, ')
          ..write('importance: $importance, ')
          ..write('source: $source, ')
          ..write('object: $object, ')
          ..write('location: $location, ')
          ..write('hasNotification: $hasNotification, ')
          ..write('notificationId: $notificationId, ')
          ..write('lastNotifiedAtMs: $lastNotifiedAtMs, ')
          ..write('snoozedUntilMs: $snoozedUntilMs, ')
          ..write('recurrenceGroupId: $recurrenceGroupId, ')
          ..write('recurrenceRule: $recurrenceRule, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('completedAtMs: $completedAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $RemindersTable reminders = $RemindersTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [reminders];
}

typedef $$RemindersTableCreateCompanionBuilder =
    RemindersCompanion Function({
      required String id,
      required String title,
      required String description,
      Value<int?> scheduledAtMs,
      required String type,
      required String status,
      Value<String> importance,
      Value<String> source,
      Value<String?> object,
      Value<String?> location,
      Value<bool> hasNotification,
      Value<int?> notificationId,
      Value<int?> lastNotifiedAtMs,
      Value<int?> snoozedUntilMs,
      Value<String?> recurrenceGroupId,
      Value<String?> recurrenceRule,
      required int createdAtMs,
      Value<int?> updatedAtMs,
      Value<int?> completedAtMs,
      Value<int> rowid,
    });
typedef $$RemindersTableUpdateCompanionBuilder =
    RemindersCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> description,
      Value<int?> scheduledAtMs,
      Value<String> type,
      Value<String> status,
      Value<String> importance,
      Value<String> source,
      Value<String?> object,
      Value<String?> location,
      Value<bool> hasNotification,
      Value<int?> notificationId,
      Value<int?> lastNotifiedAtMs,
      Value<int?> snoozedUntilMs,
      Value<String?> recurrenceGroupId,
      Value<String?> recurrenceRule,
      Value<int> createdAtMs,
      Value<int?> updatedAtMs,
      Value<int?> completedAtMs,
      Value<int> rowid,
    });

class $$RemindersTableFilterComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get scheduledAtMs => $composableBuilder(
    column: $table.scheduledAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get importance => $composableBuilder(
    column: $table.importance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get object => $composableBuilder(
    column: $table.object,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasNotification => $composableBuilder(
    column: $table.hasNotification,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get notificationId => $composableBuilder(
    column: $table.notificationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastNotifiedAtMs => $composableBuilder(
    column: $table.lastNotifiedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get snoozedUntilMs => $composableBuilder(
    column: $table.snoozedUntilMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recurrenceGroupId => $composableBuilder(
    column: $table.recurrenceGroupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recurrenceRule => $composableBuilder(
    column: $table.recurrenceRule,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedAtMs => $composableBuilder(
    column: $table.completedAtMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RemindersTableOrderingComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get scheduledAtMs => $composableBuilder(
    column: $table.scheduledAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get importance => $composableBuilder(
    column: $table.importance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get object => $composableBuilder(
    column: $table.object,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasNotification => $composableBuilder(
    column: $table.hasNotification,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get notificationId => $composableBuilder(
    column: $table.notificationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastNotifiedAtMs => $composableBuilder(
    column: $table.lastNotifiedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get snoozedUntilMs => $composableBuilder(
    column: $table.snoozedUntilMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recurrenceGroupId => $composableBuilder(
    column: $table.recurrenceGroupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recurrenceRule => $composableBuilder(
    column: $table.recurrenceRule,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedAtMs => $composableBuilder(
    column: $table.completedAtMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RemindersTableAnnotationComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get scheduledAtMs => $composableBuilder(
    column: $table.scheduledAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get importance => $composableBuilder(
    column: $table.importance,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get object =>
      $composableBuilder(column: $table.object, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<bool> get hasNotification => $composableBuilder(
    column: $table.hasNotification,
    builder: (column) => column,
  );

  GeneratedColumn<int> get notificationId => $composableBuilder(
    column: $table.notificationId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastNotifiedAtMs => $composableBuilder(
    column: $table.lastNotifiedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get snoozedUntilMs => $composableBuilder(
    column: $table.snoozedUntilMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recurrenceGroupId => $composableBuilder(
    column: $table.recurrenceGroupId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recurrenceRule => $composableBuilder(
    column: $table.recurrenceRule,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get completedAtMs => $composableBuilder(
    column: $table.completedAtMs,
    builder: (column) => column,
  );
}

class $$RemindersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RemindersTable,
          ReminderRow,
          $$RemindersTableFilterComposer,
          $$RemindersTableOrderingComposer,
          $$RemindersTableAnnotationComposer,
          $$RemindersTableCreateCompanionBuilder,
          $$RemindersTableUpdateCompanionBuilder,
          (
            ReminderRow,
            BaseReferences<_$AppDatabase, $RemindersTable, ReminderRow>,
          ),
          ReminderRow,
          PrefetchHooks Function()
        > {
  $$RemindersTableTableManager(_$AppDatabase db, $RemindersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RemindersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RemindersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RemindersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<int?> scheduledAtMs = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> importance = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> object = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<bool> hasNotification = const Value.absent(),
                Value<int?> notificationId = const Value.absent(),
                Value<int?> lastNotifiedAtMs = const Value.absent(),
                Value<int?> snoozedUntilMs = const Value.absent(),
                Value<String?> recurrenceGroupId = const Value.absent(),
                Value<String?> recurrenceRule = const Value.absent(),
                Value<int> createdAtMs = const Value.absent(),
                Value<int?> updatedAtMs = const Value.absent(),
                Value<int?> completedAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RemindersCompanion(
                id: id,
                title: title,
                description: description,
                scheduledAtMs: scheduledAtMs,
                type: type,
                status: status,
                importance: importance,
                source: source,
                object: object,
                location: location,
                hasNotification: hasNotification,
                notificationId: notificationId,
                lastNotifiedAtMs: lastNotifiedAtMs,
                snoozedUntilMs: snoozedUntilMs,
                recurrenceGroupId: recurrenceGroupId,
                recurrenceRule: recurrenceRule,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                completedAtMs: completedAtMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String description,
                Value<int?> scheduledAtMs = const Value.absent(),
                required String type,
                required String status,
                Value<String> importance = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> object = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<bool> hasNotification = const Value.absent(),
                Value<int?> notificationId = const Value.absent(),
                Value<int?> lastNotifiedAtMs = const Value.absent(),
                Value<int?> snoozedUntilMs = const Value.absent(),
                Value<String?> recurrenceGroupId = const Value.absent(),
                Value<String?> recurrenceRule = const Value.absent(),
                required int createdAtMs,
                Value<int?> updatedAtMs = const Value.absent(),
                Value<int?> completedAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RemindersCompanion.insert(
                id: id,
                title: title,
                description: description,
                scheduledAtMs: scheduledAtMs,
                type: type,
                status: status,
                importance: importance,
                source: source,
                object: object,
                location: location,
                hasNotification: hasNotification,
                notificationId: notificationId,
                lastNotifiedAtMs: lastNotifiedAtMs,
                snoozedUntilMs: snoozedUntilMs,
                recurrenceGroupId: recurrenceGroupId,
                recurrenceRule: recurrenceRule,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                completedAtMs: completedAtMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RemindersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RemindersTable,
      ReminderRow,
      $$RemindersTableFilterComposer,
      $$RemindersTableOrderingComposer,
      $$RemindersTableAnnotationComposer,
      $$RemindersTableCreateCompanionBuilder,
      $$RemindersTableUpdateCompanionBuilder,
      (
        ReminderRow,
        BaseReferences<_$AppDatabase, $RemindersTable, ReminderRow>,
      ),
      ReminderRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$RemindersTableTableManager get reminders =>
      $$RemindersTableTableManager(_db, _db.reminders);
}
