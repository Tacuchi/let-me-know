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
  final int? scheduledAtMs;
  final String type;
  final String status;
  final String importance;
  final String source;
  final String? object;
  final String? location;
  final bool hasNotification;
  final int? notificationId;
  final int? lastNotifiedAtMs;
  final int? snoozedUntilMs;
  final String? recurrenceGroupId;
  final String? recurrenceRule;
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

class $ReminderGroupsTable extends ReminderGroups
    with TableInfo<$ReminderGroupsTable, ReminderGroupRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReminderGroupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _itemCountMeta = const VerificationMeta(
    'itemCount',
  );
  @override
  late final GeneratedColumn<int> itemCount = GeneratedColumn<int>(
    'item_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    label,
    type,
    itemCount,
    createdAtMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminder_groups';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReminderGroupRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('item_count')) {
      context.handle(
        _itemCountMeta,
        itemCount.isAcceptableOrUnknown(data['item_count']!, _itemCountMeta),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReminderGroupRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReminderGroupRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      itemCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}item_count'],
      )!,
      createdAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_ms'],
      )!,
    );
  }

  @override
  $ReminderGroupsTable createAlias(String alias) {
    return $ReminderGroupsTable(attachedDatabase, alias);
  }
}

class ReminderGroupRow extends DataClass
    implements Insertable<ReminderGroupRow> {
  final String id;
  final String label;
  final String type;
  final int itemCount;
  final int createdAtMs;
  const ReminderGroupRow({
    required this.id,
    required this.label,
    required this.type,
    required this.itemCount,
    required this.createdAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['label'] = Variable<String>(label);
    map['type'] = Variable<String>(type);
    map['item_count'] = Variable<int>(itemCount);
    map['created_at_ms'] = Variable<int>(createdAtMs);
    return map;
  }

  ReminderGroupsCompanion toCompanion(bool nullToAbsent) {
    return ReminderGroupsCompanion(
      id: Value(id),
      label: Value(label),
      type: Value(type),
      itemCount: Value(itemCount),
      createdAtMs: Value(createdAtMs),
    );
  }

  factory ReminderGroupRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReminderGroupRow(
      id: serializer.fromJson<String>(json['id']),
      label: serializer.fromJson<String>(json['label']),
      type: serializer.fromJson<String>(json['type']),
      itemCount: serializer.fromJson<int>(json['itemCount']),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'label': serializer.toJson<String>(label),
      'type': serializer.toJson<String>(type),
      'itemCount': serializer.toJson<int>(itemCount),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
    };
  }

  ReminderGroupRow copyWith({
    String? id,
    String? label,
    String? type,
    int? itemCount,
    int? createdAtMs,
  }) => ReminderGroupRow(
    id: id ?? this.id,
    label: label ?? this.label,
    type: type ?? this.type,
    itemCount: itemCount ?? this.itemCount,
    createdAtMs: createdAtMs ?? this.createdAtMs,
  );
  ReminderGroupRow copyWithCompanion(ReminderGroupsCompanion data) {
    return ReminderGroupRow(
      id: data.id.present ? data.id.value : this.id,
      label: data.label.present ? data.label.value : this.label,
      type: data.type.present ? data.type.value : this.type,
      itemCount: data.itemCount.present ? data.itemCount.value : this.itemCount,
      createdAtMs: data.createdAtMs.present
          ? data.createdAtMs.value
          : this.createdAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReminderGroupRow(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('type: $type, ')
          ..write('itemCount: $itemCount, ')
          ..write('createdAtMs: $createdAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, label, type, itemCount, createdAtMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReminderGroupRow &&
          other.id == this.id &&
          other.label == this.label &&
          other.type == this.type &&
          other.itemCount == this.itemCount &&
          other.createdAtMs == this.createdAtMs);
}

class ReminderGroupsCompanion extends UpdateCompanion<ReminderGroupRow> {
  final Value<String> id;
  final Value<String> label;
  final Value<String> type;
  final Value<int> itemCount;
  final Value<int> createdAtMs;
  final Value<int> rowid;
  const ReminderGroupsCompanion({
    this.id = const Value.absent(),
    this.label = const Value.absent(),
    this.type = const Value.absent(),
    this.itemCount = const Value.absent(),
    this.createdAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReminderGroupsCompanion.insert({
    required String id,
    required String label,
    required String type,
    this.itemCount = const Value.absent(),
    required int createdAtMs,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       label = Value(label),
       type = Value(type),
       createdAtMs = Value(createdAtMs);
  static Insertable<ReminderGroupRow> custom({
    Expression<String>? id,
    Expression<String>? label,
    Expression<String>? type,
    Expression<int>? itemCount,
    Expression<int>? createdAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (label != null) 'label': label,
      if (type != null) 'type': type,
      if (itemCount != null) 'item_count': itemCount,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReminderGroupsCompanion copyWith({
    Value<String>? id,
    Value<String>? label,
    Value<String>? type,
    Value<int>? itemCount,
    Value<int>? createdAtMs,
    Value<int>? rowid,
  }) {
    return ReminderGroupsCompanion(
      id: id ?? this.id,
      label: label ?? this.label,
      type: type ?? this.type,
      itemCount: itemCount ?? this.itemCount,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (itemCount.present) {
      map['item_count'] = Variable<int>(itemCount.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReminderGroupsCompanion(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('type: $type, ')
          ..write('itemCount: $itemCount, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ActionHistoryTable extends ActionHistory
    with TableInfo<$ActionHistoryTable, ActionHistoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActionHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reminderIdMeta = const VerificationMeta(
    'reminderId',
  );
  @override
  late final GeneratedColumn<String> reminderId = GeneratedColumn<String>(
    'reminder_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reminderTitleMeta = const VerificationMeta(
    'reminderTitle',
  );
  @override
  late final GeneratedColumn<String> reminderTitle = GeneratedColumn<String>(
    'reminder_title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _groupLabelMeta = const VerificationMeta(
    'groupLabel',
  );
  @override
  late final GeneratedColumn<String> groupLabel = GeneratedColumn<String>(
    'group_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actionAtMsMeta = const VerificationMeta(
    'actionAtMs',
  );
  @override
  late final GeneratedColumn<int> actionAtMs = GeneratedColumn<int>(
    'action_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    action,
    reminderId,
    reminderTitle,
    groupId,
    groupLabel,
    actionAtMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'action_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<ActionHistoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('reminder_id')) {
      context.handle(
        _reminderIdMeta,
        reminderId.isAcceptableOrUnknown(data['reminder_id']!, _reminderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_reminderIdMeta);
    }
    if (data.containsKey('reminder_title')) {
      context.handle(
        _reminderTitleMeta,
        reminderTitle.isAcceptableOrUnknown(
          data['reminder_title']!,
          _reminderTitleMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_reminderTitleMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    }
    if (data.containsKey('group_label')) {
      context.handle(
        _groupLabelMeta,
        groupLabel.isAcceptableOrUnknown(data['group_label']!, _groupLabelMeta),
      );
    }
    if (data.containsKey('action_at_ms')) {
      context.handle(
        _actionAtMsMeta,
        actionAtMs.isAcceptableOrUnknown(
          data['action_at_ms']!,
          _actionAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_actionAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ActionHistoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActionHistoryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      reminderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reminder_id'],
      )!,
      reminderTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reminder_title'],
      )!,
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      ),
      groupLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_label'],
      ),
      actionAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}action_at_ms'],
      )!,
    );
  }

  @override
  $ActionHistoryTable createAlias(String alias) {
    return $ActionHistoryTable(attachedDatabase, alias);
  }
}

class ActionHistoryRow extends DataClass
    implements Insertable<ActionHistoryRow> {
  final String id;
  final String action;
  final String reminderId;
  final String reminderTitle;
  final String? groupId;
  final String? groupLabel;
  final int actionAtMs;
  const ActionHistoryRow({
    required this.id,
    required this.action,
    required this.reminderId,
    required this.reminderTitle,
    this.groupId,
    this.groupLabel,
    required this.actionAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['action'] = Variable<String>(action);
    map['reminder_id'] = Variable<String>(reminderId);
    map['reminder_title'] = Variable<String>(reminderTitle);
    if (!nullToAbsent || groupId != null) {
      map['group_id'] = Variable<String>(groupId);
    }
    if (!nullToAbsent || groupLabel != null) {
      map['group_label'] = Variable<String>(groupLabel);
    }
    map['action_at_ms'] = Variable<int>(actionAtMs);
    return map;
  }

  ActionHistoryCompanion toCompanion(bool nullToAbsent) {
    return ActionHistoryCompanion(
      id: Value(id),
      action: Value(action),
      reminderId: Value(reminderId),
      reminderTitle: Value(reminderTitle),
      groupId: groupId == null && nullToAbsent
          ? const Value.absent()
          : Value(groupId),
      groupLabel: groupLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(groupLabel),
      actionAtMs: Value(actionAtMs),
    );
  }

  factory ActionHistoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActionHistoryRow(
      id: serializer.fromJson<String>(json['id']),
      action: serializer.fromJson<String>(json['action']),
      reminderId: serializer.fromJson<String>(json['reminderId']),
      reminderTitle: serializer.fromJson<String>(json['reminderTitle']),
      groupId: serializer.fromJson<String?>(json['groupId']),
      groupLabel: serializer.fromJson<String?>(json['groupLabel']),
      actionAtMs: serializer.fromJson<int>(json['actionAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'action': serializer.toJson<String>(action),
      'reminderId': serializer.toJson<String>(reminderId),
      'reminderTitle': serializer.toJson<String>(reminderTitle),
      'groupId': serializer.toJson<String?>(groupId),
      'groupLabel': serializer.toJson<String?>(groupLabel),
      'actionAtMs': serializer.toJson<int>(actionAtMs),
    };
  }

  ActionHistoryRow copyWith({
    String? id,
    String? action,
    String? reminderId,
    String? reminderTitle,
    Value<String?> groupId = const Value.absent(),
    Value<String?> groupLabel = const Value.absent(),
    int? actionAtMs,
  }) => ActionHistoryRow(
    id: id ?? this.id,
    action: action ?? this.action,
    reminderId: reminderId ?? this.reminderId,
    reminderTitle: reminderTitle ?? this.reminderTitle,
    groupId: groupId.present ? groupId.value : this.groupId,
    groupLabel: groupLabel.present ? groupLabel.value : this.groupLabel,
    actionAtMs: actionAtMs ?? this.actionAtMs,
  );
  ActionHistoryRow copyWithCompanion(ActionHistoryCompanion data) {
    return ActionHistoryRow(
      id: data.id.present ? data.id.value : this.id,
      action: data.action.present ? data.action.value : this.action,
      reminderId: data.reminderId.present
          ? data.reminderId.value
          : this.reminderId,
      reminderTitle: data.reminderTitle.present
          ? data.reminderTitle.value
          : this.reminderTitle,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      groupLabel: data.groupLabel.present
          ? data.groupLabel.value
          : this.groupLabel,
      actionAtMs: data.actionAtMs.present
          ? data.actionAtMs.value
          : this.actionAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActionHistoryRow(')
          ..write('id: $id, ')
          ..write('action: $action, ')
          ..write('reminderId: $reminderId, ')
          ..write('reminderTitle: $reminderTitle, ')
          ..write('groupId: $groupId, ')
          ..write('groupLabel: $groupLabel, ')
          ..write('actionAtMs: $actionAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    action,
    reminderId,
    reminderTitle,
    groupId,
    groupLabel,
    actionAtMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActionHistoryRow &&
          other.id == this.id &&
          other.action == this.action &&
          other.reminderId == this.reminderId &&
          other.reminderTitle == this.reminderTitle &&
          other.groupId == this.groupId &&
          other.groupLabel == this.groupLabel &&
          other.actionAtMs == this.actionAtMs);
}

class ActionHistoryCompanion extends UpdateCompanion<ActionHistoryRow> {
  final Value<String> id;
  final Value<String> action;
  final Value<String> reminderId;
  final Value<String> reminderTitle;
  final Value<String?> groupId;
  final Value<String?> groupLabel;
  final Value<int> actionAtMs;
  final Value<int> rowid;
  const ActionHistoryCompanion({
    this.id = const Value.absent(),
    this.action = const Value.absent(),
    this.reminderId = const Value.absent(),
    this.reminderTitle = const Value.absent(),
    this.groupId = const Value.absent(),
    this.groupLabel = const Value.absent(),
    this.actionAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ActionHistoryCompanion.insert({
    required String id,
    required String action,
    required String reminderId,
    required String reminderTitle,
    this.groupId = const Value.absent(),
    this.groupLabel = const Value.absent(),
    required int actionAtMs,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       action = Value(action),
       reminderId = Value(reminderId),
       reminderTitle = Value(reminderTitle),
       actionAtMs = Value(actionAtMs);
  static Insertable<ActionHistoryRow> custom({
    Expression<String>? id,
    Expression<String>? action,
    Expression<String>? reminderId,
    Expression<String>? reminderTitle,
    Expression<String>? groupId,
    Expression<String>? groupLabel,
    Expression<int>? actionAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (action != null) 'action': action,
      if (reminderId != null) 'reminder_id': reminderId,
      if (reminderTitle != null) 'reminder_title': reminderTitle,
      if (groupId != null) 'group_id': groupId,
      if (groupLabel != null) 'group_label': groupLabel,
      if (actionAtMs != null) 'action_at_ms': actionAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ActionHistoryCompanion copyWith({
    Value<String>? id,
    Value<String>? action,
    Value<String>? reminderId,
    Value<String>? reminderTitle,
    Value<String?>? groupId,
    Value<String?>? groupLabel,
    Value<int>? actionAtMs,
    Value<int>? rowid,
  }) {
    return ActionHistoryCompanion(
      id: id ?? this.id,
      action: action ?? this.action,
      reminderId: reminderId ?? this.reminderId,
      reminderTitle: reminderTitle ?? this.reminderTitle,
      groupId: groupId ?? this.groupId,
      groupLabel: groupLabel ?? this.groupLabel,
      actionAtMs: actionAtMs ?? this.actionAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (reminderId.present) {
      map['reminder_id'] = Variable<String>(reminderId.value);
    }
    if (reminderTitle.present) {
      map['reminder_title'] = Variable<String>(reminderTitle.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (groupLabel.present) {
      map['group_label'] = Variable<String>(groupLabel.value);
    }
    if (actionAtMs.present) {
      map['action_at_ms'] = Variable<int>(actionAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActionHistoryCompanion(')
          ..write('id: $id, ')
          ..write('action: $action, ')
          ..write('reminderId: $reminderId, ')
          ..write('reminderTitle: $reminderTitle, ')
          ..write('groupId: $groupId, ')
          ..write('groupLabel: $groupLabel, ')
          ..write('actionAtMs: $actionAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $RemindersTable reminders = $RemindersTable(this);
  late final $ReminderGroupsTable reminderGroups = $ReminderGroupsTable(this);
  late final $ActionHistoryTable actionHistory = $ActionHistoryTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    reminders,
    reminderGroups,
    actionHistory,
  ];
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
typedef $$ReminderGroupsTableCreateCompanionBuilder =
    ReminderGroupsCompanion Function({
      required String id,
      required String label,
      required String type,
      Value<int> itemCount,
      required int createdAtMs,
      Value<int> rowid,
    });
typedef $$ReminderGroupsTableUpdateCompanionBuilder =
    ReminderGroupsCompanion Function({
      Value<String> id,
      Value<String> label,
      Value<String> type,
      Value<int> itemCount,
      Value<int> createdAtMs,
      Value<int> rowid,
    });

class $$ReminderGroupsTableFilterComposer
    extends Composer<_$AppDatabase, $ReminderGroupsTable> {
  $$ReminderGroupsTableFilterComposer({
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

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get itemCount => $composableBuilder(
    column: $table.itemCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReminderGroupsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReminderGroupsTable> {
  $$ReminderGroupsTableOrderingComposer({
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

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get itemCount => $composableBuilder(
    column: $table.itemCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReminderGroupsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReminderGroupsTable> {
  $$ReminderGroupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get itemCount =>
      $composableBuilder(column: $table.itemCount, builder: (column) => column);

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => column,
  );
}

class $$ReminderGroupsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReminderGroupsTable,
          ReminderGroupRow,
          $$ReminderGroupsTableFilterComposer,
          $$ReminderGroupsTableOrderingComposer,
          $$ReminderGroupsTableAnnotationComposer,
          $$ReminderGroupsTableCreateCompanionBuilder,
          $$ReminderGroupsTableUpdateCompanionBuilder,
          (
            ReminderGroupRow,
            BaseReferences<
              _$AppDatabase,
              $ReminderGroupsTable,
              ReminderGroupRow
            >,
          ),
          ReminderGroupRow,
          PrefetchHooks Function()
        > {
  $$ReminderGroupsTableTableManager(
    _$AppDatabase db,
    $ReminderGroupsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReminderGroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReminderGroupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReminderGroupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> itemCount = const Value.absent(),
                Value<int> createdAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReminderGroupsCompanion(
                id: id,
                label: label,
                type: type,
                itemCount: itemCount,
                createdAtMs: createdAtMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String label,
                required String type,
                Value<int> itemCount = const Value.absent(),
                required int createdAtMs,
                Value<int> rowid = const Value.absent(),
              }) => ReminderGroupsCompanion.insert(
                id: id,
                label: label,
                type: type,
                itemCount: itemCount,
                createdAtMs: createdAtMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReminderGroupsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReminderGroupsTable,
      ReminderGroupRow,
      $$ReminderGroupsTableFilterComposer,
      $$ReminderGroupsTableOrderingComposer,
      $$ReminderGroupsTableAnnotationComposer,
      $$ReminderGroupsTableCreateCompanionBuilder,
      $$ReminderGroupsTableUpdateCompanionBuilder,
      (
        ReminderGroupRow,
        BaseReferences<_$AppDatabase, $ReminderGroupsTable, ReminderGroupRow>,
      ),
      ReminderGroupRow,
      PrefetchHooks Function()
    >;
typedef $$ActionHistoryTableCreateCompanionBuilder =
    ActionHistoryCompanion Function({
      required String id,
      required String action,
      required String reminderId,
      required String reminderTitle,
      Value<String?> groupId,
      Value<String?> groupLabel,
      required int actionAtMs,
      Value<int> rowid,
    });
typedef $$ActionHistoryTableUpdateCompanionBuilder =
    ActionHistoryCompanion Function({
      Value<String> id,
      Value<String> action,
      Value<String> reminderId,
      Value<String> reminderTitle,
      Value<String?> groupId,
      Value<String?> groupLabel,
      Value<int> actionAtMs,
      Value<int> rowid,
    });

class $$ActionHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $ActionHistoryTable> {
  $$ActionHistoryTableFilterComposer({
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

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reminderId => $composableBuilder(
    column: $table.reminderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reminderTitle => $composableBuilder(
    column: $table.reminderTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get groupLabel => $composableBuilder(
    column: $table.groupLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get actionAtMs => $composableBuilder(
    column: $table.actionAtMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ActionHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $ActionHistoryTable> {
  $$ActionHistoryTableOrderingComposer({
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

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reminderId => $composableBuilder(
    column: $table.reminderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reminderTitle => $composableBuilder(
    column: $table.reminderTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupLabel => $composableBuilder(
    column: $table.groupLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get actionAtMs => $composableBuilder(
    column: $table.actionAtMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ActionHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActionHistoryTable> {
  $$ActionHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get reminderId => $composableBuilder(
    column: $table.reminderId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reminderTitle => $composableBuilder(
    column: $table.reminderTitle,
    builder: (column) => column,
  );

  GeneratedColumn<String> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<String> get groupLabel => $composableBuilder(
    column: $table.groupLabel,
    builder: (column) => column,
  );

  GeneratedColumn<int> get actionAtMs => $composableBuilder(
    column: $table.actionAtMs,
    builder: (column) => column,
  );
}

class $$ActionHistoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ActionHistoryTable,
          ActionHistoryRow,
          $$ActionHistoryTableFilterComposer,
          $$ActionHistoryTableOrderingComposer,
          $$ActionHistoryTableAnnotationComposer,
          $$ActionHistoryTableCreateCompanionBuilder,
          $$ActionHistoryTableUpdateCompanionBuilder,
          (
            ActionHistoryRow,
            BaseReferences<
              _$AppDatabase,
              $ActionHistoryTable,
              ActionHistoryRow
            >,
          ),
          ActionHistoryRow,
          PrefetchHooks Function()
        > {
  $$ActionHistoryTableTableManager(_$AppDatabase db, $ActionHistoryTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActionHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActionHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActionHistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<String> reminderId = const Value.absent(),
                Value<String> reminderTitle = const Value.absent(),
                Value<String?> groupId = const Value.absent(),
                Value<String?> groupLabel = const Value.absent(),
                Value<int> actionAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActionHistoryCompanion(
                id: id,
                action: action,
                reminderId: reminderId,
                reminderTitle: reminderTitle,
                groupId: groupId,
                groupLabel: groupLabel,
                actionAtMs: actionAtMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String action,
                required String reminderId,
                required String reminderTitle,
                Value<String?> groupId = const Value.absent(),
                Value<String?> groupLabel = const Value.absent(),
                required int actionAtMs,
                Value<int> rowid = const Value.absent(),
              }) => ActionHistoryCompanion.insert(
                id: id,
                action: action,
                reminderId: reminderId,
                reminderTitle: reminderTitle,
                groupId: groupId,
                groupLabel: groupLabel,
                actionAtMs: actionAtMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ActionHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ActionHistoryTable,
      ActionHistoryRow,
      $$ActionHistoryTableFilterComposer,
      $$ActionHistoryTableOrderingComposer,
      $$ActionHistoryTableAnnotationComposer,
      $$ActionHistoryTableCreateCompanionBuilder,
      $$ActionHistoryTableUpdateCompanionBuilder,
      (
        ActionHistoryRow,
        BaseReferences<_$AppDatabase, $ActionHistoryTable, ActionHistoryRow>,
      ),
      ActionHistoryRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$RemindersTableTableManager get reminders =>
      $$RemindersTableTableManager(_db, _db.reminders);
  $$ReminderGroupsTableTableManager get reminderGroups =>
      $$ReminderGroupsTableTableManager(_db, _db.reminderGroups);
  $$ActionHistoryTableTableManager get actionHistory =>
      $$ActionHistoryTableTableManager(_db, _db.actionHistory);
}
