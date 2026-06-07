// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ShiftsTableTable extends ShiftsTable
    with TableInfo<$ShiftsTableTable, ShiftsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShiftsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _driverNameMeta = const VerificationMeta(
    'driverName',
  );
  @override
  late final GeneratedColumn<String> driverName = GeneratedColumn<String>(
    'driver_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<String> startedAt = GeneratedColumn<String>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<String> endedAt = GeneratedColumn<String>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('open'),
  );
  static const VerificationMeta _totalEarningsCentsMeta =
      const VerificationMeta('totalEarningsCents');
  @override
  late final GeneratedColumn<int> totalEarningsCents = GeneratedColumn<int>(
    'total_earnings_cents',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deliveryCountMeta = const VerificationMeta(
    'deliveryCount',
  );
  @override
  late final GeneratedColumn<int> deliveryCount = GeneratedColumn<int>(
    'delivery_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('app'),
  );
  static const VerificationMeta _hoursWorkedMeta = const VerificationMeta(
    'hoursWorked',
  );
  @override
  late final GeneratedColumn<double> hoursWorked = GeneratedColumn<double>(
    'hours_worked',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fuelExpenseCentsMeta = const VerificationMeta(
    'fuelExpenseCents',
  );
  @override
  late final GeneratedColumn<int> fuelExpenseCents = GeneratedColumn<int>(
    'fuel_expense_cents',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    driverName,
    startedAt,
    endedAt,
    status,
    totalEarningsCents,
    deliveryCount,
    notes,
    createdAt,
    source,
    hoursWorked,
    fuelExpenseCents,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shifts';
  @override
  VerificationContext validateIntegrity(
    Insertable<ShiftsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('driver_name')) {
      context.handle(
        _driverNameMeta,
        driverName.isAcceptableOrUnknown(data['driver_name']!, _driverNameMeta),
      );
    } else if (isInserting) {
      context.missing(_driverNameMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('total_earnings_cents')) {
      context.handle(
        _totalEarningsCentsMeta,
        totalEarningsCents.isAcceptableOrUnknown(
          data['total_earnings_cents']!,
          _totalEarningsCentsMeta,
        ),
      );
    }
    if (data.containsKey('delivery_count')) {
      context.handle(
        _deliveryCountMeta,
        deliveryCount.isAcceptableOrUnknown(
          data['delivery_count']!,
          _deliveryCountMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('hours_worked')) {
      context.handle(
        _hoursWorkedMeta,
        hoursWorked.isAcceptableOrUnknown(
          data['hours_worked']!,
          _hoursWorkedMeta,
        ),
      );
    }
    if (data.containsKey('fuel_expense_cents')) {
      context.handle(
        _fuelExpenseCentsMeta,
        fuelExpenseCents.isAcceptableOrUnknown(
          data['fuel_expense_cents']!,
          _fuelExpenseCentsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ShiftsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShiftsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      driverName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}driver_name'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ended_at'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      totalEarningsCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_earnings_cents'],
      ),
      deliveryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}delivery_count'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      hoursWorked: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}hours_worked'],
      ),
      fuelExpenseCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fuel_expense_cents'],
      ),
    );
  }

  @override
  $ShiftsTableTable createAlias(String alias) {
    return $ShiftsTableTable(attachedDatabase, alias);
  }
}

class ShiftsTableData extends DataClass implements Insertable<ShiftsTableData> {
  final int id;
  final String driverName;
  final String startedAt;
  final String? endedAt;
  final String status;
  final int? totalEarningsCents;
  final int? deliveryCount;
  final String? notes;
  final String createdAt;
  final String source;
  final double? hoursWorked;
  final int? fuelExpenseCents;
  const ShiftsTableData({
    required this.id,
    required this.driverName,
    required this.startedAt,
    this.endedAt,
    required this.status,
    this.totalEarningsCents,
    this.deliveryCount,
    this.notes,
    required this.createdAt,
    required this.source,
    this.hoursWorked,
    this.fuelExpenseCents,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['driver_name'] = Variable<String>(driverName);
    map['started_at'] = Variable<String>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<String>(endedAt);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || totalEarningsCents != null) {
      map['total_earnings_cents'] = Variable<int>(totalEarningsCents);
    }
    if (!nullToAbsent || deliveryCount != null) {
      map['delivery_count'] = Variable<int>(deliveryCount);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<String>(createdAt);
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || hoursWorked != null) {
      map['hours_worked'] = Variable<double>(hoursWorked);
    }
    if (!nullToAbsent || fuelExpenseCents != null) {
      map['fuel_expense_cents'] = Variable<int>(fuelExpenseCents);
    }
    return map;
  }

  ShiftsTableCompanion toCompanion(bool nullToAbsent) {
    return ShiftsTableCompanion(
      id: Value(id),
      driverName: Value(driverName),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      status: Value(status),
      totalEarningsCents: totalEarningsCents == null && nullToAbsent
          ? const Value.absent()
          : Value(totalEarningsCents),
      deliveryCount: deliveryCount == null && nullToAbsent
          ? const Value.absent()
          : Value(deliveryCount),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
      source: Value(source),
      hoursWorked: hoursWorked == null && nullToAbsent
          ? const Value.absent()
          : Value(hoursWorked),
      fuelExpenseCents: fuelExpenseCents == null && nullToAbsent
          ? const Value.absent()
          : Value(fuelExpenseCents),
    );
  }

  factory ShiftsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShiftsTableData(
      id: serializer.fromJson<int>(json['id']),
      driverName: serializer.fromJson<String>(json['driverName']),
      startedAt: serializer.fromJson<String>(json['startedAt']),
      endedAt: serializer.fromJson<String?>(json['endedAt']),
      status: serializer.fromJson<String>(json['status']),
      totalEarningsCents: serializer.fromJson<int?>(json['totalEarningsCents']),
      deliveryCount: serializer.fromJson<int?>(json['deliveryCount']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      source: serializer.fromJson<String>(json['source']),
      hoursWorked: serializer.fromJson<double?>(json['hoursWorked']),
      fuelExpenseCents: serializer.fromJson<int?>(json['fuelExpenseCents']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'driverName': serializer.toJson<String>(driverName),
      'startedAt': serializer.toJson<String>(startedAt),
      'endedAt': serializer.toJson<String?>(endedAt),
      'status': serializer.toJson<String>(status),
      'totalEarningsCents': serializer.toJson<int?>(totalEarningsCents),
      'deliveryCount': serializer.toJson<int?>(deliveryCount),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<String>(createdAt),
      'source': serializer.toJson<String>(source),
      'hoursWorked': serializer.toJson<double?>(hoursWorked),
      'fuelExpenseCents': serializer.toJson<int?>(fuelExpenseCents),
    };
  }

  ShiftsTableData copyWith({
    int? id,
    String? driverName,
    String? startedAt,
    Value<String?> endedAt = const Value.absent(),
    String? status,
    Value<int?> totalEarningsCents = const Value.absent(),
    Value<int?> deliveryCount = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    String? createdAt,
    String? source,
    Value<double?> hoursWorked = const Value.absent(),
    Value<int?> fuelExpenseCents = const Value.absent(),
  }) => ShiftsTableData(
    id: id ?? this.id,
    driverName: driverName ?? this.driverName,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    status: status ?? this.status,
    totalEarningsCents: totalEarningsCents.present
        ? totalEarningsCents.value
        : this.totalEarningsCents,
    deliveryCount: deliveryCount.present
        ? deliveryCount.value
        : this.deliveryCount,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
    source: source ?? this.source,
    hoursWorked: hoursWorked.present ? hoursWorked.value : this.hoursWorked,
    fuelExpenseCents: fuelExpenseCents.present
        ? fuelExpenseCents.value
        : this.fuelExpenseCents,
  );
  ShiftsTableData copyWithCompanion(ShiftsTableCompanion data) {
    return ShiftsTableData(
      id: data.id.present ? data.id.value : this.id,
      driverName: data.driverName.present
          ? data.driverName.value
          : this.driverName,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      status: data.status.present ? data.status.value : this.status,
      totalEarningsCents: data.totalEarningsCents.present
          ? data.totalEarningsCents.value
          : this.totalEarningsCents,
      deliveryCount: data.deliveryCount.present
          ? data.deliveryCount.value
          : this.deliveryCount,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      source: data.source.present ? data.source.value : this.source,
      hoursWorked: data.hoursWorked.present
          ? data.hoursWorked.value
          : this.hoursWorked,
      fuelExpenseCents: data.fuelExpenseCents.present
          ? data.fuelExpenseCents.value
          : this.fuelExpenseCents,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShiftsTableData(')
          ..write('id: $id, ')
          ..write('driverName: $driverName, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('status: $status, ')
          ..write('totalEarningsCents: $totalEarningsCents, ')
          ..write('deliveryCount: $deliveryCount, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('source: $source, ')
          ..write('hoursWorked: $hoursWorked, ')
          ..write('fuelExpenseCents: $fuelExpenseCents')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    driverName,
    startedAt,
    endedAt,
    status,
    totalEarningsCents,
    deliveryCount,
    notes,
    createdAt,
    source,
    hoursWorked,
    fuelExpenseCents,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShiftsTableData &&
          other.id == this.id &&
          other.driverName == this.driverName &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.status == this.status &&
          other.totalEarningsCents == this.totalEarningsCents &&
          other.deliveryCount == this.deliveryCount &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.source == this.source &&
          other.hoursWorked == this.hoursWorked &&
          other.fuelExpenseCents == this.fuelExpenseCents);
}

class ShiftsTableCompanion extends UpdateCompanion<ShiftsTableData> {
  final Value<int> id;
  final Value<String> driverName;
  final Value<String> startedAt;
  final Value<String?> endedAt;
  final Value<String> status;
  final Value<int?> totalEarningsCents;
  final Value<int?> deliveryCount;
  final Value<String?> notes;
  final Value<String> createdAt;
  final Value<String> source;
  final Value<double?> hoursWorked;
  final Value<int?> fuelExpenseCents;
  const ShiftsTableCompanion({
    this.id = const Value.absent(),
    this.driverName = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.status = const Value.absent(),
    this.totalEarningsCents = const Value.absent(),
    this.deliveryCount = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.source = const Value.absent(),
    this.hoursWorked = const Value.absent(),
    this.fuelExpenseCents = const Value.absent(),
  });
  ShiftsTableCompanion.insert({
    this.id = const Value.absent(),
    required String driverName,
    required String startedAt,
    this.endedAt = const Value.absent(),
    this.status = const Value.absent(),
    this.totalEarningsCents = const Value.absent(),
    this.deliveryCount = const Value.absent(),
    this.notes = const Value.absent(),
    required String createdAt,
    this.source = const Value.absent(),
    this.hoursWorked = const Value.absent(),
    this.fuelExpenseCents = const Value.absent(),
  }) : driverName = Value(driverName),
       startedAt = Value(startedAt),
       createdAt = Value(createdAt);
  static Insertable<ShiftsTableData> custom({
    Expression<int>? id,
    Expression<String>? driverName,
    Expression<String>? startedAt,
    Expression<String>? endedAt,
    Expression<String>? status,
    Expression<int>? totalEarningsCents,
    Expression<int>? deliveryCount,
    Expression<String>? notes,
    Expression<String>? createdAt,
    Expression<String>? source,
    Expression<double>? hoursWorked,
    Expression<int>? fuelExpenseCents,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (driverName != null) 'driver_name': driverName,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (status != null) 'status': status,
      if (totalEarningsCents != null)
        'total_earnings_cents': totalEarningsCents,
      if (deliveryCount != null) 'delivery_count': deliveryCount,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (source != null) 'source': source,
      if (hoursWorked != null) 'hours_worked': hoursWorked,
      if (fuelExpenseCents != null) 'fuel_expense_cents': fuelExpenseCents,
    });
  }

  ShiftsTableCompanion copyWith({
    Value<int>? id,
    Value<String>? driverName,
    Value<String>? startedAt,
    Value<String?>? endedAt,
    Value<String>? status,
    Value<int?>? totalEarningsCents,
    Value<int?>? deliveryCount,
    Value<String?>? notes,
    Value<String>? createdAt,
    Value<String>? source,
    Value<double?>? hoursWorked,
    Value<int?>? fuelExpenseCents,
  }) {
    return ShiftsTableCompanion(
      id: id ?? this.id,
      driverName: driverName ?? this.driverName,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      status: status ?? this.status,
      totalEarningsCents: totalEarningsCents ?? this.totalEarningsCents,
      deliveryCount: deliveryCount ?? this.deliveryCount,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      source: source ?? this.source,
      hoursWorked: hoursWorked ?? this.hoursWorked,
      fuelExpenseCents: fuelExpenseCents ?? this.fuelExpenseCents,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (driverName.present) {
      map['driver_name'] = Variable<String>(driverName.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<String>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<String>(endedAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (totalEarningsCents.present) {
      map['total_earnings_cents'] = Variable<int>(totalEarningsCents.value);
    }
    if (deliveryCount.present) {
      map['delivery_count'] = Variable<int>(deliveryCount.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (hoursWorked.present) {
      map['hours_worked'] = Variable<double>(hoursWorked.value);
    }
    if (fuelExpenseCents.present) {
      map['fuel_expense_cents'] = Variable<int>(fuelExpenseCents.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShiftsTableCompanion(')
          ..write('id: $id, ')
          ..write('driverName: $driverName, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('status: $status, ')
          ..write('totalEarningsCents: $totalEarningsCents, ')
          ..write('deliveryCount: $deliveryCount, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('source: $source, ')
          ..write('hoursWorked: $hoursWorked, ')
          ..write('fuelExpenseCents: $fuelExpenseCents')
          ..write(')'))
        .toString();
  }
}

class $RoutesTableTable extends RoutesTable
    with TableInfo<$RoutesTableTable, RoutesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _shiftIdMeta = const VerificationMeta(
    'shiftId',
  );
  @override
  late final GeneratedColumn<int> shiftId = GeneratedColumn<int>(
    'shift_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES shifts (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _routeNumberMeta = const VerificationMeta(
    'routeNumber',
  );
  @override
  late final GeneratedColumn<int> routeNumber = GeneratedColumn<int>(
    'route_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('open'),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<String> startedAt = GeneratedColumn<String>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _closedAtMeta = const VerificationMeta(
    'closedAt',
  );
  @override
  late final GeneratedColumn<String> closedAt = GeneratedColumn<String>(
    'closed_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deliveryCountAtCloseMeta =
      const VerificationMeta('deliveryCountAtClose');
  @override
  late final GeneratedColumn<int> deliveryCountAtClose = GeneratedColumn<int>(
    'delivery_count_at_close',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    shiftId,
    routeNumber,
    status,
    startedAt,
    closedAt,
    deliveryCountAtClose,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'routes';
  @override
  VerificationContext validateIntegrity(
    Insertable<RoutesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('shift_id')) {
      context.handle(
        _shiftIdMeta,
        shiftId.isAcceptableOrUnknown(data['shift_id']!, _shiftIdMeta),
      );
    } else if (isInserting) {
      context.missing(_shiftIdMeta);
    }
    if (data.containsKey('route_number')) {
      context.handle(
        _routeNumberMeta,
        routeNumber.isAcceptableOrUnknown(
          data['route_number']!,
          _routeNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_routeNumberMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('closed_at')) {
      context.handle(
        _closedAtMeta,
        closedAt.isAcceptableOrUnknown(data['closed_at']!, _closedAtMeta),
      );
    }
    if (data.containsKey('delivery_count_at_close')) {
      context.handle(
        _deliveryCountAtCloseMeta,
        deliveryCountAtClose.isAcceptableOrUnknown(
          data['delivery_count_at_close']!,
          _deliveryCountAtCloseMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {shiftId, routeNumber},
  ];
  @override
  RoutesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoutesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      shiftId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}shift_id'],
      )!,
      routeNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}route_number'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}started_at'],
      )!,
      closedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}closed_at'],
      ),
      deliveryCountAtClose: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}delivery_count_at_close'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $RoutesTableTable createAlias(String alias) {
    return $RoutesTableTable(attachedDatabase, alias);
  }
}

class RoutesTableData extends DataClass implements Insertable<RoutesTableData> {
  final int id;
  final int shiftId;
  final int routeNumber;
  final String status;
  final String startedAt;
  final String? closedAt;
  final int? deliveryCountAtClose;
  final String createdAt;
  const RoutesTableData({
    required this.id,
    required this.shiftId,
    required this.routeNumber,
    required this.status,
    required this.startedAt,
    this.closedAt,
    this.deliveryCountAtClose,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['shift_id'] = Variable<int>(shiftId);
    map['route_number'] = Variable<int>(routeNumber);
    map['status'] = Variable<String>(status);
    map['started_at'] = Variable<String>(startedAt);
    if (!nullToAbsent || closedAt != null) {
      map['closed_at'] = Variable<String>(closedAt);
    }
    if (!nullToAbsent || deliveryCountAtClose != null) {
      map['delivery_count_at_close'] = Variable<int>(deliveryCountAtClose);
    }
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  RoutesTableCompanion toCompanion(bool nullToAbsent) {
    return RoutesTableCompanion(
      id: Value(id),
      shiftId: Value(shiftId),
      routeNumber: Value(routeNumber),
      status: Value(status),
      startedAt: Value(startedAt),
      closedAt: closedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(closedAt),
      deliveryCountAtClose: deliveryCountAtClose == null && nullToAbsent
          ? const Value.absent()
          : Value(deliveryCountAtClose),
      createdAt: Value(createdAt),
    );
  }

  factory RoutesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoutesTableData(
      id: serializer.fromJson<int>(json['id']),
      shiftId: serializer.fromJson<int>(json['shiftId']),
      routeNumber: serializer.fromJson<int>(json['routeNumber']),
      status: serializer.fromJson<String>(json['status']),
      startedAt: serializer.fromJson<String>(json['startedAt']),
      closedAt: serializer.fromJson<String?>(json['closedAt']),
      deliveryCountAtClose: serializer.fromJson<int?>(
        json['deliveryCountAtClose'],
      ),
      createdAt: serializer.fromJson<String>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'shiftId': serializer.toJson<int>(shiftId),
      'routeNumber': serializer.toJson<int>(routeNumber),
      'status': serializer.toJson<String>(status),
      'startedAt': serializer.toJson<String>(startedAt),
      'closedAt': serializer.toJson<String?>(closedAt),
      'deliveryCountAtClose': serializer.toJson<int?>(deliveryCountAtClose),
      'createdAt': serializer.toJson<String>(createdAt),
    };
  }

  RoutesTableData copyWith({
    int? id,
    int? shiftId,
    int? routeNumber,
    String? status,
    String? startedAt,
    Value<String?> closedAt = const Value.absent(),
    Value<int?> deliveryCountAtClose = const Value.absent(),
    String? createdAt,
  }) => RoutesTableData(
    id: id ?? this.id,
    shiftId: shiftId ?? this.shiftId,
    routeNumber: routeNumber ?? this.routeNumber,
    status: status ?? this.status,
    startedAt: startedAt ?? this.startedAt,
    closedAt: closedAt.present ? closedAt.value : this.closedAt,
    deliveryCountAtClose: deliveryCountAtClose.present
        ? deliveryCountAtClose.value
        : this.deliveryCountAtClose,
    createdAt: createdAt ?? this.createdAt,
  );
  RoutesTableData copyWithCompanion(RoutesTableCompanion data) {
    return RoutesTableData(
      id: data.id.present ? data.id.value : this.id,
      shiftId: data.shiftId.present ? data.shiftId.value : this.shiftId,
      routeNumber: data.routeNumber.present
          ? data.routeNumber.value
          : this.routeNumber,
      status: data.status.present ? data.status.value : this.status,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      closedAt: data.closedAt.present ? data.closedAt.value : this.closedAt,
      deliveryCountAtClose: data.deliveryCountAtClose.present
          ? data.deliveryCountAtClose.value
          : this.deliveryCountAtClose,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoutesTableData(')
          ..write('id: $id, ')
          ..write('shiftId: $shiftId, ')
          ..write('routeNumber: $routeNumber, ')
          ..write('status: $status, ')
          ..write('startedAt: $startedAt, ')
          ..write('closedAt: $closedAt, ')
          ..write('deliveryCountAtClose: $deliveryCountAtClose, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    shiftId,
    routeNumber,
    status,
    startedAt,
    closedAt,
    deliveryCountAtClose,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoutesTableData &&
          other.id == this.id &&
          other.shiftId == this.shiftId &&
          other.routeNumber == this.routeNumber &&
          other.status == this.status &&
          other.startedAt == this.startedAt &&
          other.closedAt == this.closedAt &&
          other.deliveryCountAtClose == this.deliveryCountAtClose &&
          other.createdAt == this.createdAt);
}

class RoutesTableCompanion extends UpdateCompanion<RoutesTableData> {
  final Value<int> id;
  final Value<int> shiftId;
  final Value<int> routeNumber;
  final Value<String> status;
  final Value<String> startedAt;
  final Value<String?> closedAt;
  final Value<int?> deliveryCountAtClose;
  final Value<String> createdAt;
  const RoutesTableCompanion({
    this.id = const Value.absent(),
    this.shiftId = const Value.absent(),
    this.routeNumber = const Value.absent(),
    this.status = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.closedAt = const Value.absent(),
    this.deliveryCountAtClose = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  RoutesTableCompanion.insert({
    this.id = const Value.absent(),
    required int shiftId,
    required int routeNumber,
    this.status = const Value.absent(),
    required String startedAt,
    this.closedAt = const Value.absent(),
    this.deliveryCountAtClose = const Value.absent(),
    required String createdAt,
  }) : shiftId = Value(shiftId),
       routeNumber = Value(routeNumber),
       startedAt = Value(startedAt),
       createdAt = Value(createdAt);
  static Insertable<RoutesTableData> custom({
    Expression<int>? id,
    Expression<int>? shiftId,
    Expression<int>? routeNumber,
    Expression<String>? status,
    Expression<String>? startedAt,
    Expression<String>? closedAt,
    Expression<int>? deliveryCountAtClose,
    Expression<String>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (shiftId != null) 'shift_id': shiftId,
      if (routeNumber != null) 'route_number': routeNumber,
      if (status != null) 'status': status,
      if (startedAt != null) 'started_at': startedAt,
      if (closedAt != null) 'closed_at': closedAt,
      if (deliveryCountAtClose != null)
        'delivery_count_at_close': deliveryCountAtClose,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  RoutesTableCompanion copyWith({
    Value<int>? id,
    Value<int>? shiftId,
    Value<int>? routeNumber,
    Value<String>? status,
    Value<String>? startedAt,
    Value<String?>? closedAt,
    Value<int?>? deliveryCountAtClose,
    Value<String>? createdAt,
  }) {
    return RoutesTableCompanion(
      id: id ?? this.id,
      shiftId: shiftId ?? this.shiftId,
      routeNumber: routeNumber ?? this.routeNumber,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      closedAt: closedAt ?? this.closedAt,
      deliveryCountAtClose: deliveryCountAtClose ?? this.deliveryCountAtClose,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (shiftId.present) {
      map['shift_id'] = Variable<int>(shiftId.value);
    }
    if (routeNumber.present) {
      map['route_number'] = Variable<int>(routeNumber.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<String>(startedAt.value);
    }
    if (closedAt.present) {
      map['closed_at'] = Variable<String>(closedAt.value);
    }
    if (deliveryCountAtClose.present) {
      map['delivery_count_at_close'] = Variable<int>(
        deliveryCountAtClose.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoutesTableCompanion(')
          ..write('id: $id, ')
          ..write('shiftId: $shiftId, ')
          ..write('routeNumber: $routeNumber, ')
          ..write('status: $status, ')
          ..write('startedAt: $startedAt, ')
          ..write('closedAt: $closedAt, ')
          ..write('deliveryCountAtClose: $deliveryCountAtClose, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $DeliveriesTableTable extends DeliveriesTable
    with TableInfo<$DeliveriesTableTable, DeliveriesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DeliveriesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _routeIdMeta = const VerificationMeta(
    'routeId',
  );
  @override
  late final GeneratedColumn<int> routeId = GeneratedColumn<int>(
    'route_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES routes (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _shiftIdMeta = const VerificationMeta(
    'shiftId',
  );
  @override
  late final GeneratedColumn<int> shiftId = GeneratedColumn<int>(
    'shift_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES shifts (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sequenceNumberMeta = const VerificationMeta(
    'sequenceNumber',
  );
  @override
  late final GeneratedColumn<int> sequenceNumber = GeneratedColumn<int>(
    'sequence_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _customerNameMeta = const VerificationMeta(
    'customerName',
  );
  @override
  late final GeneratedColumn<String> customerName = GeneratedColumn<String>(
    'customer_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressTextMeta = const VerificationMeta(
    'addressText',
  );
  @override
  late final GeneratedColumn<String> addressText = GeneratedColumn<String>(
    'address_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _distanceKmMeta = const VerificationMeta(
    'distanceKm',
  );
  @override
  late final GeneratedColumn<double> distanceKm = GeneratedColumn<double>(
    'distance_km',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _orderNumberMeta = const VerificationMeta(
    'orderNumber',
  );
  @override
  late final GeneratedColumn<String> orderNumber = GeneratedColumn<String>(
    'order_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _orderValueCentsMeta = const VerificationMeta(
    'orderValueCents',
  );
  @override
  late final GeneratedColumn<int> orderValueCents = GeneratedColumn<int>(
    'order_value_cents',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ocrRawTextMeta = const VerificationMeta(
    'ocrRawText',
  );
  @override
  late final GeneratedColumn<String> ocrRawText = GeneratedColumn<String>(
    'ocr_raw_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<String> completedAt = GeneratedColumn<String>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _needsIfoodConfirmationMeta =
      const VerificationMeta('needsIfoodConfirmation');
  @override
  late final GeneratedColumn<bool> needsIfoodConfirmation =
      GeneratedColumn<bool>(
        'needs_ifood_confirmation',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("needs_ifood_confirmation" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _deliveryIdentifierMeta =
      const VerificationMeta('deliveryIdentifier');
  @override
  late final GeneratedColumn<String> deliveryIdentifier =
      GeneratedColumn<String>(
        'delivery_identifier',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _partnerCollectionCodeMeta =
      const VerificationMeta('partnerCollectionCode');
  @override
  late final GeneratedColumn<String> partnerCollectionCode =
      GeneratedColumn<String>(
        'partner_collection_code',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _ifoodConfirmationSuccessMeta =
      const VerificationMeta('ifoodConfirmationSuccess');
  @override
  late final GeneratedColumn<bool> ifoodConfirmationSuccess =
      GeneratedColumn<bool>(
        'ifood_confirmation_success',
        aliasedName,
        true,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("ifood_confirmation_success" IN (0, 1))',
        ),
      );
  static const VerificationMeta _ifoodConfirmedAtMeta = const VerificationMeta(
    'ifoodConfirmedAt',
  );
  @override
  late final GeneratedColumn<String> ifoodConfirmedAt = GeneratedColumn<String>(
    'ifood_confirmed_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hasDrinksMeta = const VerificationMeta(
    'hasDrinks',
  );
  @override
  late final GeneratedColumn<bool> hasDrinks = GeneratedColumn<bool>(
    'has_drinks',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_drinks" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _needsCardMeta = const VerificationMeta(
    'needsCard',
  );
  @override
  late final GeneratedColumn<bool> needsCard = GeneratedColumn<bool>(
    'needs_card',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("needs_card" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _needsChangeMeta = const VerificationMeta(
    'needsChange',
  );
  @override
  late final GeneratedColumn<bool> needsChange = GeneratedColumn<bool>(
    'needs_change',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("needs_change" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _changeAmountCentsMeta = const VerificationMeta(
    'changeAmountCents',
  );
  @override
  late final GeneratedColumn<int> changeAmountCents = GeneratedColumn<int>(
    'change_amount_cents',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pizzaNumberMeta = const VerificationMeta(
    'pizzaNumber',
  );
  @override
  late final GeneratedColumn<String> pizzaNumber = GeneratedColumn<String>(
    'pizza_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _houseNumberMeta = const VerificationMeta(
    'houseNumber',
  );
  @override
  late final GeneratedColumn<String> houseNumber = GeneratedColumn<String>(
    'house_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    routeId,
    shiftId,
    sequenceNumber,
    status,
    customerName,
    addressText,
    distanceKm,
    orderNumber,
    orderValueCents,
    ocrRawText,
    completedAt,
    createdAt,
    needsIfoodConfirmation,
    deliveryIdentifier,
    partnerCollectionCode,
    ifoodConfirmationSuccess,
    ifoodConfirmedAt,
    hasDrinks,
    needsCard,
    needsChange,
    changeAmountCents,
    pizzaNumber,
    houseNumber,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'deliveries';
  @override
  VerificationContext validateIntegrity(
    Insertable<DeliveriesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('route_id')) {
      context.handle(
        _routeIdMeta,
        routeId.isAcceptableOrUnknown(data['route_id']!, _routeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_routeIdMeta);
    }
    if (data.containsKey('shift_id')) {
      context.handle(
        _shiftIdMeta,
        shiftId.isAcceptableOrUnknown(data['shift_id']!, _shiftIdMeta),
      );
    } else if (isInserting) {
      context.missing(_shiftIdMeta);
    }
    if (data.containsKey('sequence_number')) {
      context.handle(
        _sequenceNumberMeta,
        sequenceNumber.isAcceptableOrUnknown(
          data['sequence_number']!,
          _sequenceNumberMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('customer_name')) {
      context.handle(
        _customerNameMeta,
        customerName.isAcceptableOrUnknown(
          data['customer_name']!,
          _customerNameMeta,
        ),
      );
    }
    if (data.containsKey('address_text')) {
      context.handle(
        _addressTextMeta,
        addressText.isAcceptableOrUnknown(
          data['address_text']!,
          _addressTextMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_addressTextMeta);
    }
    if (data.containsKey('distance_km')) {
      context.handle(
        _distanceKmMeta,
        distanceKm.isAcceptableOrUnknown(data['distance_km']!, _distanceKmMeta),
      );
    }
    if (data.containsKey('order_number')) {
      context.handle(
        _orderNumberMeta,
        orderNumber.isAcceptableOrUnknown(
          data['order_number']!,
          _orderNumberMeta,
        ),
      );
    }
    if (data.containsKey('order_value_cents')) {
      context.handle(
        _orderValueCentsMeta,
        orderValueCents.isAcceptableOrUnknown(
          data['order_value_cents']!,
          _orderValueCentsMeta,
        ),
      );
    }
    if (data.containsKey('ocr_raw_text')) {
      context.handle(
        _ocrRawTextMeta,
        ocrRawText.isAcceptableOrUnknown(
          data['ocr_raw_text']!,
          _ocrRawTextMeta,
        ),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('needs_ifood_confirmation')) {
      context.handle(
        _needsIfoodConfirmationMeta,
        needsIfoodConfirmation.isAcceptableOrUnknown(
          data['needs_ifood_confirmation']!,
          _needsIfoodConfirmationMeta,
        ),
      );
    }
    if (data.containsKey('delivery_identifier')) {
      context.handle(
        _deliveryIdentifierMeta,
        deliveryIdentifier.isAcceptableOrUnknown(
          data['delivery_identifier']!,
          _deliveryIdentifierMeta,
        ),
      );
    }
    if (data.containsKey('partner_collection_code')) {
      context.handle(
        _partnerCollectionCodeMeta,
        partnerCollectionCode.isAcceptableOrUnknown(
          data['partner_collection_code']!,
          _partnerCollectionCodeMeta,
        ),
      );
    }
    if (data.containsKey('ifood_confirmation_success')) {
      context.handle(
        _ifoodConfirmationSuccessMeta,
        ifoodConfirmationSuccess.isAcceptableOrUnknown(
          data['ifood_confirmation_success']!,
          _ifoodConfirmationSuccessMeta,
        ),
      );
    }
    if (data.containsKey('ifood_confirmed_at')) {
      context.handle(
        _ifoodConfirmedAtMeta,
        ifoodConfirmedAt.isAcceptableOrUnknown(
          data['ifood_confirmed_at']!,
          _ifoodConfirmedAtMeta,
        ),
      );
    }
    if (data.containsKey('has_drinks')) {
      context.handle(
        _hasDrinksMeta,
        hasDrinks.isAcceptableOrUnknown(data['has_drinks']!, _hasDrinksMeta),
      );
    }
    if (data.containsKey('needs_card')) {
      context.handle(
        _needsCardMeta,
        needsCard.isAcceptableOrUnknown(data['needs_card']!, _needsCardMeta),
      );
    }
    if (data.containsKey('needs_change')) {
      context.handle(
        _needsChangeMeta,
        needsChange.isAcceptableOrUnknown(
          data['needs_change']!,
          _needsChangeMeta,
        ),
      );
    }
    if (data.containsKey('change_amount_cents')) {
      context.handle(
        _changeAmountCentsMeta,
        changeAmountCents.isAcceptableOrUnknown(
          data['change_amount_cents']!,
          _changeAmountCentsMeta,
        ),
      );
    }
    if (data.containsKey('pizza_number')) {
      context.handle(
        _pizzaNumberMeta,
        pizzaNumber.isAcceptableOrUnknown(
          data['pizza_number']!,
          _pizzaNumberMeta,
        ),
      );
    }
    if (data.containsKey('house_number')) {
      context.handle(
        _houseNumberMeta,
        houseNumber.isAcceptableOrUnknown(
          data['house_number']!,
          _houseNumberMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DeliveriesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeliveriesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      routeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}route_id'],
      )!,
      shiftId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}shift_id'],
      )!,
      sequenceNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sequence_number'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      customerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_name'],
      ),
      addressText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address_text'],
      )!,
      distanceKm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}distance_km'],
      ),
      orderNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}order_number'],
      ),
      orderValueCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_value_cents'],
      ),
      ocrRawText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ocr_raw_text'],
      ),
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}completed_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      needsIfoodConfirmation: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}needs_ifood_confirmation'],
      )!,
      deliveryIdentifier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}delivery_identifier'],
      ),
      partnerCollectionCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}partner_collection_code'],
      ),
      ifoodConfirmationSuccess: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}ifood_confirmation_success'],
      ),
      ifoodConfirmedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ifood_confirmed_at'],
      ),
      hasDrinks: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_drinks'],
      )!,
      needsCard: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}needs_card'],
      )!,
      needsChange: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}needs_change'],
      )!,
      changeAmountCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}change_amount_cents'],
      ),
      pizzaNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pizza_number'],
      ),
      houseNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}house_number'],
      ),
    );
  }

  @override
  $DeliveriesTableTable createAlias(String alias) {
    return $DeliveriesTableTable(attachedDatabase, alias);
  }
}

class DeliveriesTableData extends DataClass
    implements Insertable<DeliveriesTableData> {
  final int id;
  final int routeId;
  final int shiftId;
  final int sequenceNumber;
  final String status;
  final String? customerName;
  final String addressText;
  final double? distanceKm;
  final String? orderNumber;
  final int? orderValueCents;
  final String? ocrRawText;
  final String? completedAt;
  final String createdAt;
  final bool needsIfoodConfirmation;
  final String? deliveryIdentifier;
  final String? partnerCollectionCode;
  final bool? ifoodConfirmationSuccess;
  final String? ifoodConfirmedAt;
  final bool hasDrinks;
  final bool needsCard;
  final bool needsChange;
  final int? changeAmountCents;
  final String? pizzaNumber;
  final String? houseNumber;
  const DeliveriesTableData({
    required this.id,
    required this.routeId,
    required this.shiftId,
    required this.sequenceNumber,
    required this.status,
    this.customerName,
    required this.addressText,
    this.distanceKm,
    this.orderNumber,
    this.orderValueCents,
    this.ocrRawText,
    this.completedAt,
    required this.createdAt,
    required this.needsIfoodConfirmation,
    this.deliveryIdentifier,
    this.partnerCollectionCode,
    this.ifoodConfirmationSuccess,
    this.ifoodConfirmedAt,
    required this.hasDrinks,
    required this.needsCard,
    required this.needsChange,
    this.changeAmountCents,
    this.pizzaNumber,
    this.houseNumber,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['route_id'] = Variable<int>(routeId);
    map['shift_id'] = Variable<int>(shiftId);
    map['sequence_number'] = Variable<int>(sequenceNumber);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || customerName != null) {
      map['customer_name'] = Variable<String>(customerName);
    }
    map['address_text'] = Variable<String>(addressText);
    if (!nullToAbsent || distanceKm != null) {
      map['distance_km'] = Variable<double>(distanceKm);
    }
    if (!nullToAbsent || orderNumber != null) {
      map['order_number'] = Variable<String>(orderNumber);
    }
    if (!nullToAbsent || orderValueCents != null) {
      map['order_value_cents'] = Variable<int>(orderValueCents);
    }
    if (!nullToAbsent || ocrRawText != null) {
      map['ocr_raw_text'] = Variable<String>(ocrRawText);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<String>(completedAt);
    }
    map['created_at'] = Variable<String>(createdAt);
    map['needs_ifood_confirmation'] = Variable<bool>(needsIfoodConfirmation);
    if (!nullToAbsent || deliveryIdentifier != null) {
      map['delivery_identifier'] = Variable<String>(deliveryIdentifier);
    }
    if (!nullToAbsent || partnerCollectionCode != null) {
      map['partner_collection_code'] = Variable<String>(partnerCollectionCode);
    }
    if (!nullToAbsent || ifoodConfirmationSuccess != null) {
      map['ifood_confirmation_success'] = Variable<bool>(
        ifoodConfirmationSuccess,
      );
    }
    if (!nullToAbsent || ifoodConfirmedAt != null) {
      map['ifood_confirmed_at'] = Variable<String>(ifoodConfirmedAt);
    }
    map['has_drinks'] = Variable<bool>(hasDrinks);
    map['needs_card'] = Variable<bool>(needsCard);
    map['needs_change'] = Variable<bool>(needsChange);
    if (!nullToAbsent || changeAmountCents != null) {
      map['change_amount_cents'] = Variable<int>(changeAmountCents);
    }
    if (!nullToAbsent || pizzaNumber != null) {
      map['pizza_number'] = Variable<String>(pizzaNumber);
    }
    if (!nullToAbsent || houseNumber != null) {
      map['house_number'] = Variable<String>(houseNumber);
    }
    return map;
  }

  DeliveriesTableCompanion toCompanion(bool nullToAbsent) {
    return DeliveriesTableCompanion(
      id: Value(id),
      routeId: Value(routeId),
      shiftId: Value(shiftId),
      sequenceNumber: Value(sequenceNumber),
      status: Value(status),
      customerName: customerName == null && nullToAbsent
          ? const Value.absent()
          : Value(customerName),
      addressText: Value(addressText),
      distanceKm: distanceKm == null && nullToAbsent
          ? const Value.absent()
          : Value(distanceKm),
      orderNumber: orderNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(orderNumber),
      orderValueCents: orderValueCents == null && nullToAbsent
          ? const Value.absent()
          : Value(orderValueCents),
      ocrRawText: ocrRawText == null && nullToAbsent
          ? const Value.absent()
          : Value(ocrRawText),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      createdAt: Value(createdAt),
      needsIfoodConfirmation: Value(needsIfoodConfirmation),
      deliveryIdentifier: deliveryIdentifier == null && nullToAbsent
          ? const Value.absent()
          : Value(deliveryIdentifier),
      partnerCollectionCode: partnerCollectionCode == null && nullToAbsent
          ? const Value.absent()
          : Value(partnerCollectionCode),
      ifoodConfirmationSuccess: ifoodConfirmationSuccess == null && nullToAbsent
          ? const Value.absent()
          : Value(ifoodConfirmationSuccess),
      ifoodConfirmedAt: ifoodConfirmedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(ifoodConfirmedAt),
      hasDrinks: Value(hasDrinks),
      needsCard: Value(needsCard),
      needsChange: Value(needsChange),
      changeAmountCents: changeAmountCents == null && nullToAbsent
          ? const Value.absent()
          : Value(changeAmountCents),
      pizzaNumber: pizzaNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(pizzaNumber),
      houseNumber: houseNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(houseNumber),
    );
  }

  factory DeliveriesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeliveriesTableData(
      id: serializer.fromJson<int>(json['id']),
      routeId: serializer.fromJson<int>(json['routeId']),
      shiftId: serializer.fromJson<int>(json['shiftId']),
      sequenceNumber: serializer.fromJson<int>(json['sequenceNumber']),
      status: serializer.fromJson<String>(json['status']),
      customerName: serializer.fromJson<String?>(json['customerName']),
      addressText: serializer.fromJson<String>(json['addressText']),
      distanceKm: serializer.fromJson<double?>(json['distanceKm']),
      orderNumber: serializer.fromJson<String?>(json['orderNumber']),
      orderValueCents: serializer.fromJson<int?>(json['orderValueCents']),
      ocrRawText: serializer.fromJson<String?>(json['ocrRawText']),
      completedAt: serializer.fromJson<String?>(json['completedAt']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      needsIfoodConfirmation: serializer.fromJson<bool>(
        json['needsIfoodConfirmation'],
      ),
      deliveryIdentifier: serializer.fromJson<String?>(
        json['deliveryIdentifier'],
      ),
      partnerCollectionCode: serializer.fromJson<String?>(
        json['partnerCollectionCode'],
      ),
      ifoodConfirmationSuccess: serializer.fromJson<bool?>(
        json['ifoodConfirmationSuccess'],
      ),
      ifoodConfirmedAt: serializer.fromJson<String?>(json['ifoodConfirmedAt']),
      hasDrinks: serializer.fromJson<bool>(json['hasDrinks']),
      needsCard: serializer.fromJson<bool>(json['needsCard']),
      needsChange: serializer.fromJson<bool>(json['needsChange']),
      changeAmountCents: serializer.fromJson<int?>(json['changeAmountCents']),
      pizzaNumber: serializer.fromJson<String?>(json['pizzaNumber']),
      houseNumber: serializer.fromJson<String?>(json['houseNumber']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'routeId': serializer.toJson<int>(routeId),
      'shiftId': serializer.toJson<int>(shiftId),
      'sequenceNumber': serializer.toJson<int>(sequenceNumber),
      'status': serializer.toJson<String>(status),
      'customerName': serializer.toJson<String?>(customerName),
      'addressText': serializer.toJson<String>(addressText),
      'distanceKm': serializer.toJson<double?>(distanceKm),
      'orderNumber': serializer.toJson<String?>(orderNumber),
      'orderValueCents': serializer.toJson<int?>(orderValueCents),
      'ocrRawText': serializer.toJson<String?>(ocrRawText),
      'completedAt': serializer.toJson<String?>(completedAt),
      'createdAt': serializer.toJson<String>(createdAt),
      'needsIfoodConfirmation': serializer.toJson<bool>(needsIfoodConfirmation),
      'deliveryIdentifier': serializer.toJson<String?>(deliveryIdentifier),
      'partnerCollectionCode': serializer.toJson<String?>(
        partnerCollectionCode,
      ),
      'ifoodConfirmationSuccess': serializer.toJson<bool?>(
        ifoodConfirmationSuccess,
      ),
      'ifoodConfirmedAt': serializer.toJson<String?>(ifoodConfirmedAt),
      'hasDrinks': serializer.toJson<bool>(hasDrinks),
      'needsCard': serializer.toJson<bool>(needsCard),
      'needsChange': serializer.toJson<bool>(needsChange),
      'changeAmountCents': serializer.toJson<int?>(changeAmountCents),
      'pizzaNumber': serializer.toJson<String?>(pizzaNumber),
      'houseNumber': serializer.toJson<String?>(houseNumber),
    };
  }

  DeliveriesTableData copyWith({
    int? id,
    int? routeId,
    int? shiftId,
    int? sequenceNumber,
    String? status,
    Value<String?> customerName = const Value.absent(),
    String? addressText,
    Value<double?> distanceKm = const Value.absent(),
    Value<String?> orderNumber = const Value.absent(),
    Value<int?> orderValueCents = const Value.absent(),
    Value<String?> ocrRawText = const Value.absent(),
    Value<String?> completedAt = const Value.absent(),
    String? createdAt,
    bool? needsIfoodConfirmation,
    Value<String?> deliveryIdentifier = const Value.absent(),
    Value<String?> partnerCollectionCode = const Value.absent(),
    Value<bool?> ifoodConfirmationSuccess = const Value.absent(),
    Value<String?> ifoodConfirmedAt = const Value.absent(),
    bool? hasDrinks,
    bool? needsCard,
    bool? needsChange,
    Value<int?> changeAmountCents = const Value.absent(),
    Value<String?> pizzaNumber = const Value.absent(),
    Value<String?> houseNumber = const Value.absent(),
  }) => DeliveriesTableData(
    id: id ?? this.id,
    routeId: routeId ?? this.routeId,
    shiftId: shiftId ?? this.shiftId,
    sequenceNumber: sequenceNumber ?? this.sequenceNumber,
    status: status ?? this.status,
    customerName: customerName.present ? customerName.value : this.customerName,
    addressText: addressText ?? this.addressText,
    distanceKm: distanceKm.present ? distanceKm.value : this.distanceKm,
    orderNumber: orderNumber.present ? orderNumber.value : this.orderNumber,
    orderValueCents: orderValueCents.present
        ? orderValueCents.value
        : this.orderValueCents,
    ocrRawText: ocrRawText.present ? ocrRawText.value : this.ocrRawText,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    createdAt: createdAt ?? this.createdAt,
    needsIfoodConfirmation:
        needsIfoodConfirmation ?? this.needsIfoodConfirmation,
    deliveryIdentifier: deliveryIdentifier.present
        ? deliveryIdentifier.value
        : this.deliveryIdentifier,
    partnerCollectionCode: partnerCollectionCode.present
        ? partnerCollectionCode.value
        : this.partnerCollectionCode,
    ifoodConfirmationSuccess: ifoodConfirmationSuccess.present
        ? ifoodConfirmationSuccess.value
        : this.ifoodConfirmationSuccess,
    ifoodConfirmedAt: ifoodConfirmedAt.present
        ? ifoodConfirmedAt.value
        : this.ifoodConfirmedAt,
    hasDrinks: hasDrinks ?? this.hasDrinks,
    needsCard: needsCard ?? this.needsCard,
    needsChange: needsChange ?? this.needsChange,
    changeAmountCents: changeAmountCents.present
        ? changeAmountCents.value
        : this.changeAmountCents,
    pizzaNumber: pizzaNumber.present ? pizzaNumber.value : this.pizzaNumber,
    houseNumber: houseNumber.present ? houseNumber.value : this.houseNumber,
  );
  DeliveriesTableData copyWithCompanion(DeliveriesTableCompanion data) {
    return DeliveriesTableData(
      id: data.id.present ? data.id.value : this.id,
      routeId: data.routeId.present ? data.routeId.value : this.routeId,
      shiftId: data.shiftId.present ? data.shiftId.value : this.shiftId,
      sequenceNumber: data.sequenceNumber.present
          ? data.sequenceNumber.value
          : this.sequenceNumber,
      status: data.status.present ? data.status.value : this.status,
      customerName: data.customerName.present
          ? data.customerName.value
          : this.customerName,
      addressText: data.addressText.present
          ? data.addressText.value
          : this.addressText,
      distanceKm: data.distanceKm.present
          ? data.distanceKm.value
          : this.distanceKm,
      orderNumber: data.orderNumber.present
          ? data.orderNumber.value
          : this.orderNumber,
      orderValueCents: data.orderValueCents.present
          ? data.orderValueCents.value
          : this.orderValueCents,
      ocrRawText: data.ocrRawText.present
          ? data.ocrRawText.value
          : this.ocrRawText,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      needsIfoodConfirmation: data.needsIfoodConfirmation.present
          ? data.needsIfoodConfirmation.value
          : this.needsIfoodConfirmation,
      deliveryIdentifier: data.deliveryIdentifier.present
          ? data.deliveryIdentifier.value
          : this.deliveryIdentifier,
      partnerCollectionCode: data.partnerCollectionCode.present
          ? data.partnerCollectionCode.value
          : this.partnerCollectionCode,
      ifoodConfirmationSuccess: data.ifoodConfirmationSuccess.present
          ? data.ifoodConfirmationSuccess.value
          : this.ifoodConfirmationSuccess,
      ifoodConfirmedAt: data.ifoodConfirmedAt.present
          ? data.ifoodConfirmedAt.value
          : this.ifoodConfirmedAt,
      hasDrinks: data.hasDrinks.present ? data.hasDrinks.value : this.hasDrinks,
      needsCard: data.needsCard.present ? data.needsCard.value : this.needsCard,
      needsChange: data.needsChange.present
          ? data.needsChange.value
          : this.needsChange,
      changeAmountCents: data.changeAmountCents.present
          ? data.changeAmountCents.value
          : this.changeAmountCents,
      pizzaNumber: data.pizzaNumber.present
          ? data.pizzaNumber.value
          : this.pizzaNumber,
      houseNumber: data.houseNumber.present
          ? data.houseNumber.value
          : this.houseNumber,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeliveriesTableData(')
          ..write('id: $id, ')
          ..write('routeId: $routeId, ')
          ..write('shiftId: $shiftId, ')
          ..write('sequenceNumber: $sequenceNumber, ')
          ..write('status: $status, ')
          ..write('customerName: $customerName, ')
          ..write('addressText: $addressText, ')
          ..write('distanceKm: $distanceKm, ')
          ..write('orderNumber: $orderNumber, ')
          ..write('orderValueCents: $orderValueCents, ')
          ..write('ocrRawText: $ocrRawText, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('needsIfoodConfirmation: $needsIfoodConfirmation, ')
          ..write('deliveryIdentifier: $deliveryIdentifier, ')
          ..write('partnerCollectionCode: $partnerCollectionCode, ')
          ..write('ifoodConfirmationSuccess: $ifoodConfirmationSuccess, ')
          ..write('ifoodConfirmedAt: $ifoodConfirmedAt, ')
          ..write('hasDrinks: $hasDrinks, ')
          ..write('needsCard: $needsCard, ')
          ..write('needsChange: $needsChange, ')
          ..write('changeAmountCents: $changeAmountCents, ')
          ..write('pizzaNumber: $pizzaNumber, ')
          ..write('houseNumber: $houseNumber')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    routeId,
    shiftId,
    sequenceNumber,
    status,
    customerName,
    addressText,
    distanceKm,
    orderNumber,
    orderValueCents,
    ocrRawText,
    completedAt,
    createdAt,
    needsIfoodConfirmation,
    deliveryIdentifier,
    partnerCollectionCode,
    ifoodConfirmationSuccess,
    ifoodConfirmedAt,
    hasDrinks,
    needsCard,
    needsChange,
    changeAmountCents,
    pizzaNumber,
    houseNumber,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeliveriesTableData &&
          other.id == this.id &&
          other.routeId == this.routeId &&
          other.shiftId == this.shiftId &&
          other.sequenceNumber == this.sequenceNumber &&
          other.status == this.status &&
          other.customerName == this.customerName &&
          other.addressText == this.addressText &&
          other.distanceKm == this.distanceKm &&
          other.orderNumber == this.orderNumber &&
          other.orderValueCents == this.orderValueCents &&
          other.ocrRawText == this.ocrRawText &&
          other.completedAt == this.completedAt &&
          other.createdAt == this.createdAt &&
          other.needsIfoodConfirmation == this.needsIfoodConfirmation &&
          other.deliveryIdentifier == this.deliveryIdentifier &&
          other.partnerCollectionCode == this.partnerCollectionCode &&
          other.ifoodConfirmationSuccess == this.ifoodConfirmationSuccess &&
          other.ifoodConfirmedAt == this.ifoodConfirmedAt &&
          other.hasDrinks == this.hasDrinks &&
          other.needsCard == this.needsCard &&
          other.needsChange == this.needsChange &&
          other.changeAmountCents == this.changeAmountCents &&
          other.pizzaNumber == this.pizzaNumber &&
          other.houseNumber == this.houseNumber);
}

class DeliveriesTableCompanion extends UpdateCompanion<DeliveriesTableData> {
  final Value<int> id;
  final Value<int> routeId;
  final Value<int> shiftId;
  final Value<int> sequenceNumber;
  final Value<String> status;
  final Value<String?> customerName;
  final Value<String> addressText;
  final Value<double?> distanceKm;
  final Value<String?> orderNumber;
  final Value<int?> orderValueCents;
  final Value<String?> ocrRawText;
  final Value<String?> completedAt;
  final Value<String> createdAt;
  final Value<bool> needsIfoodConfirmation;
  final Value<String?> deliveryIdentifier;
  final Value<String?> partnerCollectionCode;
  final Value<bool?> ifoodConfirmationSuccess;
  final Value<String?> ifoodConfirmedAt;
  final Value<bool> hasDrinks;
  final Value<bool> needsCard;
  final Value<bool> needsChange;
  final Value<int?> changeAmountCents;
  final Value<String?> pizzaNumber;
  final Value<String?> houseNumber;
  const DeliveriesTableCompanion({
    this.id = const Value.absent(),
    this.routeId = const Value.absent(),
    this.shiftId = const Value.absent(),
    this.sequenceNumber = const Value.absent(),
    this.status = const Value.absent(),
    this.customerName = const Value.absent(),
    this.addressText = const Value.absent(),
    this.distanceKm = const Value.absent(),
    this.orderNumber = const Value.absent(),
    this.orderValueCents = const Value.absent(),
    this.ocrRawText = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.needsIfoodConfirmation = const Value.absent(),
    this.deliveryIdentifier = const Value.absent(),
    this.partnerCollectionCode = const Value.absent(),
    this.ifoodConfirmationSuccess = const Value.absent(),
    this.ifoodConfirmedAt = const Value.absent(),
    this.hasDrinks = const Value.absent(),
    this.needsCard = const Value.absent(),
    this.needsChange = const Value.absent(),
    this.changeAmountCents = const Value.absent(),
    this.pizzaNumber = const Value.absent(),
    this.houseNumber = const Value.absent(),
  });
  DeliveriesTableCompanion.insert({
    this.id = const Value.absent(),
    required int routeId,
    required int shiftId,
    this.sequenceNumber = const Value.absent(),
    this.status = const Value.absent(),
    this.customerName = const Value.absent(),
    required String addressText,
    this.distanceKm = const Value.absent(),
    this.orderNumber = const Value.absent(),
    this.orderValueCents = const Value.absent(),
    this.ocrRawText = const Value.absent(),
    this.completedAt = const Value.absent(),
    required String createdAt,
    this.needsIfoodConfirmation = const Value.absent(),
    this.deliveryIdentifier = const Value.absent(),
    this.partnerCollectionCode = const Value.absent(),
    this.ifoodConfirmationSuccess = const Value.absent(),
    this.ifoodConfirmedAt = const Value.absent(),
    this.hasDrinks = const Value.absent(),
    this.needsCard = const Value.absent(),
    this.needsChange = const Value.absent(),
    this.changeAmountCents = const Value.absent(),
    this.pizzaNumber = const Value.absent(),
    this.houseNumber = const Value.absent(),
  }) : routeId = Value(routeId),
       shiftId = Value(shiftId),
       addressText = Value(addressText),
       createdAt = Value(createdAt);
  static Insertable<DeliveriesTableData> custom({
    Expression<int>? id,
    Expression<int>? routeId,
    Expression<int>? shiftId,
    Expression<int>? sequenceNumber,
    Expression<String>? status,
    Expression<String>? customerName,
    Expression<String>? addressText,
    Expression<double>? distanceKm,
    Expression<String>? orderNumber,
    Expression<int>? orderValueCents,
    Expression<String>? ocrRawText,
    Expression<String>? completedAt,
    Expression<String>? createdAt,
    Expression<bool>? needsIfoodConfirmation,
    Expression<String>? deliveryIdentifier,
    Expression<String>? partnerCollectionCode,
    Expression<bool>? ifoodConfirmationSuccess,
    Expression<String>? ifoodConfirmedAt,
    Expression<bool>? hasDrinks,
    Expression<bool>? needsCard,
    Expression<bool>? needsChange,
    Expression<int>? changeAmountCents,
    Expression<String>? pizzaNumber,
    Expression<String>? houseNumber,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (routeId != null) 'route_id': routeId,
      if (shiftId != null) 'shift_id': shiftId,
      if (sequenceNumber != null) 'sequence_number': sequenceNumber,
      if (status != null) 'status': status,
      if (customerName != null) 'customer_name': customerName,
      if (addressText != null) 'address_text': addressText,
      if (distanceKm != null) 'distance_km': distanceKm,
      if (orderNumber != null) 'order_number': orderNumber,
      if (orderValueCents != null) 'order_value_cents': orderValueCents,
      if (ocrRawText != null) 'ocr_raw_text': ocrRawText,
      if (completedAt != null) 'completed_at': completedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (needsIfoodConfirmation != null)
        'needs_ifood_confirmation': needsIfoodConfirmation,
      if (deliveryIdentifier != null) 'delivery_identifier': deliveryIdentifier,
      if (partnerCollectionCode != null)
        'partner_collection_code': partnerCollectionCode,
      if (ifoodConfirmationSuccess != null)
        'ifood_confirmation_success': ifoodConfirmationSuccess,
      if (ifoodConfirmedAt != null) 'ifood_confirmed_at': ifoodConfirmedAt,
      if (hasDrinks != null) 'has_drinks': hasDrinks,
      if (needsCard != null) 'needs_card': needsCard,
      if (needsChange != null) 'needs_change': needsChange,
      if (changeAmountCents != null) 'change_amount_cents': changeAmountCents,
      if (pizzaNumber != null) 'pizza_number': pizzaNumber,
      if (houseNumber != null) 'house_number': houseNumber,
    });
  }

  DeliveriesTableCompanion copyWith({
    Value<int>? id,
    Value<int>? routeId,
    Value<int>? shiftId,
    Value<int>? sequenceNumber,
    Value<String>? status,
    Value<String?>? customerName,
    Value<String>? addressText,
    Value<double?>? distanceKm,
    Value<String?>? orderNumber,
    Value<int?>? orderValueCents,
    Value<String?>? ocrRawText,
    Value<String?>? completedAt,
    Value<String>? createdAt,
    Value<bool>? needsIfoodConfirmation,
    Value<String?>? deliveryIdentifier,
    Value<String?>? partnerCollectionCode,
    Value<bool?>? ifoodConfirmationSuccess,
    Value<String?>? ifoodConfirmedAt,
    Value<bool>? hasDrinks,
    Value<bool>? needsCard,
    Value<bool>? needsChange,
    Value<int?>? changeAmountCents,
    Value<String?>? pizzaNumber,
    Value<String?>? houseNumber,
  }) {
    return DeliveriesTableCompanion(
      id: id ?? this.id,
      routeId: routeId ?? this.routeId,
      shiftId: shiftId ?? this.shiftId,
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
      status: status ?? this.status,
      customerName: customerName ?? this.customerName,
      addressText: addressText ?? this.addressText,
      distanceKm: distanceKm ?? this.distanceKm,
      orderNumber: orderNumber ?? this.orderNumber,
      orderValueCents: orderValueCents ?? this.orderValueCents,
      ocrRawText: ocrRawText ?? this.ocrRawText,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      needsIfoodConfirmation:
          needsIfoodConfirmation ?? this.needsIfoodConfirmation,
      deliveryIdentifier: deliveryIdentifier ?? this.deliveryIdentifier,
      partnerCollectionCode:
          partnerCollectionCode ?? this.partnerCollectionCode,
      ifoodConfirmationSuccess:
          ifoodConfirmationSuccess ?? this.ifoodConfirmationSuccess,
      ifoodConfirmedAt: ifoodConfirmedAt ?? this.ifoodConfirmedAt,
      hasDrinks: hasDrinks ?? this.hasDrinks,
      needsCard: needsCard ?? this.needsCard,
      needsChange: needsChange ?? this.needsChange,
      changeAmountCents: changeAmountCents ?? this.changeAmountCents,
      pizzaNumber: pizzaNumber ?? this.pizzaNumber,
      houseNumber: houseNumber ?? this.houseNumber,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (routeId.present) {
      map['route_id'] = Variable<int>(routeId.value);
    }
    if (shiftId.present) {
      map['shift_id'] = Variable<int>(shiftId.value);
    }
    if (sequenceNumber.present) {
      map['sequence_number'] = Variable<int>(sequenceNumber.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (customerName.present) {
      map['customer_name'] = Variable<String>(customerName.value);
    }
    if (addressText.present) {
      map['address_text'] = Variable<String>(addressText.value);
    }
    if (distanceKm.present) {
      map['distance_km'] = Variable<double>(distanceKm.value);
    }
    if (orderNumber.present) {
      map['order_number'] = Variable<String>(orderNumber.value);
    }
    if (orderValueCents.present) {
      map['order_value_cents'] = Variable<int>(orderValueCents.value);
    }
    if (ocrRawText.present) {
      map['ocr_raw_text'] = Variable<String>(ocrRawText.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<String>(completedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (needsIfoodConfirmation.present) {
      map['needs_ifood_confirmation'] = Variable<bool>(
        needsIfoodConfirmation.value,
      );
    }
    if (deliveryIdentifier.present) {
      map['delivery_identifier'] = Variable<String>(deliveryIdentifier.value);
    }
    if (partnerCollectionCode.present) {
      map['partner_collection_code'] = Variable<String>(
        partnerCollectionCode.value,
      );
    }
    if (ifoodConfirmationSuccess.present) {
      map['ifood_confirmation_success'] = Variable<bool>(
        ifoodConfirmationSuccess.value,
      );
    }
    if (ifoodConfirmedAt.present) {
      map['ifood_confirmed_at'] = Variable<String>(ifoodConfirmedAt.value);
    }
    if (hasDrinks.present) {
      map['has_drinks'] = Variable<bool>(hasDrinks.value);
    }
    if (needsCard.present) {
      map['needs_card'] = Variable<bool>(needsCard.value);
    }
    if (needsChange.present) {
      map['needs_change'] = Variable<bool>(needsChange.value);
    }
    if (changeAmountCents.present) {
      map['change_amount_cents'] = Variable<int>(changeAmountCents.value);
    }
    if (pizzaNumber.present) {
      map['pizza_number'] = Variable<String>(pizzaNumber.value);
    }
    if (houseNumber.present) {
      map['house_number'] = Variable<String>(houseNumber.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DeliveriesTableCompanion(')
          ..write('id: $id, ')
          ..write('routeId: $routeId, ')
          ..write('shiftId: $shiftId, ')
          ..write('sequenceNumber: $sequenceNumber, ')
          ..write('status: $status, ')
          ..write('customerName: $customerName, ')
          ..write('addressText: $addressText, ')
          ..write('distanceKm: $distanceKm, ')
          ..write('orderNumber: $orderNumber, ')
          ..write('orderValueCents: $orderValueCents, ')
          ..write('ocrRawText: $ocrRawText, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('needsIfoodConfirmation: $needsIfoodConfirmation, ')
          ..write('deliveryIdentifier: $deliveryIdentifier, ')
          ..write('partnerCollectionCode: $partnerCollectionCode, ')
          ..write('ifoodConfirmationSuccess: $ifoodConfirmationSuccess, ')
          ..write('ifoodConfirmedAt: $ifoodConfirmedAt, ')
          ..write('hasDrinks: $hasDrinks, ')
          ..write('needsCard: $needsCard, ')
          ..write('needsChange: $needsChange, ')
          ..write('changeAmountCents: $changeAmountCents, ')
          ..write('pizzaNumber: $pizzaNumber, ')
          ..write('houseNumber: $houseNumber')
          ..write(')'))
        .toString();
  }
}

class $ReceiptsTableTable extends ReceiptsTable
    with TableInfo<$ReceiptsTableTable, ReceiptsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReceiptsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _deliveryIdMeta = const VerificationMeta(
    'deliveryId',
  );
  @override
  late final GeneratedColumn<int> deliveryId = GeneratedColumn<int>(
    'delivery_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES deliveries (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _imagePathMeta = const VerificationMeta(
    'imagePath',
  );
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
    'image_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ocrRawTextMeta = const VerificationMeta(
    'ocrRawText',
  );
  @override
  late final GeneratedColumn<String> ocrRawText = GeneratedColumn<String>(
    'ocr_raw_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ocrConfidenceJsonMeta = const VerificationMeta(
    'ocrConfidenceJson',
  );
  @override
  late final GeneratedColumn<String> ocrConfidenceJson =
      GeneratedColumn<String>(
        'ocr_confidence_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _captureAttemptedAtMeta =
      const VerificationMeta('captureAttemptedAt');
  @override
  late final GeneratedColumn<String> captureAttemptedAt =
      GeneratedColumn<String>(
        'capture_attempted_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _wasRetakenMeta = const VerificationMeta(
    'wasRetaken',
  );
  @override
  late final GeneratedColumn<bool> wasRetaken = GeneratedColumn<bool>(
    'was_retaken',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("was_retaken" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deliveryId,
    imagePath,
    ocrRawText,
    ocrConfidenceJson,
    captureAttemptedAt,
    wasRetaken,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'receipts';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReceiptsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('delivery_id')) {
      context.handle(
        _deliveryIdMeta,
        deliveryId.isAcceptableOrUnknown(data['delivery_id']!, _deliveryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deliveryIdMeta);
    }
    if (data.containsKey('image_path')) {
      context.handle(
        _imagePathMeta,
        imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta),
      );
    } else if (isInserting) {
      context.missing(_imagePathMeta);
    }
    if (data.containsKey('ocr_raw_text')) {
      context.handle(
        _ocrRawTextMeta,
        ocrRawText.isAcceptableOrUnknown(
          data['ocr_raw_text']!,
          _ocrRawTextMeta,
        ),
      );
    }
    if (data.containsKey('ocr_confidence_json')) {
      context.handle(
        _ocrConfidenceJsonMeta,
        ocrConfidenceJson.isAcceptableOrUnknown(
          data['ocr_confidence_json']!,
          _ocrConfidenceJsonMeta,
        ),
      );
    }
    if (data.containsKey('capture_attempted_at')) {
      context.handle(
        _captureAttemptedAtMeta,
        captureAttemptedAt.isAcceptableOrUnknown(
          data['capture_attempted_at']!,
          _captureAttemptedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_captureAttemptedAtMeta);
    }
    if (data.containsKey('was_retaken')) {
      context.handle(
        _wasRetakenMeta,
        wasRetaken.isAcceptableOrUnknown(data['was_retaken']!, _wasRetakenMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReceiptsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReceiptsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      deliveryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}delivery_id'],
      )!,
      imagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_path'],
      )!,
      ocrRawText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ocr_raw_text'],
      ),
      ocrConfidenceJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ocr_confidence_json'],
      ),
      captureAttemptedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}capture_attempted_at'],
      )!,
      wasRetaken: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}was_retaken'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ReceiptsTableTable createAlias(String alias) {
    return $ReceiptsTableTable(attachedDatabase, alias);
  }
}

class ReceiptsTableData extends DataClass
    implements Insertable<ReceiptsTableData> {
  final int id;
  final int deliveryId;
  final String imagePath;
  final String? ocrRawText;
  final String? ocrConfidenceJson;
  final String captureAttemptedAt;
  final bool wasRetaken;
  final String createdAt;
  const ReceiptsTableData({
    required this.id,
    required this.deliveryId,
    required this.imagePath,
    this.ocrRawText,
    this.ocrConfidenceJson,
    required this.captureAttemptedAt,
    required this.wasRetaken,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['delivery_id'] = Variable<int>(deliveryId);
    map['image_path'] = Variable<String>(imagePath);
    if (!nullToAbsent || ocrRawText != null) {
      map['ocr_raw_text'] = Variable<String>(ocrRawText);
    }
    if (!nullToAbsent || ocrConfidenceJson != null) {
      map['ocr_confidence_json'] = Variable<String>(ocrConfidenceJson);
    }
    map['capture_attempted_at'] = Variable<String>(captureAttemptedAt);
    map['was_retaken'] = Variable<bool>(wasRetaken);
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  ReceiptsTableCompanion toCompanion(bool nullToAbsent) {
    return ReceiptsTableCompanion(
      id: Value(id),
      deliveryId: Value(deliveryId),
      imagePath: Value(imagePath),
      ocrRawText: ocrRawText == null && nullToAbsent
          ? const Value.absent()
          : Value(ocrRawText),
      ocrConfidenceJson: ocrConfidenceJson == null && nullToAbsent
          ? const Value.absent()
          : Value(ocrConfidenceJson),
      captureAttemptedAt: Value(captureAttemptedAt),
      wasRetaken: Value(wasRetaken),
      createdAt: Value(createdAt),
    );
  }

  factory ReceiptsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReceiptsTableData(
      id: serializer.fromJson<int>(json['id']),
      deliveryId: serializer.fromJson<int>(json['deliveryId']),
      imagePath: serializer.fromJson<String>(json['imagePath']),
      ocrRawText: serializer.fromJson<String?>(json['ocrRawText']),
      ocrConfidenceJson: serializer.fromJson<String?>(
        json['ocrConfidenceJson'],
      ),
      captureAttemptedAt: serializer.fromJson<String>(
        json['captureAttemptedAt'],
      ),
      wasRetaken: serializer.fromJson<bool>(json['wasRetaken']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'deliveryId': serializer.toJson<int>(deliveryId),
      'imagePath': serializer.toJson<String>(imagePath),
      'ocrRawText': serializer.toJson<String?>(ocrRawText),
      'ocrConfidenceJson': serializer.toJson<String?>(ocrConfidenceJson),
      'captureAttemptedAt': serializer.toJson<String>(captureAttemptedAt),
      'wasRetaken': serializer.toJson<bool>(wasRetaken),
      'createdAt': serializer.toJson<String>(createdAt),
    };
  }

  ReceiptsTableData copyWith({
    int? id,
    int? deliveryId,
    String? imagePath,
    Value<String?> ocrRawText = const Value.absent(),
    Value<String?> ocrConfidenceJson = const Value.absent(),
    String? captureAttemptedAt,
    bool? wasRetaken,
    String? createdAt,
  }) => ReceiptsTableData(
    id: id ?? this.id,
    deliveryId: deliveryId ?? this.deliveryId,
    imagePath: imagePath ?? this.imagePath,
    ocrRawText: ocrRawText.present ? ocrRawText.value : this.ocrRawText,
    ocrConfidenceJson: ocrConfidenceJson.present
        ? ocrConfidenceJson.value
        : this.ocrConfidenceJson,
    captureAttemptedAt: captureAttemptedAt ?? this.captureAttemptedAt,
    wasRetaken: wasRetaken ?? this.wasRetaken,
    createdAt: createdAt ?? this.createdAt,
  );
  ReceiptsTableData copyWithCompanion(ReceiptsTableCompanion data) {
    return ReceiptsTableData(
      id: data.id.present ? data.id.value : this.id,
      deliveryId: data.deliveryId.present
          ? data.deliveryId.value
          : this.deliveryId,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      ocrRawText: data.ocrRawText.present
          ? data.ocrRawText.value
          : this.ocrRawText,
      ocrConfidenceJson: data.ocrConfidenceJson.present
          ? data.ocrConfidenceJson.value
          : this.ocrConfidenceJson,
      captureAttemptedAt: data.captureAttemptedAt.present
          ? data.captureAttemptedAt.value
          : this.captureAttemptedAt,
      wasRetaken: data.wasRetaken.present
          ? data.wasRetaken.value
          : this.wasRetaken,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReceiptsTableData(')
          ..write('id: $id, ')
          ..write('deliveryId: $deliveryId, ')
          ..write('imagePath: $imagePath, ')
          ..write('ocrRawText: $ocrRawText, ')
          ..write('ocrConfidenceJson: $ocrConfidenceJson, ')
          ..write('captureAttemptedAt: $captureAttemptedAt, ')
          ..write('wasRetaken: $wasRetaken, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    deliveryId,
    imagePath,
    ocrRawText,
    ocrConfidenceJson,
    captureAttemptedAt,
    wasRetaken,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReceiptsTableData &&
          other.id == this.id &&
          other.deliveryId == this.deliveryId &&
          other.imagePath == this.imagePath &&
          other.ocrRawText == this.ocrRawText &&
          other.ocrConfidenceJson == this.ocrConfidenceJson &&
          other.captureAttemptedAt == this.captureAttemptedAt &&
          other.wasRetaken == this.wasRetaken &&
          other.createdAt == this.createdAt);
}

class ReceiptsTableCompanion extends UpdateCompanion<ReceiptsTableData> {
  final Value<int> id;
  final Value<int> deliveryId;
  final Value<String> imagePath;
  final Value<String?> ocrRawText;
  final Value<String?> ocrConfidenceJson;
  final Value<String> captureAttemptedAt;
  final Value<bool> wasRetaken;
  final Value<String> createdAt;
  const ReceiptsTableCompanion({
    this.id = const Value.absent(),
    this.deliveryId = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.ocrRawText = const Value.absent(),
    this.ocrConfidenceJson = const Value.absent(),
    this.captureAttemptedAt = const Value.absent(),
    this.wasRetaken = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ReceiptsTableCompanion.insert({
    this.id = const Value.absent(),
    required int deliveryId,
    required String imagePath,
    this.ocrRawText = const Value.absent(),
    this.ocrConfidenceJson = const Value.absent(),
    required String captureAttemptedAt,
    this.wasRetaken = const Value.absent(),
    required String createdAt,
  }) : deliveryId = Value(deliveryId),
       imagePath = Value(imagePath),
       captureAttemptedAt = Value(captureAttemptedAt),
       createdAt = Value(createdAt);
  static Insertable<ReceiptsTableData> custom({
    Expression<int>? id,
    Expression<int>? deliveryId,
    Expression<String>? imagePath,
    Expression<String>? ocrRawText,
    Expression<String>? ocrConfidenceJson,
    Expression<String>? captureAttemptedAt,
    Expression<bool>? wasRetaken,
    Expression<String>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deliveryId != null) 'delivery_id': deliveryId,
      if (imagePath != null) 'image_path': imagePath,
      if (ocrRawText != null) 'ocr_raw_text': ocrRawText,
      if (ocrConfidenceJson != null) 'ocr_confidence_json': ocrConfidenceJson,
      if (captureAttemptedAt != null)
        'capture_attempted_at': captureAttemptedAt,
      if (wasRetaken != null) 'was_retaken': wasRetaken,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ReceiptsTableCompanion copyWith({
    Value<int>? id,
    Value<int>? deliveryId,
    Value<String>? imagePath,
    Value<String?>? ocrRawText,
    Value<String?>? ocrConfidenceJson,
    Value<String>? captureAttemptedAt,
    Value<bool>? wasRetaken,
    Value<String>? createdAt,
  }) {
    return ReceiptsTableCompanion(
      id: id ?? this.id,
      deliveryId: deliveryId ?? this.deliveryId,
      imagePath: imagePath ?? this.imagePath,
      ocrRawText: ocrRawText ?? this.ocrRawText,
      ocrConfidenceJson: ocrConfidenceJson ?? this.ocrConfidenceJson,
      captureAttemptedAt: captureAttemptedAt ?? this.captureAttemptedAt,
      wasRetaken: wasRetaken ?? this.wasRetaken,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (deliveryId.present) {
      map['delivery_id'] = Variable<int>(deliveryId.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (ocrRawText.present) {
      map['ocr_raw_text'] = Variable<String>(ocrRawText.value);
    }
    if (ocrConfidenceJson.present) {
      map['ocr_confidence_json'] = Variable<String>(ocrConfidenceJson.value);
    }
    if (captureAttemptedAt.present) {
      map['capture_attempted_at'] = Variable<String>(captureAttemptedAt.value);
    }
    if (wasRetaken.present) {
      map['was_retaken'] = Variable<bool>(wasRetaken.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReceiptsTableCompanion(')
          ..write('id: $id, ')
          ..write('deliveryId: $deliveryId, ')
          ..write('imagePath: $imagePath, ')
          ..write('ocrRawText: $ocrRawText, ')
          ..write('ocrConfidenceJson: $ocrConfidenceJson, ')
          ..write('captureAttemptedAt: $captureAttemptedAt, ')
          ..write('wasRetaken: $wasRetaken, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $EarningsEntriesTableTable extends EarningsEntriesTable
    with TableInfo<$EarningsEntriesTableTable, EarningsEntriesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EarningsEntriesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _routeIdMeta = const VerificationMeta(
    'routeId',
  );
  @override
  late final GeneratedColumn<int> routeId = GeneratedColumn<int>(
    'route_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES routes (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _shiftIdMeta = const VerificationMeta(
    'shiftId',
  );
  @override
  late final GeneratedColumn<int> shiftId = GeneratedColumn<int>(
    'shift_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES shifts (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _earningsTypeMeta = const VerificationMeta(
    'earningsType',
  );
  @override
  late final GeneratedColumn<String> earningsType = GeneratedColumn<String>(
    'earnings_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rateAppliedCentsMeta = const VerificationMeta(
    'rateAppliedCents',
  );
  @override
  late final GeneratedColumn<int> rateAppliedCents = GeneratedColumn<int>(
    'rate_applied_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _routeDeliveryCountMeta =
      const VerificationMeta('routeDeliveryCount');
  @override
  late final GeneratedColumn<int> routeDeliveryCount = GeneratedColumn<int>(
    'route_delivery_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _routeDistanceKmMeta = const VerificationMeta(
    'routeDistanceKm',
  );
  @override
  late final GeneratedColumn<double> routeDistanceKm = GeneratedColumn<double>(
    'route_distance_km',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _classificationReasonMeta =
      const VerificationMeta('classificationReason');
  @override
  late final GeneratedColumn<String> classificationReason =
      GeneratedColumn<String>(
        'classification_reason',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _configSnapshotMeta = const VerificationMeta(
    'configSnapshot',
  );
  @override
  late final GeneratedColumn<String> configSnapshot = GeneratedColumn<String>(
    'config_snapshot',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    routeId,
    shiftId,
    earningsType,
    rateAppliedCents,
    routeDeliveryCount,
    routeDistanceKm,
    classificationReason,
    configSnapshot,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'earnings_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<EarningsEntriesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('route_id')) {
      context.handle(
        _routeIdMeta,
        routeId.isAcceptableOrUnknown(data['route_id']!, _routeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_routeIdMeta);
    }
    if (data.containsKey('shift_id')) {
      context.handle(
        _shiftIdMeta,
        shiftId.isAcceptableOrUnknown(data['shift_id']!, _shiftIdMeta),
      );
    } else if (isInserting) {
      context.missing(_shiftIdMeta);
    }
    if (data.containsKey('earnings_type')) {
      context.handle(
        _earningsTypeMeta,
        earningsType.isAcceptableOrUnknown(
          data['earnings_type']!,
          _earningsTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_earningsTypeMeta);
    }
    if (data.containsKey('rate_applied_cents')) {
      context.handle(
        _rateAppliedCentsMeta,
        rateAppliedCents.isAcceptableOrUnknown(
          data['rate_applied_cents']!,
          _rateAppliedCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_rateAppliedCentsMeta);
    }
    if (data.containsKey('route_delivery_count')) {
      context.handle(
        _routeDeliveryCountMeta,
        routeDeliveryCount.isAcceptableOrUnknown(
          data['route_delivery_count']!,
          _routeDeliveryCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_routeDeliveryCountMeta);
    }
    if (data.containsKey('route_distance_km')) {
      context.handle(
        _routeDistanceKmMeta,
        routeDistanceKm.isAcceptableOrUnknown(
          data['route_distance_km']!,
          _routeDistanceKmMeta,
        ),
      );
    }
    if (data.containsKey('classification_reason')) {
      context.handle(
        _classificationReasonMeta,
        classificationReason.isAcceptableOrUnknown(
          data['classification_reason']!,
          _classificationReasonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_classificationReasonMeta);
    }
    if (data.containsKey('config_snapshot')) {
      context.handle(
        _configSnapshotMeta,
        configSnapshot.isAcceptableOrUnknown(
          data['config_snapshot']!,
          _configSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_configSnapshotMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {routeId},
  ];
  @override
  EarningsEntriesTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EarningsEntriesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      routeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}route_id'],
      )!,
      shiftId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}shift_id'],
      )!,
      earningsType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}earnings_type'],
      )!,
      rateAppliedCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rate_applied_cents'],
      )!,
      routeDeliveryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}route_delivery_count'],
      )!,
      routeDistanceKm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}route_distance_km'],
      ),
      classificationReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}classification_reason'],
      )!,
      configSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}config_snapshot'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $EarningsEntriesTableTable createAlias(String alias) {
    return $EarningsEntriesTableTable(attachedDatabase, alias);
  }
}

class EarningsEntriesTableData extends DataClass
    implements Insertable<EarningsEntriesTableData> {
  final int id;
  final int routeId;
  final int shiftId;
  final String earningsType;
  final int rateAppliedCents;
  final int routeDeliveryCount;
  final double? routeDistanceKm;
  final String classificationReason;
  final String configSnapshot;
  final String createdAt;
  const EarningsEntriesTableData({
    required this.id,
    required this.routeId,
    required this.shiftId,
    required this.earningsType,
    required this.rateAppliedCents,
    required this.routeDeliveryCount,
    this.routeDistanceKm,
    required this.classificationReason,
    required this.configSnapshot,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['route_id'] = Variable<int>(routeId);
    map['shift_id'] = Variable<int>(shiftId);
    map['earnings_type'] = Variable<String>(earningsType);
    map['rate_applied_cents'] = Variable<int>(rateAppliedCents);
    map['route_delivery_count'] = Variable<int>(routeDeliveryCount);
    if (!nullToAbsent || routeDistanceKm != null) {
      map['route_distance_km'] = Variable<double>(routeDistanceKm);
    }
    map['classification_reason'] = Variable<String>(classificationReason);
    map['config_snapshot'] = Variable<String>(configSnapshot);
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  EarningsEntriesTableCompanion toCompanion(bool nullToAbsent) {
    return EarningsEntriesTableCompanion(
      id: Value(id),
      routeId: Value(routeId),
      shiftId: Value(shiftId),
      earningsType: Value(earningsType),
      rateAppliedCents: Value(rateAppliedCents),
      routeDeliveryCount: Value(routeDeliveryCount),
      routeDistanceKm: routeDistanceKm == null && nullToAbsent
          ? const Value.absent()
          : Value(routeDistanceKm),
      classificationReason: Value(classificationReason),
      configSnapshot: Value(configSnapshot),
      createdAt: Value(createdAt),
    );
  }

  factory EarningsEntriesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EarningsEntriesTableData(
      id: serializer.fromJson<int>(json['id']),
      routeId: serializer.fromJson<int>(json['routeId']),
      shiftId: serializer.fromJson<int>(json['shiftId']),
      earningsType: serializer.fromJson<String>(json['earningsType']),
      rateAppliedCents: serializer.fromJson<int>(json['rateAppliedCents']),
      routeDeliveryCount: serializer.fromJson<int>(json['routeDeliveryCount']),
      routeDistanceKm: serializer.fromJson<double?>(json['routeDistanceKm']),
      classificationReason: serializer.fromJson<String>(
        json['classificationReason'],
      ),
      configSnapshot: serializer.fromJson<String>(json['configSnapshot']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'routeId': serializer.toJson<int>(routeId),
      'shiftId': serializer.toJson<int>(shiftId),
      'earningsType': serializer.toJson<String>(earningsType),
      'rateAppliedCents': serializer.toJson<int>(rateAppliedCents),
      'routeDeliveryCount': serializer.toJson<int>(routeDeliveryCount),
      'routeDistanceKm': serializer.toJson<double?>(routeDistanceKm),
      'classificationReason': serializer.toJson<String>(classificationReason),
      'configSnapshot': serializer.toJson<String>(configSnapshot),
      'createdAt': serializer.toJson<String>(createdAt),
    };
  }

  EarningsEntriesTableData copyWith({
    int? id,
    int? routeId,
    int? shiftId,
    String? earningsType,
    int? rateAppliedCents,
    int? routeDeliveryCount,
    Value<double?> routeDistanceKm = const Value.absent(),
    String? classificationReason,
    String? configSnapshot,
    String? createdAt,
  }) => EarningsEntriesTableData(
    id: id ?? this.id,
    routeId: routeId ?? this.routeId,
    shiftId: shiftId ?? this.shiftId,
    earningsType: earningsType ?? this.earningsType,
    rateAppliedCents: rateAppliedCents ?? this.rateAppliedCents,
    routeDeliveryCount: routeDeliveryCount ?? this.routeDeliveryCount,
    routeDistanceKm: routeDistanceKm.present
        ? routeDistanceKm.value
        : this.routeDistanceKm,
    classificationReason: classificationReason ?? this.classificationReason,
    configSnapshot: configSnapshot ?? this.configSnapshot,
    createdAt: createdAt ?? this.createdAt,
  );
  EarningsEntriesTableData copyWithCompanion(
    EarningsEntriesTableCompanion data,
  ) {
    return EarningsEntriesTableData(
      id: data.id.present ? data.id.value : this.id,
      routeId: data.routeId.present ? data.routeId.value : this.routeId,
      shiftId: data.shiftId.present ? data.shiftId.value : this.shiftId,
      earningsType: data.earningsType.present
          ? data.earningsType.value
          : this.earningsType,
      rateAppliedCents: data.rateAppliedCents.present
          ? data.rateAppliedCents.value
          : this.rateAppliedCents,
      routeDeliveryCount: data.routeDeliveryCount.present
          ? data.routeDeliveryCount.value
          : this.routeDeliveryCount,
      routeDistanceKm: data.routeDistanceKm.present
          ? data.routeDistanceKm.value
          : this.routeDistanceKm,
      classificationReason: data.classificationReason.present
          ? data.classificationReason.value
          : this.classificationReason,
      configSnapshot: data.configSnapshot.present
          ? data.configSnapshot.value
          : this.configSnapshot,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EarningsEntriesTableData(')
          ..write('id: $id, ')
          ..write('routeId: $routeId, ')
          ..write('shiftId: $shiftId, ')
          ..write('earningsType: $earningsType, ')
          ..write('rateAppliedCents: $rateAppliedCents, ')
          ..write('routeDeliveryCount: $routeDeliveryCount, ')
          ..write('routeDistanceKm: $routeDistanceKm, ')
          ..write('classificationReason: $classificationReason, ')
          ..write('configSnapshot: $configSnapshot, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    routeId,
    shiftId,
    earningsType,
    rateAppliedCents,
    routeDeliveryCount,
    routeDistanceKm,
    classificationReason,
    configSnapshot,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EarningsEntriesTableData &&
          other.id == this.id &&
          other.routeId == this.routeId &&
          other.shiftId == this.shiftId &&
          other.earningsType == this.earningsType &&
          other.rateAppliedCents == this.rateAppliedCents &&
          other.routeDeliveryCount == this.routeDeliveryCount &&
          other.routeDistanceKm == this.routeDistanceKm &&
          other.classificationReason == this.classificationReason &&
          other.configSnapshot == this.configSnapshot &&
          other.createdAt == this.createdAt);
}

class EarningsEntriesTableCompanion
    extends UpdateCompanion<EarningsEntriesTableData> {
  final Value<int> id;
  final Value<int> routeId;
  final Value<int> shiftId;
  final Value<String> earningsType;
  final Value<int> rateAppliedCents;
  final Value<int> routeDeliveryCount;
  final Value<double?> routeDistanceKm;
  final Value<String> classificationReason;
  final Value<String> configSnapshot;
  final Value<String> createdAt;
  const EarningsEntriesTableCompanion({
    this.id = const Value.absent(),
    this.routeId = const Value.absent(),
    this.shiftId = const Value.absent(),
    this.earningsType = const Value.absent(),
    this.rateAppliedCents = const Value.absent(),
    this.routeDeliveryCount = const Value.absent(),
    this.routeDistanceKm = const Value.absent(),
    this.classificationReason = const Value.absent(),
    this.configSnapshot = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  EarningsEntriesTableCompanion.insert({
    this.id = const Value.absent(),
    required int routeId,
    required int shiftId,
    required String earningsType,
    required int rateAppliedCents,
    required int routeDeliveryCount,
    this.routeDistanceKm = const Value.absent(),
    required String classificationReason,
    required String configSnapshot,
    required String createdAt,
  }) : routeId = Value(routeId),
       shiftId = Value(shiftId),
       earningsType = Value(earningsType),
       rateAppliedCents = Value(rateAppliedCents),
       routeDeliveryCount = Value(routeDeliveryCount),
       classificationReason = Value(classificationReason),
       configSnapshot = Value(configSnapshot),
       createdAt = Value(createdAt);
  static Insertable<EarningsEntriesTableData> custom({
    Expression<int>? id,
    Expression<int>? routeId,
    Expression<int>? shiftId,
    Expression<String>? earningsType,
    Expression<int>? rateAppliedCents,
    Expression<int>? routeDeliveryCount,
    Expression<double>? routeDistanceKm,
    Expression<String>? classificationReason,
    Expression<String>? configSnapshot,
    Expression<String>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (routeId != null) 'route_id': routeId,
      if (shiftId != null) 'shift_id': shiftId,
      if (earningsType != null) 'earnings_type': earningsType,
      if (rateAppliedCents != null) 'rate_applied_cents': rateAppliedCents,
      if (routeDeliveryCount != null)
        'route_delivery_count': routeDeliveryCount,
      if (routeDistanceKm != null) 'route_distance_km': routeDistanceKm,
      if (classificationReason != null)
        'classification_reason': classificationReason,
      if (configSnapshot != null) 'config_snapshot': configSnapshot,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  EarningsEntriesTableCompanion copyWith({
    Value<int>? id,
    Value<int>? routeId,
    Value<int>? shiftId,
    Value<String>? earningsType,
    Value<int>? rateAppliedCents,
    Value<int>? routeDeliveryCount,
    Value<double?>? routeDistanceKm,
    Value<String>? classificationReason,
    Value<String>? configSnapshot,
    Value<String>? createdAt,
  }) {
    return EarningsEntriesTableCompanion(
      id: id ?? this.id,
      routeId: routeId ?? this.routeId,
      shiftId: shiftId ?? this.shiftId,
      earningsType: earningsType ?? this.earningsType,
      rateAppliedCents: rateAppliedCents ?? this.rateAppliedCents,
      routeDeliveryCount: routeDeliveryCount ?? this.routeDeliveryCount,
      routeDistanceKm: routeDistanceKm ?? this.routeDistanceKm,
      classificationReason: classificationReason ?? this.classificationReason,
      configSnapshot: configSnapshot ?? this.configSnapshot,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (routeId.present) {
      map['route_id'] = Variable<int>(routeId.value);
    }
    if (shiftId.present) {
      map['shift_id'] = Variable<int>(shiftId.value);
    }
    if (earningsType.present) {
      map['earnings_type'] = Variable<String>(earningsType.value);
    }
    if (rateAppliedCents.present) {
      map['rate_applied_cents'] = Variable<int>(rateAppliedCents.value);
    }
    if (routeDeliveryCount.present) {
      map['route_delivery_count'] = Variable<int>(routeDeliveryCount.value);
    }
    if (routeDistanceKm.present) {
      map['route_distance_km'] = Variable<double>(routeDistanceKm.value);
    }
    if (classificationReason.present) {
      map['classification_reason'] = Variable<String>(
        classificationReason.value,
      );
    }
    if (configSnapshot.present) {
      map['config_snapshot'] = Variable<String>(configSnapshot.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EarningsEntriesTableCompanion(')
          ..write('id: $id, ')
          ..write('routeId: $routeId, ')
          ..write('shiftId: $shiftId, ')
          ..write('earningsType: $earningsType, ')
          ..write('rateAppliedCents: $rateAppliedCents, ')
          ..write('routeDeliveryCount: $routeDeliveryCount, ')
          ..write('routeDistanceKm: $routeDistanceKm, ')
          ..write('classificationReason: $classificationReason, ')
          ..write('configSnapshot: $configSnapshot, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $EarningsConfigTableTable extends EarningsConfigTable
    with TableInfo<$EarningsConfigTableTable, EarningsConfigTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EarningsConfigTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _baseRateCentsMeta = const VerificationMeta(
    'baseRateCents',
  );
  @override
  late final GeneratedColumn<int> baseRateCents = GeneratedColumn<int>(
    'base_rate_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(800),
  );
  static const VerificationMeta _longSingleDeliveryRateCentsMeta =
      const VerificationMeta('longSingleDeliveryRateCents');
  @override
  late final GeneratedColumn<int> longSingleDeliveryRateCents =
      GeneratedColumn<int>(
        'long_single_delivery_rate_cents',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(1000),
      );
  static const VerificationMeta _effectiveFromMeta = const VerificationMeta(
    'effectiveFrom',
  );
  @override
  late final GeneratedColumn<String> effectiveFrom = GeneratedColumn<String>(
    'effective_from',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isCurrentMeta = const VerificationMeta(
    'isCurrent',
  );
  @override
  late final GeneratedColumn<bool> isCurrent = GeneratedColumn<bool>(
    'is_current',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_current" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    baseRateCents,
    longSingleDeliveryRateCents,
    effectiveFrom,
    isCurrent,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'earnings_config';
  @override
  VerificationContext validateIntegrity(
    Insertable<EarningsConfigTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('base_rate_cents')) {
      context.handle(
        _baseRateCentsMeta,
        baseRateCents.isAcceptableOrUnknown(
          data['base_rate_cents']!,
          _baseRateCentsMeta,
        ),
      );
    }
    if (data.containsKey('long_single_delivery_rate_cents')) {
      context.handle(
        _longSingleDeliveryRateCentsMeta,
        longSingleDeliveryRateCents.isAcceptableOrUnknown(
          data['long_single_delivery_rate_cents']!,
          _longSingleDeliveryRateCentsMeta,
        ),
      );
    }
    if (data.containsKey('effective_from')) {
      context.handle(
        _effectiveFromMeta,
        effectiveFrom.isAcceptableOrUnknown(
          data['effective_from']!,
          _effectiveFromMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_effectiveFromMeta);
    }
    if (data.containsKey('is_current')) {
      context.handle(
        _isCurrentMeta,
        isCurrent.isAcceptableOrUnknown(data['is_current']!, _isCurrentMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EarningsConfigTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EarningsConfigTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      baseRateCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}base_rate_cents'],
      )!,
      longSingleDeliveryRateCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}long_single_delivery_rate_cents'],
      )!,
      effectiveFrom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}effective_from'],
      )!,
      isCurrent: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_current'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $EarningsConfigTableTable createAlias(String alias) {
    return $EarningsConfigTableTable(attachedDatabase, alias);
  }
}

class EarningsConfigTableData extends DataClass
    implements Insertable<EarningsConfigTableData> {
  final int id;
  final int baseRateCents;
  final int longSingleDeliveryRateCents;
  final String effectiveFrom;
  final bool isCurrent;
  final String createdAt;
  const EarningsConfigTableData({
    required this.id,
    required this.baseRateCents,
    required this.longSingleDeliveryRateCents,
    required this.effectiveFrom,
    required this.isCurrent,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['base_rate_cents'] = Variable<int>(baseRateCents);
    map['long_single_delivery_rate_cents'] = Variable<int>(
      longSingleDeliveryRateCents,
    );
    map['effective_from'] = Variable<String>(effectiveFrom);
    map['is_current'] = Variable<bool>(isCurrent);
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  EarningsConfigTableCompanion toCompanion(bool nullToAbsent) {
    return EarningsConfigTableCompanion(
      id: Value(id),
      baseRateCents: Value(baseRateCents),
      longSingleDeliveryRateCents: Value(longSingleDeliveryRateCents),
      effectiveFrom: Value(effectiveFrom),
      isCurrent: Value(isCurrent),
      createdAt: Value(createdAt),
    );
  }

  factory EarningsConfigTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EarningsConfigTableData(
      id: serializer.fromJson<int>(json['id']),
      baseRateCents: serializer.fromJson<int>(json['baseRateCents']),
      longSingleDeliveryRateCents: serializer.fromJson<int>(
        json['longSingleDeliveryRateCents'],
      ),
      effectiveFrom: serializer.fromJson<String>(json['effectiveFrom']),
      isCurrent: serializer.fromJson<bool>(json['isCurrent']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'baseRateCents': serializer.toJson<int>(baseRateCents),
      'longSingleDeliveryRateCents': serializer.toJson<int>(
        longSingleDeliveryRateCents,
      ),
      'effectiveFrom': serializer.toJson<String>(effectiveFrom),
      'isCurrent': serializer.toJson<bool>(isCurrent),
      'createdAt': serializer.toJson<String>(createdAt),
    };
  }

  EarningsConfigTableData copyWith({
    int? id,
    int? baseRateCents,
    int? longSingleDeliveryRateCents,
    String? effectiveFrom,
    bool? isCurrent,
    String? createdAt,
  }) => EarningsConfigTableData(
    id: id ?? this.id,
    baseRateCents: baseRateCents ?? this.baseRateCents,
    longSingleDeliveryRateCents:
        longSingleDeliveryRateCents ?? this.longSingleDeliveryRateCents,
    effectiveFrom: effectiveFrom ?? this.effectiveFrom,
    isCurrent: isCurrent ?? this.isCurrent,
    createdAt: createdAt ?? this.createdAt,
  );
  EarningsConfigTableData copyWithCompanion(EarningsConfigTableCompanion data) {
    return EarningsConfigTableData(
      id: data.id.present ? data.id.value : this.id,
      baseRateCents: data.baseRateCents.present
          ? data.baseRateCents.value
          : this.baseRateCents,
      longSingleDeliveryRateCents: data.longSingleDeliveryRateCents.present
          ? data.longSingleDeliveryRateCents.value
          : this.longSingleDeliveryRateCents,
      effectiveFrom: data.effectiveFrom.present
          ? data.effectiveFrom.value
          : this.effectiveFrom,
      isCurrent: data.isCurrent.present ? data.isCurrent.value : this.isCurrent,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EarningsConfigTableData(')
          ..write('id: $id, ')
          ..write('baseRateCents: $baseRateCents, ')
          ..write('longSingleDeliveryRateCents: $longSingleDeliveryRateCents, ')
          ..write('effectiveFrom: $effectiveFrom, ')
          ..write('isCurrent: $isCurrent, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    baseRateCents,
    longSingleDeliveryRateCents,
    effectiveFrom,
    isCurrent,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EarningsConfigTableData &&
          other.id == this.id &&
          other.baseRateCents == this.baseRateCents &&
          other.longSingleDeliveryRateCents ==
              this.longSingleDeliveryRateCents &&
          other.effectiveFrom == this.effectiveFrom &&
          other.isCurrent == this.isCurrent &&
          other.createdAt == this.createdAt);
}

class EarningsConfigTableCompanion
    extends UpdateCompanion<EarningsConfigTableData> {
  final Value<int> id;
  final Value<int> baseRateCents;
  final Value<int> longSingleDeliveryRateCents;
  final Value<String> effectiveFrom;
  final Value<bool> isCurrent;
  final Value<String> createdAt;
  const EarningsConfigTableCompanion({
    this.id = const Value.absent(),
    this.baseRateCents = const Value.absent(),
    this.longSingleDeliveryRateCents = const Value.absent(),
    this.effectiveFrom = const Value.absent(),
    this.isCurrent = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  EarningsConfigTableCompanion.insert({
    this.id = const Value.absent(),
    this.baseRateCents = const Value.absent(),
    this.longSingleDeliveryRateCents = const Value.absent(),
    required String effectiveFrom,
    this.isCurrent = const Value.absent(),
    required String createdAt,
  }) : effectiveFrom = Value(effectiveFrom),
       createdAt = Value(createdAt);
  static Insertable<EarningsConfigTableData> custom({
    Expression<int>? id,
    Expression<int>? baseRateCents,
    Expression<int>? longSingleDeliveryRateCents,
    Expression<String>? effectiveFrom,
    Expression<bool>? isCurrent,
    Expression<String>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (baseRateCents != null) 'base_rate_cents': baseRateCents,
      if (longSingleDeliveryRateCents != null)
        'long_single_delivery_rate_cents': longSingleDeliveryRateCents,
      if (effectiveFrom != null) 'effective_from': effectiveFrom,
      if (isCurrent != null) 'is_current': isCurrent,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  EarningsConfigTableCompanion copyWith({
    Value<int>? id,
    Value<int>? baseRateCents,
    Value<int>? longSingleDeliveryRateCents,
    Value<String>? effectiveFrom,
    Value<bool>? isCurrent,
    Value<String>? createdAt,
  }) {
    return EarningsConfigTableCompanion(
      id: id ?? this.id,
      baseRateCents: baseRateCents ?? this.baseRateCents,
      longSingleDeliveryRateCents:
          longSingleDeliveryRateCents ?? this.longSingleDeliveryRateCents,
      effectiveFrom: effectiveFrom ?? this.effectiveFrom,
      isCurrent: isCurrent ?? this.isCurrent,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (baseRateCents.present) {
      map['base_rate_cents'] = Variable<int>(baseRateCents.value);
    }
    if (longSingleDeliveryRateCents.present) {
      map['long_single_delivery_rate_cents'] = Variable<int>(
        longSingleDeliveryRateCents.value,
      );
    }
    if (effectiveFrom.present) {
      map['effective_from'] = Variable<String>(effectiveFrom.value);
    }
    if (isCurrent.present) {
      map['is_current'] = Variable<bool>(isCurrent.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EarningsConfigTableCompanion(')
          ..write('id: $id, ')
          ..write('baseRateCents: $baseRateCents, ')
          ..write('longSingleDeliveryRateCents: $longSingleDeliveryRateCents, ')
          ..write('effectiveFrom: $effectiveFrom, ')
          ..write('isCurrent: $isCurrent, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $AppConfigTableTable extends AppConfigTable
    with TableInfo<$AppConfigTableTable, AppConfigTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppConfigTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _driverNameMeta = const VerificationMeta(
    'driverName',
  );
  @override
  late final GeneratedColumn<String> driverName = GeneratedColumn<String>(
    'driver_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _pizzeriaAddressMeta = const VerificationMeta(
    'pizzeriaAddress',
  );
  @override
  late final GeneratedColumn<String> pizzeriaAddress = GeneratedColumn<String>(
    'pizzeria_address',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _ifoodUrlMeta = const VerificationMeta(
    'ifoodUrl',
  );
  @override
  late final GeneratedColumn<String> ifoodUrl = GeneratedColumn<String>(
    'ifood_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(
      'https://confirmacao-entrega-propria.ifood.com.br/',
    ),
  );
  static const VerificationMeta _ifoodFieldSelectorMeta =
      const VerificationMeta('ifoodFieldSelector');
  @override
  late final GeneratedColumn<String> ifoodFieldSelector =
      GeneratedColumn<String>(
        'ifood_field_selector',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  static const VerificationMeta _ocrContrastEnabledMeta =
      const VerificationMeta('ocrContrastEnabled');
  @override
  late final GeneratedColumn<bool> ocrContrastEnabled = GeneratedColumn<bool>(
    'ocr_contrast_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("ocr_contrast_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _activeRouteIdMeta = const VerificationMeta(
    'activeRouteId',
  );
  @override
  late final GeneratedColumn<int> activeRouteId = GeneratedColumn<int>(
    'active_route_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _activeDeliveryIndexMeta =
      const VerificationMeta('activeDeliveryIndex');
  @override
  late final GeneratedColumn<int> activeDeliveryIndex = GeneratedColumn<int>(
    'active_delivery_index',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dailyGoalCentsMeta = const VerificationMeta(
    'dailyGoalCents',
  );
  @override
  late final GeneratedColumn<int> dailyGoalCents = GeneratedColumn<int>(
    'daily_goal_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(12000),
  );
  static const VerificationMeta _homeAddressMeta = const VerificationMeta(
    'homeAddress',
  );
  @override
  late final GeneratedColumn<String> homeAddress = GeneratedColumn<String>(
    'home_address',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    driverName,
    pizzeriaAddress,
    ifoodUrl,
    ifoodFieldSelector,
    ocrContrastEnabled,
    activeRouteId,
    activeDeliveryIndex,
    dailyGoalCents,
    homeAddress,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_config';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppConfigTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('driver_name')) {
      context.handle(
        _driverNameMeta,
        driverName.isAcceptableOrUnknown(data['driver_name']!, _driverNameMeta),
      );
    }
    if (data.containsKey('pizzeria_address')) {
      context.handle(
        _pizzeriaAddressMeta,
        pizzeriaAddress.isAcceptableOrUnknown(
          data['pizzeria_address']!,
          _pizzeriaAddressMeta,
        ),
      );
    }
    if (data.containsKey('ifood_url')) {
      context.handle(
        _ifoodUrlMeta,
        ifoodUrl.isAcceptableOrUnknown(data['ifood_url']!, _ifoodUrlMeta),
      );
    }
    if (data.containsKey('ifood_field_selector')) {
      context.handle(
        _ifoodFieldSelectorMeta,
        ifoodFieldSelector.isAcceptableOrUnknown(
          data['ifood_field_selector']!,
          _ifoodFieldSelectorMeta,
        ),
      );
    }
    if (data.containsKey('ocr_contrast_enabled')) {
      context.handle(
        _ocrContrastEnabledMeta,
        ocrContrastEnabled.isAcceptableOrUnknown(
          data['ocr_contrast_enabled']!,
          _ocrContrastEnabledMeta,
        ),
      );
    }
    if (data.containsKey('active_route_id')) {
      context.handle(
        _activeRouteIdMeta,
        activeRouteId.isAcceptableOrUnknown(
          data['active_route_id']!,
          _activeRouteIdMeta,
        ),
      );
    }
    if (data.containsKey('active_delivery_index')) {
      context.handle(
        _activeDeliveryIndexMeta,
        activeDeliveryIndex.isAcceptableOrUnknown(
          data['active_delivery_index']!,
          _activeDeliveryIndexMeta,
        ),
      );
    }
    if (data.containsKey('daily_goal_cents')) {
      context.handle(
        _dailyGoalCentsMeta,
        dailyGoalCents.isAcceptableOrUnknown(
          data['daily_goal_cents']!,
          _dailyGoalCentsMeta,
        ),
      );
    }
    if (data.containsKey('home_address')) {
      context.handle(
        _homeAddressMeta,
        homeAddress.isAcceptableOrUnknown(
          data['home_address']!,
          _homeAddressMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppConfigTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppConfigTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      driverName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}driver_name'],
      )!,
      pizzeriaAddress: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pizzeria_address'],
      )!,
      ifoodUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ifood_url'],
      )!,
      ifoodFieldSelector: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ifood_field_selector'],
      )!,
      ocrContrastEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}ocr_contrast_enabled'],
      )!,
      activeRouteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}active_route_id'],
      ),
      activeDeliveryIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}active_delivery_index'],
      ),
      dailyGoalCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}daily_goal_cents'],
      )!,
      homeAddress: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}home_address'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AppConfigTableTable createAlias(String alias) {
    return $AppConfigTableTable(attachedDatabase, alias);
  }
}

class AppConfigTableData extends DataClass
    implements Insertable<AppConfigTableData> {
  final int id;
  final String driverName;
  final String pizzeriaAddress;
  final String ifoodUrl;
  final String ifoodFieldSelector;
  final bool ocrContrastEnabled;
  final int? activeRouteId;
  final int? activeDeliveryIndex;
  final int dailyGoalCents;
  final String homeAddress;
  final String createdAt;
  final String updatedAt;
  const AppConfigTableData({
    required this.id,
    required this.driverName,
    required this.pizzeriaAddress,
    required this.ifoodUrl,
    required this.ifoodFieldSelector,
    required this.ocrContrastEnabled,
    this.activeRouteId,
    this.activeDeliveryIndex,
    required this.dailyGoalCents,
    required this.homeAddress,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['driver_name'] = Variable<String>(driverName);
    map['pizzeria_address'] = Variable<String>(pizzeriaAddress);
    map['ifood_url'] = Variable<String>(ifoodUrl);
    map['ifood_field_selector'] = Variable<String>(ifoodFieldSelector);
    map['ocr_contrast_enabled'] = Variable<bool>(ocrContrastEnabled);
    if (!nullToAbsent || activeRouteId != null) {
      map['active_route_id'] = Variable<int>(activeRouteId);
    }
    if (!nullToAbsent || activeDeliveryIndex != null) {
      map['active_delivery_index'] = Variable<int>(activeDeliveryIndex);
    }
    map['daily_goal_cents'] = Variable<int>(dailyGoalCents);
    map['home_address'] = Variable<String>(homeAddress);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  AppConfigTableCompanion toCompanion(bool nullToAbsent) {
    return AppConfigTableCompanion(
      id: Value(id),
      driverName: Value(driverName),
      pizzeriaAddress: Value(pizzeriaAddress),
      ifoodUrl: Value(ifoodUrl),
      ifoodFieldSelector: Value(ifoodFieldSelector),
      ocrContrastEnabled: Value(ocrContrastEnabled),
      activeRouteId: activeRouteId == null && nullToAbsent
          ? const Value.absent()
          : Value(activeRouteId),
      activeDeliveryIndex: activeDeliveryIndex == null && nullToAbsent
          ? const Value.absent()
          : Value(activeDeliveryIndex),
      dailyGoalCents: Value(dailyGoalCents),
      homeAddress: Value(homeAddress),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory AppConfigTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppConfigTableData(
      id: serializer.fromJson<int>(json['id']),
      driverName: serializer.fromJson<String>(json['driverName']),
      pizzeriaAddress: serializer.fromJson<String>(json['pizzeriaAddress']),
      ifoodUrl: serializer.fromJson<String>(json['ifoodUrl']),
      ifoodFieldSelector: serializer.fromJson<String>(
        json['ifoodFieldSelector'],
      ),
      ocrContrastEnabled: serializer.fromJson<bool>(json['ocrContrastEnabled']),
      activeRouteId: serializer.fromJson<int?>(json['activeRouteId']),
      activeDeliveryIndex: serializer.fromJson<int?>(
        json['activeDeliveryIndex'],
      ),
      dailyGoalCents: serializer.fromJson<int>(json['dailyGoalCents']),
      homeAddress: serializer.fromJson<String>(json['homeAddress']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'driverName': serializer.toJson<String>(driverName),
      'pizzeriaAddress': serializer.toJson<String>(pizzeriaAddress),
      'ifoodUrl': serializer.toJson<String>(ifoodUrl),
      'ifoodFieldSelector': serializer.toJson<String>(ifoodFieldSelector),
      'ocrContrastEnabled': serializer.toJson<bool>(ocrContrastEnabled),
      'activeRouteId': serializer.toJson<int?>(activeRouteId),
      'activeDeliveryIndex': serializer.toJson<int?>(activeDeliveryIndex),
      'dailyGoalCents': serializer.toJson<int>(dailyGoalCents),
      'homeAddress': serializer.toJson<String>(homeAddress),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  AppConfigTableData copyWith({
    int? id,
    String? driverName,
    String? pizzeriaAddress,
    String? ifoodUrl,
    String? ifoodFieldSelector,
    bool? ocrContrastEnabled,
    Value<int?> activeRouteId = const Value.absent(),
    Value<int?> activeDeliveryIndex = const Value.absent(),
    int? dailyGoalCents,
    String? homeAddress,
    String? createdAt,
    String? updatedAt,
  }) => AppConfigTableData(
    id: id ?? this.id,
    driverName: driverName ?? this.driverName,
    pizzeriaAddress: pizzeriaAddress ?? this.pizzeriaAddress,
    ifoodUrl: ifoodUrl ?? this.ifoodUrl,
    ifoodFieldSelector: ifoodFieldSelector ?? this.ifoodFieldSelector,
    ocrContrastEnabled: ocrContrastEnabled ?? this.ocrContrastEnabled,
    activeRouteId: activeRouteId.present
        ? activeRouteId.value
        : this.activeRouteId,
    activeDeliveryIndex: activeDeliveryIndex.present
        ? activeDeliveryIndex.value
        : this.activeDeliveryIndex,
    dailyGoalCents: dailyGoalCents ?? this.dailyGoalCents,
    homeAddress: homeAddress ?? this.homeAddress,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AppConfigTableData copyWithCompanion(AppConfigTableCompanion data) {
    return AppConfigTableData(
      id: data.id.present ? data.id.value : this.id,
      driverName: data.driverName.present
          ? data.driverName.value
          : this.driverName,
      pizzeriaAddress: data.pizzeriaAddress.present
          ? data.pizzeriaAddress.value
          : this.pizzeriaAddress,
      ifoodUrl: data.ifoodUrl.present ? data.ifoodUrl.value : this.ifoodUrl,
      ifoodFieldSelector: data.ifoodFieldSelector.present
          ? data.ifoodFieldSelector.value
          : this.ifoodFieldSelector,
      ocrContrastEnabled: data.ocrContrastEnabled.present
          ? data.ocrContrastEnabled.value
          : this.ocrContrastEnabled,
      activeRouteId: data.activeRouteId.present
          ? data.activeRouteId.value
          : this.activeRouteId,
      activeDeliveryIndex: data.activeDeliveryIndex.present
          ? data.activeDeliveryIndex.value
          : this.activeDeliveryIndex,
      dailyGoalCents: data.dailyGoalCents.present
          ? data.dailyGoalCents.value
          : this.dailyGoalCents,
      homeAddress: data.homeAddress.present
          ? data.homeAddress.value
          : this.homeAddress,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppConfigTableData(')
          ..write('id: $id, ')
          ..write('driverName: $driverName, ')
          ..write('pizzeriaAddress: $pizzeriaAddress, ')
          ..write('ifoodUrl: $ifoodUrl, ')
          ..write('ifoodFieldSelector: $ifoodFieldSelector, ')
          ..write('ocrContrastEnabled: $ocrContrastEnabled, ')
          ..write('activeRouteId: $activeRouteId, ')
          ..write('activeDeliveryIndex: $activeDeliveryIndex, ')
          ..write('dailyGoalCents: $dailyGoalCents, ')
          ..write('homeAddress: $homeAddress, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    driverName,
    pizzeriaAddress,
    ifoodUrl,
    ifoodFieldSelector,
    ocrContrastEnabled,
    activeRouteId,
    activeDeliveryIndex,
    dailyGoalCents,
    homeAddress,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppConfigTableData &&
          other.id == this.id &&
          other.driverName == this.driverName &&
          other.pizzeriaAddress == this.pizzeriaAddress &&
          other.ifoodUrl == this.ifoodUrl &&
          other.ifoodFieldSelector == this.ifoodFieldSelector &&
          other.ocrContrastEnabled == this.ocrContrastEnabled &&
          other.activeRouteId == this.activeRouteId &&
          other.activeDeliveryIndex == this.activeDeliveryIndex &&
          other.dailyGoalCents == this.dailyGoalCents &&
          other.homeAddress == this.homeAddress &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class AppConfigTableCompanion extends UpdateCompanion<AppConfigTableData> {
  final Value<int> id;
  final Value<String> driverName;
  final Value<String> pizzeriaAddress;
  final Value<String> ifoodUrl;
  final Value<String> ifoodFieldSelector;
  final Value<bool> ocrContrastEnabled;
  final Value<int?> activeRouteId;
  final Value<int?> activeDeliveryIndex;
  final Value<int> dailyGoalCents;
  final Value<String> homeAddress;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  const AppConfigTableCompanion({
    this.id = const Value.absent(),
    this.driverName = const Value.absent(),
    this.pizzeriaAddress = const Value.absent(),
    this.ifoodUrl = const Value.absent(),
    this.ifoodFieldSelector = const Value.absent(),
    this.ocrContrastEnabled = const Value.absent(),
    this.activeRouteId = const Value.absent(),
    this.activeDeliveryIndex = const Value.absent(),
    this.dailyGoalCents = const Value.absent(),
    this.homeAddress = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  AppConfigTableCompanion.insert({
    this.id = const Value.absent(),
    this.driverName = const Value.absent(),
    this.pizzeriaAddress = const Value.absent(),
    this.ifoodUrl = const Value.absent(),
    this.ifoodFieldSelector = const Value.absent(),
    this.ocrContrastEnabled = const Value.absent(),
    this.activeRouteId = const Value.absent(),
    this.activeDeliveryIndex = const Value.absent(),
    this.dailyGoalCents = const Value.absent(),
    this.homeAddress = const Value.absent(),
    required String createdAt,
    required String updatedAt,
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<AppConfigTableData> custom({
    Expression<int>? id,
    Expression<String>? driverName,
    Expression<String>? pizzeriaAddress,
    Expression<String>? ifoodUrl,
    Expression<String>? ifoodFieldSelector,
    Expression<bool>? ocrContrastEnabled,
    Expression<int>? activeRouteId,
    Expression<int>? activeDeliveryIndex,
    Expression<int>? dailyGoalCents,
    Expression<String>? homeAddress,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (driverName != null) 'driver_name': driverName,
      if (pizzeriaAddress != null) 'pizzeria_address': pizzeriaAddress,
      if (ifoodUrl != null) 'ifood_url': ifoodUrl,
      if (ifoodFieldSelector != null)
        'ifood_field_selector': ifoodFieldSelector,
      if (ocrContrastEnabled != null)
        'ocr_contrast_enabled': ocrContrastEnabled,
      if (activeRouteId != null) 'active_route_id': activeRouteId,
      if (activeDeliveryIndex != null)
        'active_delivery_index': activeDeliveryIndex,
      if (dailyGoalCents != null) 'daily_goal_cents': dailyGoalCents,
      if (homeAddress != null) 'home_address': homeAddress,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  AppConfigTableCompanion copyWith({
    Value<int>? id,
    Value<String>? driverName,
    Value<String>? pizzeriaAddress,
    Value<String>? ifoodUrl,
    Value<String>? ifoodFieldSelector,
    Value<bool>? ocrContrastEnabled,
    Value<int?>? activeRouteId,
    Value<int?>? activeDeliveryIndex,
    Value<int>? dailyGoalCents,
    Value<String>? homeAddress,
    Value<String>? createdAt,
    Value<String>? updatedAt,
  }) {
    return AppConfigTableCompanion(
      id: id ?? this.id,
      driverName: driverName ?? this.driverName,
      pizzeriaAddress: pizzeriaAddress ?? this.pizzeriaAddress,
      ifoodUrl: ifoodUrl ?? this.ifoodUrl,
      ifoodFieldSelector: ifoodFieldSelector ?? this.ifoodFieldSelector,
      ocrContrastEnabled: ocrContrastEnabled ?? this.ocrContrastEnabled,
      activeRouteId: activeRouteId ?? this.activeRouteId,
      activeDeliveryIndex: activeDeliveryIndex ?? this.activeDeliveryIndex,
      dailyGoalCents: dailyGoalCents ?? this.dailyGoalCents,
      homeAddress: homeAddress ?? this.homeAddress,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (driverName.present) {
      map['driver_name'] = Variable<String>(driverName.value);
    }
    if (pizzeriaAddress.present) {
      map['pizzeria_address'] = Variable<String>(pizzeriaAddress.value);
    }
    if (ifoodUrl.present) {
      map['ifood_url'] = Variable<String>(ifoodUrl.value);
    }
    if (ifoodFieldSelector.present) {
      map['ifood_field_selector'] = Variable<String>(ifoodFieldSelector.value);
    }
    if (ocrContrastEnabled.present) {
      map['ocr_contrast_enabled'] = Variable<bool>(ocrContrastEnabled.value);
    }
    if (activeRouteId.present) {
      map['active_route_id'] = Variable<int>(activeRouteId.value);
    }
    if (activeDeliveryIndex.present) {
      map['active_delivery_index'] = Variable<int>(activeDeliveryIndex.value);
    }
    if (dailyGoalCents.present) {
      map['daily_goal_cents'] = Variable<int>(dailyGoalCents.value);
    }
    if (homeAddress.present) {
      map['home_address'] = Variable<String>(homeAddress.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppConfigTableCompanion(')
          ..write('id: $id, ')
          ..write('driverName: $driverName, ')
          ..write('pizzeriaAddress: $pizzeriaAddress, ')
          ..write('ifoodUrl: $ifoodUrl, ')
          ..write('ifoodFieldSelector: $ifoodFieldSelector, ')
          ..write('ocrContrastEnabled: $ocrContrastEnabled, ')
          ..write('activeRouteId: $activeRouteId, ')
          ..write('activeDeliveryIndex: $activeDeliveryIndex, ')
          ..write('dailyGoalCents: $dailyGoalCents, ')
          ..write('homeAddress: $homeAddress, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ShiftsTableTable shiftsTable = $ShiftsTableTable(this);
  late final $RoutesTableTable routesTable = $RoutesTableTable(this);
  late final $DeliveriesTableTable deliveriesTable = $DeliveriesTableTable(
    this,
  );
  late final $ReceiptsTableTable receiptsTable = $ReceiptsTableTable(this);
  late final $EarningsEntriesTableTable earningsEntriesTable =
      $EarningsEntriesTableTable(this);
  late final $EarningsConfigTableTable earningsConfigTable =
      $EarningsConfigTableTable(this);
  late final $AppConfigTableTable appConfigTable = $AppConfigTableTable(this);
  late final ShiftsDao shiftsDao = ShiftsDao(this as AppDatabase);
  late final RoutesDao routesDao = RoutesDao(this as AppDatabase);
  late final DeliveriesDao deliveriesDao = DeliveriesDao(this as AppDatabase);
  late final ReceiptsDao receiptsDao = ReceiptsDao(this as AppDatabase);
  late final EarningsDao earningsDao = EarningsDao(this as AppDatabase);
  late final ConfigDao configDao = ConfigDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    shiftsTable,
    routesTable,
    deliveriesTable,
    receiptsTable,
    earningsEntriesTable,
    earningsConfigTable,
    appConfigTable,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'shifts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('routes', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'routes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('deliveries', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'shifts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('deliveries', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'deliveries',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('receipts', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'routes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('earnings_entries', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'shifts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('earnings_entries', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$ShiftsTableTableCreateCompanionBuilder =
    ShiftsTableCompanion Function({
      Value<int> id,
      required String driverName,
      required String startedAt,
      Value<String?> endedAt,
      Value<String> status,
      Value<int?> totalEarningsCents,
      Value<int?> deliveryCount,
      Value<String?> notes,
      required String createdAt,
      Value<String> source,
      Value<double?> hoursWorked,
      Value<int?> fuelExpenseCents,
    });
typedef $$ShiftsTableTableUpdateCompanionBuilder =
    ShiftsTableCompanion Function({
      Value<int> id,
      Value<String> driverName,
      Value<String> startedAt,
      Value<String?> endedAt,
      Value<String> status,
      Value<int?> totalEarningsCents,
      Value<int?> deliveryCount,
      Value<String?> notes,
      Value<String> createdAt,
      Value<String> source,
      Value<double?> hoursWorked,
      Value<int?> fuelExpenseCents,
    });

final class $$ShiftsTableTableReferences
    extends BaseReferences<_$AppDatabase, $ShiftsTableTable, ShiftsTableData> {
  $$ShiftsTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RoutesTableTable, List<RoutesTableData>>
  _routesTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.routesTable,
    aliasName: $_aliasNameGenerator(db.shiftsTable.id, db.routesTable.shiftId),
  );

  $$RoutesTableTableProcessedTableManager get routesTableRefs {
    final manager = $$RoutesTableTableTableManager(
      $_db,
      $_db.routesTable,
    ).filter((f) => f.shiftId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_routesTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DeliveriesTableTable, List<DeliveriesTableData>>
  _deliveriesTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.deliveriesTable,
    aliasName: $_aliasNameGenerator(
      db.shiftsTable.id,
      db.deliveriesTable.shiftId,
    ),
  );

  $$DeliveriesTableTableProcessedTableManager get deliveriesTableRefs {
    final manager = $$DeliveriesTableTableTableManager(
      $_db,
      $_db.deliveriesTable,
    ).filter((f) => f.shiftId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _deliveriesTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $EarningsEntriesTableTable,
    List<EarningsEntriesTableData>
  >
  _earningsEntriesTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.earningsEntriesTable,
        aliasName: $_aliasNameGenerator(
          db.shiftsTable.id,
          db.earningsEntriesTable.shiftId,
        ),
      );

  $$EarningsEntriesTableTableProcessedTableManager
  get earningsEntriesTableRefs {
    final manager = $$EarningsEntriesTableTableTableManager(
      $_db,
      $_db.earningsEntriesTable,
    ).filter((f) => f.shiftId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _earningsEntriesTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ShiftsTableTableFilterComposer
    extends Composer<_$AppDatabase, $ShiftsTableTable> {
  $$ShiftsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get driverName => $composableBuilder(
    column: $table.driverName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalEarningsCents => $composableBuilder(
    column: $table.totalEarningsCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deliveryCount => $composableBuilder(
    column: $table.deliveryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get hoursWorked => $composableBuilder(
    column: $table.hoursWorked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fuelExpenseCents => $composableBuilder(
    column: $table.fuelExpenseCents,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> routesTableRefs(
    Expression<bool> Function($$RoutesTableTableFilterComposer f) f,
  ) {
    final $$RoutesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routesTable,
      getReferencedColumn: (t) => t.shiftId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutesTableTableFilterComposer(
            $db: $db,
            $table: $db.routesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> deliveriesTableRefs(
    Expression<bool> Function($$DeliveriesTableTableFilterComposer f) f,
  ) {
    final $$DeliveriesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.deliveriesTable,
      getReferencedColumn: (t) => t.shiftId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DeliveriesTableTableFilterComposer(
            $db: $db,
            $table: $db.deliveriesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> earningsEntriesTableRefs(
    Expression<bool> Function($$EarningsEntriesTableTableFilterComposer f) f,
  ) {
    final $$EarningsEntriesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.earningsEntriesTable,
      getReferencedColumn: (t) => t.shiftId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EarningsEntriesTableTableFilterComposer(
            $db: $db,
            $table: $db.earningsEntriesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ShiftsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ShiftsTableTable> {
  $$ShiftsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get driverName => $composableBuilder(
    column: $table.driverName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalEarningsCents => $composableBuilder(
    column: $table.totalEarningsCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deliveryCount => $composableBuilder(
    column: $table.deliveryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get hoursWorked => $composableBuilder(
    column: $table.hoursWorked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fuelExpenseCents => $composableBuilder(
    column: $table.fuelExpenseCents,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ShiftsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShiftsTableTable> {
  $$ShiftsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get driverName => $composableBuilder(
    column: $table.driverName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<String> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get totalEarningsCents => $composableBuilder(
    column: $table.totalEarningsCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deliveryCount => $composableBuilder(
    column: $table.deliveryCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<double> get hoursWorked => $composableBuilder(
    column: $table.hoursWorked,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fuelExpenseCents => $composableBuilder(
    column: $table.fuelExpenseCents,
    builder: (column) => column,
  );

  Expression<T> routesTableRefs<T extends Object>(
    Expression<T> Function($$RoutesTableTableAnnotationComposer a) f,
  ) {
    final $$RoutesTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routesTable,
      getReferencedColumn: (t) => t.shiftId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutesTableTableAnnotationComposer(
            $db: $db,
            $table: $db.routesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> deliveriesTableRefs<T extends Object>(
    Expression<T> Function($$DeliveriesTableTableAnnotationComposer a) f,
  ) {
    final $$DeliveriesTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.deliveriesTable,
      getReferencedColumn: (t) => t.shiftId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DeliveriesTableTableAnnotationComposer(
            $db: $db,
            $table: $db.deliveriesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> earningsEntriesTableRefs<T extends Object>(
    Expression<T> Function($$EarningsEntriesTableTableAnnotationComposer a) f,
  ) {
    final $$EarningsEntriesTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.earningsEntriesTable,
          getReferencedColumn: (t) => t.shiftId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$EarningsEntriesTableTableAnnotationComposer(
                $db: $db,
                $table: $db.earningsEntriesTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ShiftsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ShiftsTableTable,
          ShiftsTableData,
          $$ShiftsTableTableFilterComposer,
          $$ShiftsTableTableOrderingComposer,
          $$ShiftsTableTableAnnotationComposer,
          $$ShiftsTableTableCreateCompanionBuilder,
          $$ShiftsTableTableUpdateCompanionBuilder,
          (ShiftsTableData, $$ShiftsTableTableReferences),
          ShiftsTableData,
          PrefetchHooks Function({
            bool routesTableRefs,
            bool deliveriesTableRefs,
            bool earningsEntriesTableRefs,
          })
        > {
  $$ShiftsTableTableTableManager(_$AppDatabase db, $ShiftsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShiftsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShiftsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShiftsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> driverName = const Value.absent(),
                Value<String> startedAt = const Value.absent(),
                Value<String?> endedAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> totalEarningsCents = const Value.absent(),
                Value<int?> deliveryCount = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<double?> hoursWorked = const Value.absent(),
                Value<int?> fuelExpenseCents = const Value.absent(),
              }) => ShiftsTableCompanion(
                id: id,
                driverName: driverName,
                startedAt: startedAt,
                endedAt: endedAt,
                status: status,
                totalEarningsCents: totalEarningsCents,
                deliveryCount: deliveryCount,
                notes: notes,
                createdAt: createdAt,
                source: source,
                hoursWorked: hoursWorked,
                fuelExpenseCents: fuelExpenseCents,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String driverName,
                required String startedAt,
                Value<String?> endedAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> totalEarningsCents = const Value.absent(),
                Value<int?> deliveryCount = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required String createdAt,
                Value<String> source = const Value.absent(),
                Value<double?> hoursWorked = const Value.absent(),
                Value<int?> fuelExpenseCents = const Value.absent(),
              }) => ShiftsTableCompanion.insert(
                id: id,
                driverName: driverName,
                startedAt: startedAt,
                endedAt: endedAt,
                status: status,
                totalEarningsCents: totalEarningsCents,
                deliveryCount: deliveryCount,
                notes: notes,
                createdAt: createdAt,
                source: source,
                hoursWorked: hoursWorked,
                fuelExpenseCents: fuelExpenseCents,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ShiftsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                routesTableRefs = false,
                deliveriesTableRefs = false,
                earningsEntriesTableRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (routesTableRefs) db.routesTable,
                    if (deliveriesTableRefs) db.deliveriesTable,
                    if (earningsEntriesTableRefs) db.earningsEntriesTable,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (routesTableRefs)
                        await $_getPrefetchedData<
                          ShiftsTableData,
                          $ShiftsTableTable,
                          RoutesTableData
                        >(
                          currentTable: table,
                          referencedTable: $$ShiftsTableTableReferences
                              ._routesTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ShiftsTableTableReferences(
                                db,
                                table,
                                p0,
                              ).routesTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.shiftId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (deliveriesTableRefs)
                        await $_getPrefetchedData<
                          ShiftsTableData,
                          $ShiftsTableTable,
                          DeliveriesTableData
                        >(
                          currentTable: table,
                          referencedTable: $$ShiftsTableTableReferences
                              ._deliveriesTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ShiftsTableTableReferences(
                                db,
                                table,
                                p0,
                              ).deliveriesTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.shiftId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (earningsEntriesTableRefs)
                        await $_getPrefetchedData<
                          ShiftsTableData,
                          $ShiftsTableTable,
                          EarningsEntriesTableData
                        >(
                          currentTable: table,
                          referencedTable: $$ShiftsTableTableReferences
                              ._earningsEntriesTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ShiftsTableTableReferences(
                                db,
                                table,
                                p0,
                              ).earningsEntriesTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.shiftId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ShiftsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ShiftsTableTable,
      ShiftsTableData,
      $$ShiftsTableTableFilterComposer,
      $$ShiftsTableTableOrderingComposer,
      $$ShiftsTableTableAnnotationComposer,
      $$ShiftsTableTableCreateCompanionBuilder,
      $$ShiftsTableTableUpdateCompanionBuilder,
      (ShiftsTableData, $$ShiftsTableTableReferences),
      ShiftsTableData,
      PrefetchHooks Function({
        bool routesTableRefs,
        bool deliveriesTableRefs,
        bool earningsEntriesTableRefs,
      })
    >;
typedef $$RoutesTableTableCreateCompanionBuilder =
    RoutesTableCompanion Function({
      Value<int> id,
      required int shiftId,
      required int routeNumber,
      Value<String> status,
      required String startedAt,
      Value<String?> closedAt,
      Value<int?> deliveryCountAtClose,
      required String createdAt,
    });
typedef $$RoutesTableTableUpdateCompanionBuilder =
    RoutesTableCompanion Function({
      Value<int> id,
      Value<int> shiftId,
      Value<int> routeNumber,
      Value<String> status,
      Value<String> startedAt,
      Value<String?> closedAt,
      Value<int?> deliveryCountAtClose,
      Value<String> createdAt,
    });

final class $$RoutesTableTableReferences
    extends BaseReferences<_$AppDatabase, $RoutesTableTable, RoutesTableData> {
  $$RoutesTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ShiftsTableTable _shiftIdTable(_$AppDatabase db) =>
      db.shiftsTable.createAlias(
        $_aliasNameGenerator(db.routesTable.shiftId, db.shiftsTable.id),
      );

  $$ShiftsTableTableProcessedTableManager get shiftId {
    final $_column = $_itemColumn<int>('shift_id')!;

    final manager = $$ShiftsTableTableTableManager(
      $_db,
      $_db.shiftsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_shiftIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$DeliveriesTableTable, List<DeliveriesTableData>>
  _deliveriesTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.deliveriesTable,
    aliasName: $_aliasNameGenerator(
      db.routesTable.id,
      db.deliveriesTable.routeId,
    ),
  );

  $$DeliveriesTableTableProcessedTableManager get deliveriesTableRefs {
    final manager = $$DeliveriesTableTableTableManager(
      $_db,
      $_db.deliveriesTable,
    ).filter((f) => f.routeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _deliveriesTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $EarningsEntriesTableTable,
    List<EarningsEntriesTableData>
  >
  _earningsEntriesTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.earningsEntriesTable,
        aliasName: $_aliasNameGenerator(
          db.routesTable.id,
          db.earningsEntriesTable.routeId,
        ),
      );

  $$EarningsEntriesTableTableProcessedTableManager
  get earningsEntriesTableRefs {
    final manager = $$EarningsEntriesTableTableTableManager(
      $_db,
      $_db.earningsEntriesTable,
    ).filter((f) => f.routeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _earningsEntriesTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RoutesTableTableFilterComposer
    extends Composer<_$AppDatabase, $RoutesTableTable> {
  $$RoutesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get routeNumber => $composableBuilder(
    column: $table.routeNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get closedAt => $composableBuilder(
    column: $table.closedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deliveryCountAtClose => $composableBuilder(
    column: $table.deliveryCountAtClose,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ShiftsTableTableFilterComposer get shiftId {
    final $$ShiftsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shiftId,
      referencedTable: $db.shiftsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShiftsTableTableFilterComposer(
            $db: $db,
            $table: $db.shiftsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> deliveriesTableRefs(
    Expression<bool> Function($$DeliveriesTableTableFilterComposer f) f,
  ) {
    final $$DeliveriesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.deliveriesTable,
      getReferencedColumn: (t) => t.routeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DeliveriesTableTableFilterComposer(
            $db: $db,
            $table: $db.deliveriesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> earningsEntriesTableRefs(
    Expression<bool> Function($$EarningsEntriesTableTableFilterComposer f) f,
  ) {
    final $$EarningsEntriesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.earningsEntriesTable,
      getReferencedColumn: (t) => t.routeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EarningsEntriesTableTableFilterComposer(
            $db: $db,
            $table: $db.earningsEntriesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoutesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $RoutesTableTable> {
  $$RoutesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get routeNumber => $composableBuilder(
    column: $table.routeNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get closedAt => $composableBuilder(
    column: $table.closedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deliveryCountAtClose => $composableBuilder(
    column: $table.deliveryCountAtClose,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ShiftsTableTableOrderingComposer get shiftId {
    final $$ShiftsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shiftId,
      referencedTable: $db.shiftsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShiftsTableTableOrderingComposer(
            $db: $db,
            $table: $db.shiftsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoutesTableTable> {
  $$RoutesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get routeNumber => $composableBuilder(
    column: $table.routeNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<String> get closedAt =>
      $composableBuilder(column: $table.closedAt, builder: (column) => column);

  GeneratedColumn<int> get deliveryCountAtClose => $composableBuilder(
    column: $table.deliveryCountAtClose,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ShiftsTableTableAnnotationComposer get shiftId {
    final $$ShiftsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shiftId,
      referencedTable: $db.shiftsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShiftsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.shiftsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> deliveriesTableRefs<T extends Object>(
    Expression<T> Function($$DeliveriesTableTableAnnotationComposer a) f,
  ) {
    final $$DeliveriesTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.deliveriesTable,
      getReferencedColumn: (t) => t.routeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DeliveriesTableTableAnnotationComposer(
            $db: $db,
            $table: $db.deliveriesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> earningsEntriesTableRefs<T extends Object>(
    Expression<T> Function($$EarningsEntriesTableTableAnnotationComposer a) f,
  ) {
    final $$EarningsEntriesTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.earningsEntriesTable,
          getReferencedColumn: (t) => t.routeId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$EarningsEntriesTableTableAnnotationComposer(
                $db: $db,
                $table: $db.earningsEntriesTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$RoutesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RoutesTableTable,
          RoutesTableData,
          $$RoutesTableTableFilterComposer,
          $$RoutesTableTableOrderingComposer,
          $$RoutesTableTableAnnotationComposer,
          $$RoutesTableTableCreateCompanionBuilder,
          $$RoutesTableTableUpdateCompanionBuilder,
          (RoutesTableData, $$RoutesTableTableReferences),
          RoutesTableData,
          PrefetchHooks Function({
            bool shiftId,
            bool deliveriesTableRefs,
            bool earningsEntriesTableRefs,
          })
        > {
  $$RoutesTableTableTableManager(_$AppDatabase db, $RoutesTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoutesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoutesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoutesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> shiftId = const Value.absent(),
                Value<int> routeNumber = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> startedAt = const Value.absent(),
                Value<String?> closedAt = const Value.absent(),
                Value<int?> deliveryCountAtClose = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
              }) => RoutesTableCompanion(
                id: id,
                shiftId: shiftId,
                routeNumber: routeNumber,
                status: status,
                startedAt: startedAt,
                closedAt: closedAt,
                deliveryCountAtClose: deliveryCountAtClose,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int shiftId,
                required int routeNumber,
                Value<String> status = const Value.absent(),
                required String startedAt,
                Value<String?> closedAt = const Value.absent(),
                Value<int?> deliveryCountAtClose = const Value.absent(),
                required String createdAt,
              }) => RoutesTableCompanion.insert(
                id: id,
                shiftId: shiftId,
                routeNumber: routeNumber,
                status: status,
                startedAt: startedAt,
                closedAt: closedAt,
                deliveryCountAtClose: deliveryCountAtClose,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RoutesTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                shiftId = false,
                deliveriesTableRefs = false,
                earningsEntriesTableRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (deliveriesTableRefs) db.deliveriesTable,
                    if (earningsEntriesTableRefs) db.earningsEntriesTable,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (shiftId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.shiftId,
                                    referencedTable:
                                        $$RoutesTableTableReferences
                                            ._shiftIdTable(db),
                                    referencedColumn:
                                        $$RoutesTableTableReferences
                                            ._shiftIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (deliveriesTableRefs)
                        await $_getPrefetchedData<
                          RoutesTableData,
                          $RoutesTableTable,
                          DeliveriesTableData
                        >(
                          currentTable: table,
                          referencedTable: $$RoutesTableTableReferences
                              ._deliveriesTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RoutesTableTableReferences(
                                db,
                                table,
                                p0,
                              ).deliveriesTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.routeId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (earningsEntriesTableRefs)
                        await $_getPrefetchedData<
                          RoutesTableData,
                          $RoutesTableTable,
                          EarningsEntriesTableData
                        >(
                          currentTable: table,
                          referencedTable: $$RoutesTableTableReferences
                              ._earningsEntriesTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RoutesTableTableReferences(
                                db,
                                table,
                                p0,
                              ).earningsEntriesTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.routeId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$RoutesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RoutesTableTable,
      RoutesTableData,
      $$RoutesTableTableFilterComposer,
      $$RoutesTableTableOrderingComposer,
      $$RoutesTableTableAnnotationComposer,
      $$RoutesTableTableCreateCompanionBuilder,
      $$RoutesTableTableUpdateCompanionBuilder,
      (RoutesTableData, $$RoutesTableTableReferences),
      RoutesTableData,
      PrefetchHooks Function({
        bool shiftId,
        bool deliveriesTableRefs,
        bool earningsEntriesTableRefs,
      })
    >;
typedef $$DeliveriesTableTableCreateCompanionBuilder =
    DeliveriesTableCompanion Function({
      Value<int> id,
      required int routeId,
      required int shiftId,
      Value<int> sequenceNumber,
      Value<String> status,
      Value<String?> customerName,
      required String addressText,
      Value<double?> distanceKm,
      Value<String?> orderNumber,
      Value<int?> orderValueCents,
      Value<String?> ocrRawText,
      Value<String?> completedAt,
      required String createdAt,
      Value<bool> needsIfoodConfirmation,
      Value<String?> deliveryIdentifier,
      Value<String?> partnerCollectionCode,
      Value<bool?> ifoodConfirmationSuccess,
      Value<String?> ifoodConfirmedAt,
      Value<bool> hasDrinks,
      Value<bool> needsCard,
      Value<bool> needsChange,
      Value<int?> changeAmountCents,
      Value<String?> pizzaNumber,
      Value<String?> houseNumber,
    });
typedef $$DeliveriesTableTableUpdateCompanionBuilder =
    DeliveriesTableCompanion Function({
      Value<int> id,
      Value<int> routeId,
      Value<int> shiftId,
      Value<int> sequenceNumber,
      Value<String> status,
      Value<String?> customerName,
      Value<String> addressText,
      Value<double?> distanceKm,
      Value<String?> orderNumber,
      Value<int?> orderValueCents,
      Value<String?> ocrRawText,
      Value<String?> completedAt,
      Value<String> createdAt,
      Value<bool> needsIfoodConfirmation,
      Value<String?> deliveryIdentifier,
      Value<String?> partnerCollectionCode,
      Value<bool?> ifoodConfirmationSuccess,
      Value<String?> ifoodConfirmedAt,
      Value<bool> hasDrinks,
      Value<bool> needsCard,
      Value<bool> needsChange,
      Value<int?> changeAmountCents,
      Value<String?> pizzaNumber,
      Value<String?> houseNumber,
    });

final class $$DeliveriesTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $DeliveriesTableTable,
          DeliveriesTableData
        > {
  $$DeliveriesTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $RoutesTableTable _routeIdTable(_$AppDatabase db) =>
      db.routesTable.createAlias(
        $_aliasNameGenerator(db.deliveriesTable.routeId, db.routesTable.id),
      );

  $$RoutesTableTableProcessedTableManager get routeId {
    final $_column = $_itemColumn<int>('route_id')!;

    final manager = $$RoutesTableTableTableManager(
      $_db,
      $_db.routesTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_routeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ShiftsTableTable _shiftIdTable(_$AppDatabase db) =>
      db.shiftsTable.createAlias(
        $_aliasNameGenerator(db.deliveriesTable.shiftId, db.shiftsTable.id),
      );

  $$ShiftsTableTableProcessedTableManager get shiftId {
    final $_column = $_itemColumn<int>('shift_id')!;

    final manager = $$ShiftsTableTableTableManager(
      $_db,
      $_db.shiftsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_shiftIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ReceiptsTableTable, List<ReceiptsTableData>>
  _receiptsTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.receiptsTable,
    aliasName: $_aliasNameGenerator(
      db.deliveriesTable.id,
      db.receiptsTable.deliveryId,
    ),
  );

  $$ReceiptsTableTableProcessedTableManager get receiptsTableRefs {
    final manager = $$ReceiptsTableTableTableManager(
      $_db,
      $_db.receiptsTable,
    ).filter((f) => f.deliveryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_receiptsTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DeliveriesTableTableFilterComposer
    extends Composer<_$AppDatabase, $DeliveriesTableTable> {
  $$DeliveriesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sequenceNumber => $composableBuilder(
    column: $table.sequenceNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get addressText => $composableBuilder(
    column: $table.addressText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get distanceKm => $composableBuilder(
    column: $table.distanceKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get orderNumber => $composableBuilder(
    column: $table.orderNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orderValueCents => $composableBuilder(
    column: $table.orderValueCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ocrRawText => $composableBuilder(
    column: $table.ocrRawText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get needsIfoodConfirmation => $composableBuilder(
    column: $table.needsIfoodConfirmation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deliveryIdentifier => $composableBuilder(
    column: $table.deliveryIdentifier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get partnerCollectionCode => $composableBuilder(
    column: $table.partnerCollectionCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get ifoodConfirmationSuccess => $composableBuilder(
    column: $table.ifoodConfirmationSuccess,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ifoodConfirmedAt => $composableBuilder(
    column: $table.ifoodConfirmedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasDrinks => $composableBuilder(
    column: $table.hasDrinks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get needsCard => $composableBuilder(
    column: $table.needsCard,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get needsChange => $composableBuilder(
    column: $table.needsChange,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get changeAmountCents => $composableBuilder(
    column: $table.changeAmountCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pizzaNumber => $composableBuilder(
    column: $table.pizzaNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get houseNumber => $composableBuilder(
    column: $table.houseNumber,
    builder: (column) => ColumnFilters(column),
  );

  $$RoutesTableTableFilterComposer get routeId {
    final $$RoutesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routeId,
      referencedTable: $db.routesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutesTableTableFilterComposer(
            $db: $db,
            $table: $db.routesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ShiftsTableTableFilterComposer get shiftId {
    final $$ShiftsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shiftId,
      referencedTable: $db.shiftsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShiftsTableTableFilterComposer(
            $db: $db,
            $table: $db.shiftsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> receiptsTableRefs(
    Expression<bool> Function($$ReceiptsTableTableFilterComposer f) f,
  ) {
    final $$ReceiptsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.receiptsTable,
      getReferencedColumn: (t) => t.deliveryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReceiptsTableTableFilterComposer(
            $db: $db,
            $table: $db.receiptsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DeliveriesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $DeliveriesTableTable> {
  $$DeliveriesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sequenceNumber => $composableBuilder(
    column: $table.sequenceNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get addressText => $composableBuilder(
    column: $table.addressText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get distanceKm => $composableBuilder(
    column: $table.distanceKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get orderNumber => $composableBuilder(
    column: $table.orderNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orderValueCents => $composableBuilder(
    column: $table.orderValueCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ocrRawText => $composableBuilder(
    column: $table.ocrRawText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get needsIfoodConfirmation => $composableBuilder(
    column: $table.needsIfoodConfirmation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deliveryIdentifier => $composableBuilder(
    column: $table.deliveryIdentifier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partnerCollectionCode => $composableBuilder(
    column: $table.partnerCollectionCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get ifoodConfirmationSuccess => $composableBuilder(
    column: $table.ifoodConfirmationSuccess,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ifoodConfirmedAt => $composableBuilder(
    column: $table.ifoodConfirmedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasDrinks => $composableBuilder(
    column: $table.hasDrinks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get needsCard => $composableBuilder(
    column: $table.needsCard,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get needsChange => $composableBuilder(
    column: $table.needsChange,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get changeAmountCents => $composableBuilder(
    column: $table.changeAmountCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pizzaNumber => $composableBuilder(
    column: $table.pizzaNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get houseNumber => $composableBuilder(
    column: $table.houseNumber,
    builder: (column) => ColumnOrderings(column),
  );

  $$RoutesTableTableOrderingComposer get routeId {
    final $$RoutesTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routeId,
      referencedTable: $db.routesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutesTableTableOrderingComposer(
            $db: $db,
            $table: $db.routesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ShiftsTableTableOrderingComposer get shiftId {
    final $$ShiftsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shiftId,
      referencedTable: $db.shiftsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShiftsTableTableOrderingComposer(
            $db: $db,
            $table: $db.shiftsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DeliveriesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $DeliveriesTableTable> {
  $$DeliveriesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sequenceNumber => $composableBuilder(
    column: $table.sequenceNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get addressText => $composableBuilder(
    column: $table.addressText,
    builder: (column) => column,
  );

  GeneratedColumn<double> get distanceKm => $composableBuilder(
    column: $table.distanceKm,
    builder: (column) => column,
  );

  GeneratedColumn<String> get orderNumber => $composableBuilder(
    column: $table.orderNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get orderValueCents => $composableBuilder(
    column: $table.orderValueCents,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ocrRawText => $composableBuilder(
    column: $table.ocrRawText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get needsIfoodConfirmation => $composableBuilder(
    column: $table.needsIfoodConfirmation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deliveryIdentifier => $composableBuilder(
    column: $table.deliveryIdentifier,
    builder: (column) => column,
  );

  GeneratedColumn<String> get partnerCollectionCode => $composableBuilder(
    column: $table.partnerCollectionCode,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get ifoodConfirmationSuccess => $composableBuilder(
    column: $table.ifoodConfirmationSuccess,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ifoodConfirmedAt => $composableBuilder(
    column: $table.ifoodConfirmedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hasDrinks =>
      $composableBuilder(column: $table.hasDrinks, builder: (column) => column);

  GeneratedColumn<bool> get needsCard =>
      $composableBuilder(column: $table.needsCard, builder: (column) => column);

  GeneratedColumn<bool> get needsChange => $composableBuilder(
    column: $table.needsChange,
    builder: (column) => column,
  );

  GeneratedColumn<int> get changeAmountCents => $composableBuilder(
    column: $table.changeAmountCents,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pizzaNumber => $composableBuilder(
    column: $table.pizzaNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get houseNumber => $composableBuilder(
    column: $table.houseNumber,
    builder: (column) => column,
  );

  $$RoutesTableTableAnnotationComposer get routeId {
    final $$RoutesTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routeId,
      referencedTable: $db.routesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutesTableTableAnnotationComposer(
            $db: $db,
            $table: $db.routesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ShiftsTableTableAnnotationComposer get shiftId {
    final $$ShiftsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shiftId,
      referencedTable: $db.shiftsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShiftsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.shiftsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> receiptsTableRefs<T extends Object>(
    Expression<T> Function($$ReceiptsTableTableAnnotationComposer a) f,
  ) {
    final $$ReceiptsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.receiptsTable,
      getReferencedColumn: (t) => t.deliveryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReceiptsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.receiptsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DeliveriesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DeliveriesTableTable,
          DeliveriesTableData,
          $$DeliveriesTableTableFilterComposer,
          $$DeliveriesTableTableOrderingComposer,
          $$DeliveriesTableTableAnnotationComposer,
          $$DeliveriesTableTableCreateCompanionBuilder,
          $$DeliveriesTableTableUpdateCompanionBuilder,
          (DeliveriesTableData, $$DeliveriesTableTableReferences),
          DeliveriesTableData,
          PrefetchHooks Function({
            bool routeId,
            bool shiftId,
            bool receiptsTableRefs,
          })
        > {
  $$DeliveriesTableTableTableManager(
    _$AppDatabase db,
    $DeliveriesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DeliveriesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DeliveriesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DeliveriesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> routeId = const Value.absent(),
                Value<int> shiftId = const Value.absent(),
                Value<int> sequenceNumber = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> customerName = const Value.absent(),
                Value<String> addressText = const Value.absent(),
                Value<double?> distanceKm = const Value.absent(),
                Value<String?> orderNumber = const Value.absent(),
                Value<int?> orderValueCents = const Value.absent(),
                Value<String?> ocrRawText = const Value.absent(),
                Value<String?> completedAt = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<bool> needsIfoodConfirmation = const Value.absent(),
                Value<String?> deliveryIdentifier = const Value.absent(),
                Value<String?> partnerCollectionCode = const Value.absent(),
                Value<bool?> ifoodConfirmationSuccess = const Value.absent(),
                Value<String?> ifoodConfirmedAt = const Value.absent(),
                Value<bool> hasDrinks = const Value.absent(),
                Value<bool> needsCard = const Value.absent(),
                Value<bool> needsChange = const Value.absent(),
                Value<int?> changeAmountCents = const Value.absent(),
                Value<String?> pizzaNumber = const Value.absent(),
                Value<String?> houseNumber = const Value.absent(),
              }) => DeliveriesTableCompanion(
                id: id,
                routeId: routeId,
                shiftId: shiftId,
                sequenceNumber: sequenceNumber,
                status: status,
                customerName: customerName,
                addressText: addressText,
                distanceKm: distanceKm,
                orderNumber: orderNumber,
                orderValueCents: orderValueCents,
                ocrRawText: ocrRawText,
                completedAt: completedAt,
                createdAt: createdAt,
                needsIfoodConfirmation: needsIfoodConfirmation,
                deliveryIdentifier: deliveryIdentifier,
                partnerCollectionCode: partnerCollectionCode,
                ifoodConfirmationSuccess: ifoodConfirmationSuccess,
                ifoodConfirmedAt: ifoodConfirmedAt,
                hasDrinks: hasDrinks,
                needsCard: needsCard,
                needsChange: needsChange,
                changeAmountCents: changeAmountCents,
                pizzaNumber: pizzaNumber,
                houseNumber: houseNumber,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int routeId,
                required int shiftId,
                Value<int> sequenceNumber = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> customerName = const Value.absent(),
                required String addressText,
                Value<double?> distanceKm = const Value.absent(),
                Value<String?> orderNumber = const Value.absent(),
                Value<int?> orderValueCents = const Value.absent(),
                Value<String?> ocrRawText = const Value.absent(),
                Value<String?> completedAt = const Value.absent(),
                required String createdAt,
                Value<bool> needsIfoodConfirmation = const Value.absent(),
                Value<String?> deliveryIdentifier = const Value.absent(),
                Value<String?> partnerCollectionCode = const Value.absent(),
                Value<bool?> ifoodConfirmationSuccess = const Value.absent(),
                Value<String?> ifoodConfirmedAt = const Value.absent(),
                Value<bool> hasDrinks = const Value.absent(),
                Value<bool> needsCard = const Value.absent(),
                Value<bool> needsChange = const Value.absent(),
                Value<int?> changeAmountCents = const Value.absent(),
                Value<String?> pizzaNumber = const Value.absent(),
                Value<String?> houseNumber = const Value.absent(),
              }) => DeliveriesTableCompanion.insert(
                id: id,
                routeId: routeId,
                shiftId: shiftId,
                sequenceNumber: sequenceNumber,
                status: status,
                customerName: customerName,
                addressText: addressText,
                distanceKm: distanceKm,
                orderNumber: orderNumber,
                orderValueCents: orderValueCents,
                ocrRawText: ocrRawText,
                completedAt: completedAt,
                createdAt: createdAt,
                needsIfoodConfirmation: needsIfoodConfirmation,
                deliveryIdentifier: deliveryIdentifier,
                partnerCollectionCode: partnerCollectionCode,
                ifoodConfirmationSuccess: ifoodConfirmationSuccess,
                ifoodConfirmedAt: ifoodConfirmedAt,
                hasDrinks: hasDrinks,
                needsCard: needsCard,
                needsChange: needsChange,
                changeAmountCents: changeAmountCents,
                pizzaNumber: pizzaNumber,
                houseNumber: houseNumber,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DeliveriesTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({routeId = false, shiftId = false, receiptsTableRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (receiptsTableRefs) db.receiptsTable,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (routeId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.routeId,
                                    referencedTable:
                                        $$DeliveriesTableTableReferences
                                            ._routeIdTable(db),
                                    referencedColumn:
                                        $$DeliveriesTableTableReferences
                                            ._routeIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (shiftId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.shiftId,
                                    referencedTable:
                                        $$DeliveriesTableTableReferences
                                            ._shiftIdTable(db),
                                    referencedColumn:
                                        $$DeliveriesTableTableReferences
                                            ._shiftIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (receiptsTableRefs)
                        await $_getPrefetchedData<
                          DeliveriesTableData,
                          $DeliveriesTableTable,
                          ReceiptsTableData
                        >(
                          currentTable: table,
                          referencedTable: $$DeliveriesTableTableReferences
                              ._receiptsTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DeliveriesTableTableReferences(
                                db,
                                table,
                                p0,
                              ).receiptsTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.deliveryId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$DeliveriesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DeliveriesTableTable,
      DeliveriesTableData,
      $$DeliveriesTableTableFilterComposer,
      $$DeliveriesTableTableOrderingComposer,
      $$DeliveriesTableTableAnnotationComposer,
      $$DeliveriesTableTableCreateCompanionBuilder,
      $$DeliveriesTableTableUpdateCompanionBuilder,
      (DeliveriesTableData, $$DeliveriesTableTableReferences),
      DeliveriesTableData,
      PrefetchHooks Function({
        bool routeId,
        bool shiftId,
        bool receiptsTableRefs,
      })
    >;
typedef $$ReceiptsTableTableCreateCompanionBuilder =
    ReceiptsTableCompanion Function({
      Value<int> id,
      required int deliveryId,
      required String imagePath,
      Value<String?> ocrRawText,
      Value<String?> ocrConfidenceJson,
      required String captureAttemptedAt,
      Value<bool> wasRetaken,
      required String createdAt,
    });
typedef $$ReceiptsTableTableUpdateCompanionBuilder =
    ReceiptsTableCompanion Function({
      Value<int> id,
      Value<int> deliveryId,
      Value<String> imagePath,
      Value<String?> ocrRawText,
      Value<String?> ocrConfidenceJson,
      Value<String> captureAttemptedAt,
      Value<bool> wasRetaken,
      Value<String> createdAt,
    });

final class $$ReceiptsTableTableReferences
    extends
        BaseReferences<_$AppDatabase, $ReceiptsTableTable, ReceiptsTableData> {
  $$ReceiptsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DeliveriesTableTable _deliveryIdTable(_$AppDatabase db) =>
      db.deliveriesTable.createAlias(
        $_aliasNameGenerator(
          db.receiptsTable.deliveryId,
          db.deliveriesTable.id,
        ),
      );

  $$DeliveriesTableTableProcessedTableManager get deliveryId {
    final $_column = $_itemColumn<int>('delivery_id')!;

    final manager = $$DeliveriesTableTableTableManager(
      $_db,
      $_db.deliveriesTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_deliveryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ReceiptsTableTableFilterComposer
    extends Composer<_$AppDatabase, $ReceiptsTableTable> {
  $$ReceiptsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ocrRawText => $composableBuilder(
    column: $table.ocrRawText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ocrConfidenceJson => $composableBuilder(
    column: $table.ocrConfidenceJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get captureAttemptedAt => $composableBuilder(
    column: $table.captureAttemptedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get wasRetaken => $composableBuilder(
    column: $table.wasRetaken,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$DeliveriesTableTableFilterComposer get deliveryId {
    final $$DeliveriesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deliveryId,
      referencedTable: $db.deliveriesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DeliveriesTableTableFilterComposer(
            $db: $db,
            $table: $db.deliveriesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReceiptsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ReceiptsTableTable> {
  $$ReceiptsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ocrRawText => $composableBuilder(
    column: $table.ocrRawText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ocrConfidenceJson => $composableBuilder(
    column: $table.ocrConfidenceJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get captureAttemptedAt => $composableBuilder(
    column: $table.captureAttemptedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get wasRetaken => $composableBuilder(
    column: $table.wasRetaken,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$DeliveriesTableTableOrderingComposer get deliveryId {
    final $$DeliveriesTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deliveryId,
      referencedTable: $db.deliveriesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DeliveriesTableTableOrderingComposer(
            $db: $db,
            $table: $db.deliveriesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReceiptsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReceiptsTableTable> {
  $$ReceiptsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<String> get ocrRawText => $composableBuilder(
    column: $table.ocrRawText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ocrConfidenceJson => $composableBuilder(
    column: $table.ocrConfidenceJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get captureAttemptedAt => $composableBuilder(
    column: $table.captureAttemptedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get wasRetaken => $composableBuilder(
    column: $table.wasRetaken,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$DeliveriesTableTableAnnotationComposer get deliveryId {
    final $$DeliveriesTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deliveryId,
      referencedTable: $db.deliveriesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DeliveriesTableTableAnnotationComposer(
            $db: $db,
            $table: $db.deliveriesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReceiptsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReceiptsTableTable,
          ReceiptsTableData,
          $$ReceiptsTableTableFilterComposer,
          $$ReceiptsTableTableOrderingComposer,
          $$ReceiptsTableTableAnnotationComposer,
          $$ReceiptsTableTableCreateCompanionBuilder,
          $$ReceiptsTableTableUpdateCompanionBuilder,
          (ReceiptsTableData, $$ReceiptsTableTableReferences),
          ReceiptsTableData,
          PrefetchHooks Function({bool deliveryId})
        > {
  $$ReceiptsTableTableTableManager(_$AppDatabase db, $ReceiptsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReceiptsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReceiptsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReceiptsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> deliveryId = const Value.absent(),
                Value<String> imagePath = const Value.absent(),
                Value<String?> ocrRawText = const Value.absent(),
                Value<String?> ocrConfidenceJson = const Value.absent(),
                Value<String> captureAttemptedAt = const Value.absent(),
                Value<bool> wasRetaken = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
              }) => ReceiptsTableCompanion(
                id: id,
                deliveryId: deliveryId,
                imagePath: imagePath,
                ocrRawText: ocrRawText,
                ocrConfidenceJson: ocrConfidenceJson,
                captureAttemptedAt: captureAttemptedAt,
                wasRetaken: wasRetaken,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int deliveryId,
                required String imagePath,
                Value<String?> ocrRawText = const Value.absent(),
                Value<String?> ocrConfidenceJson = const Value.absent(),
                required String captureAttemptedAt,
                Value<bool> wasRetaken = const Value.absent(),
                required String createdAt,
              }) => ReceiptsTableCompanion.insert(
                id: id,
                deliveryId: deliveryId,
                imagePath: imagePath,
                ocrRawText: ocrRawText,
                ocrConfidenceJson: ocrConfidenceJson,
                captureAttemptedAt: captureAttemptedAt,
                wasRetaken: wasRetaken,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ReceiptsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({deliveryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (deliveryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.deliveryId,
                                referencedTable: $$ReceiptsTableTableReferences
                                    ._deliveryIdTable(db),
                                referencedColumn: $$ReceiptsTableTableReferences
                                    ._deliveryIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ReceiptsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReceiptsTableTable,
      ReceiptsTableData,
      $$ReceiptsTableTableFilterComposer,
      $$ReceiptsTableTableOrderingComposer,
      $$ReceiptsTableTableAnnotationComposer,
      $$ReceiptsTableTableCreateCompanionBuilder,
      $$ReceiptsTableTableUpdateCompanionBuilder,
      (ReceiptsTableData, $$ReceiptsTableTableReferences),
      ReceiptsTableData,
      PrefetchHooks Function({bool deliveryId})
    >;
typedef $$EarningsEntriesTableTableCreateCompanionBuilder =
    EarningsEntriesTableCompanion Function({
      Value<int> id,
      required int routeId,
      required int shiftId,
      required String earningsType,
      required int rateAppliedCents,
      required int routeDeliveryCount,
      Value<double?> routeDistanceKm,
      required String classificationReason,
      required String configSnapshot,
      required String createdAt,
    });
typedef $$EarningsEntriesTableTableUpdateCompanionBuilder =
    EarningsEntriesTableCompanion Function({
      Value<int> id,
      Value<int> routeId,
      Value<int> shiftId,
      Value<String> earningsType,
      Value<int> rateAppliedCents,
      Value<int> routeDeliveryCount,
      Value<double?> routeDistanceKm,
      Value<String> classificationReason,
      Value<String> configSnapshot,
      Value<String> createdAt,
    });

final class $$EarningsEntriesTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $EarningsEntriesTableTable,
          EarningsEntriesTableData
        > {
  $$EarningsEntriesTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $RoutesTableTable _routeIdTable(_$AppDatabase db) =>
      db.routesTable.createAlias(
        $_aliasNameGenerator(
          db.earningsEntriesTable.routeId,
          db.routesTable.id,
        ),
      );

  $$RoutesTableTableProcessedTableManager get routeId {
    final $_column = $_itemColumn<int>('route_id')!;

    final manager = $$RoutesTableTableTableManager(
      $_db,
      $_db.routesTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_routeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ShiftsTableTable _shiftIdTable(_$AppDatabase db) =>
      db.shiftsTable.createAlias(
        $_aliasNameGenerator(
          db.earningsEntriesTable.shiftId,
          db.shiftsTable.id,
        ),
      );

  $$ShiftsTableTableProcessedTableManager get shiftId {
    final $_column = $_itemColumn<int>('shift_id')!;

    final manager = $$ShiftsTableTableTableManager(
      $_db,
      $_db.shiftsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_shiftIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EarningsEntriesTableTableFilterComposer
    extends Composer<_$AppDatabase, $EarningsEntriesTableTable> {
  $$EarningsEntriesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get earningsType => $composableBuilder(
    column: $table.earningsType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rateAppliedCents => $composableBuilder(
    column: $table.rateAppliedCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get routeDeliveryCount => $composableBuilder(
    column: $table.routeDeliveryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get routeDistanceKm => $composableBuilder(
    column: $table.routeDistanceKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get classificationReason => $composableBuilder(
    column: $table.classificationReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get configSnapshot => $composableBuilder(
    column: $table.configSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$RoutesTableTableFilterComposer get routeId {
    final $$RoutesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routeId,
      referencedTable: $db.routesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutesTableTableFilterComposer(
            $db: $db,
            $table: $db.routesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ShiftsTableTableFilterComposer get shiftId {
    final $$ShiftsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shiftId,
      referencedTable: $db.shiftsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShiftsTableTableFilterComposer(
            $db: $db,
            $table: $db.shiftsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EarningsEntriesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $EarningsEntriesTableTable> {
  $$EarningsEntriesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get earningsType => $composableBuilder(
    column: $table.earningsType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rateAppliedCents => $composableBuilder(
    column: $table.rateAppliedCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get routeDeliveryCount => $composableBuilder(
    column: $table.routeDeliveryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get routeDistanceKm => $composableBuilder(
    column: $table.routeDistanceKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get classificationReason => $composableBuilder(
    column: $table.classificationReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get configSnapshot => $composableBuilder(
    column: $table.configSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$RoutesTableTableOrderingComposer get routeId {
    final $$RoutesTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routeId,
      referencedTable: $db.routesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutesTableTableOrderingComposer(
            $db: $db,
            $table: $db.routesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ShiftsTableTableOrderingComposer get shiftId {
    final $$ShiftsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shiftId,
      referencedTable: $db.shiftsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShiftsTableTableOrderingComposer(
            $db: $db,
            $table: $db.shiftsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EarningsEntriesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $EarningsEntriesTableTable> {
  $$EarningsEntriesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get earningsType => $composableBuilder(
    column: $table.earningsType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rateAppliedCents => $composableBuilder(
    column: $table.rateAppliedCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get routeDeliveryCount => $composableBuilder(
    column: $table.routeDeliveryCount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get routeDistanceKm => $composableBuilder(
    column: $table.routeDistanceKm,
    builder: (column) => column,
  );

  GeneratedColumn<String> get classificationReason => $composableBuilder(
    column: $table.classificationReason,
    builder: (column) => column,
  );

  GeneratedColumn<String> get configSnapshot => $composableBuilder(
    column: $table.configSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$RoutesTableTableAnnotationComposer get routeId {
    final $$RoutesTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routeId,
      referencedTable: $db.routesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutesTableTableAnnotationComposer(
            $db: $db,
            $table: $db.routesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ShiftsTableTableAnnotationComposer get shiftId {
    final $$ShiftsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shiftId,
      referencedTable: $db.shiftsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShiftsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.shiftsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EarningsEntriesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EarningsEntriesTableTable,
          EarningsEntriesTableData,
          $$EarningsEntriesTableTableFilterComposer,
          $$EarningsEntriesTableTableOrderingComposer,
          $$EarningsEntriesTableTableAnnotationComposer,
          $$EarningsEntriesTableTableCreateCompanionBuilder,
          $$EarningsEntriesTableTableUpdateCompanionBuilder,
          (EarningsEntriesTableData, $$EarningsEntriesTableTableReferences),
          EarningsEntriesTableData,
          PrefetchHooks Function({bool routeId, bool shiftId})
        > {
  $$EarningsEntriesTableTableTableManager(
    _$AppDatabase db,
    $EarningsEntriesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EarningsEntriesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EarningsEntriesTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$EarningsEntriesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> routeId = const Value.absent(),
                Value<int> shiftId = const Value.absent(),
                Value<String> earningsType = const Value.absent(),
                Value<int> rateAppliedCents = const Value.absent(),
                Value<int> routeDeliveryCount = const Value.absent(),
                Value<double?> routeDistanceKm = const Value.absent(),
                Value<String> classificationReason = const Value.absent(),
                Value<String> configSnapshot = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
              }) => EarningsEntriesTableCompanion(
                id: id,
                routeId: routeId,
                shiftId: shiftId,
                earningsType: earningsType,
                rateAppliedCents: rateAppliedCents,
                routeDeliveryCount: routeDeliveryCount,
                routeDistanceKm: routeDistanceKm,
                classificationReason: classificationReason,
                configSnapshot: configSnapshot,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int routeId,
                required int shiftId,
                required String earningsType,
                required int rateAppliedCents,
                required int routeDeliveryCount,
                Value<double?> routeDistanceKm = const Value.absent(),
                required String classificationReason,
                required String configSnapshot,
                required String createdAt,
              }) => EarningsEntriesTableCompanion.insert(
                id: id,
                routeId: routeId,
                shiftId: shiftId,
                earningsType: earningsType,
                rateAppliedCents: rateAppliedCents,
                routeDeliveryCount: routeDeliveryCount,
                routeDistanceKm: routeDistanceKm,
                classificationReason: classificationReason,
                configSnapshot: configSnapshot,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EarningsEntriesTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({routeId = false, shiftId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (routeId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.routeId,
                                referencedTable:
                                    $$EarningsEntriesTableTableReferences
                                        ._routeIdTable(db),
                                referencedColumn:
                                    $$EarningsEntriesTableTableReferences
                                        ._routeIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (shiftId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.shiftId,
                                referencedTable:
                                    $$EarningsEntriesTableTableReferences
                                        ._shiftIdTable(db),
                                referencedColumn:
                                    $$EarningsEntriesTableTableReferences
                                        ._shiftIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$EarningsEntriesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EarningsEntriesTableTable,
      EarningsEntriesTableData,
      $$EarningsEntriesTableTableFilterComposer,
      $$EarningsEntriesTableTableOrderingComposer,
      $$EarningsEntriesTableTableAnnotationComposer,
      $$EarningsEntriesTableTableCreateCompanionBuilder,
      $$EarningsEntriesTableTableUpdateCompanionBuilder,
      (EarningsEntriesTableData, $$EarningsEntriesTableTableReferences),
      EarningsEntriesTableData,
      PrefetchHooks Function({bool routeId, bool shiftId})
    >;
typedef $$EarningsConfigTableTableCreateCompanionBuilder =
    EarningsConfigTableCompanion Function({
      Value<int> id,
      Value<int> baseRateCents,
      Value<int> longSingleDeliveryRateCents,
      required String effectiveFrom,
      Value<bool> isCurrent,
      required String createdAt,
    });
typedef $$EarningsConfigTableTableUpdateCompanionBuilder =
    EarningsConfigTableCompanion Function({
      Value<int> id,
      Value<int> baseRateCents,
      Value<int> longSingleDeliveryRateCents,
      Value<String> effectiveFrom,
      Value<bool> isCurrent,
      Value<String> createdAt,
    });

class $$EarningsConfigTableTableFilterComposer
    extends Composer<_$AppDatabase, $EarningsConfigTableTable> {
  $$EarningsConfigTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get baseRateCents => $composableBuilder(
    column: $table.baseRateCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get longSingleDeliveryRateCents => $composableBuilder(
    column: $table.longSingleDeliveryRateCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get effectiveFrom => $composableBuilder(
    column: $table.effectiveFrom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCurrent => $composableBuilder(
    column: $table.isCurrent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EarningsConfigTableTableOrderingComposer
    extends Composer<_$AppDatabase, $EarningsConfigTableTable> {
  $$EarningsConfigTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get baseRateCents => $composableBuilder(
    column: $table.baseRateCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get longSingleDeliveryRateCents => $composableBuilder(
    column: $table.longSingleDeliveryRateCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get effectiveFrom => $composableBuilder(
    column: $table.effectiveFrom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCurrent => $composableBuilder(
    column: $table.isCurrent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EarningsConfigTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $EarningsConfigTableTable> {
  $$EarningsConfigTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get baseRateCents => $composableBuilder(
    column: $table.baseRateCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get longSingleDeliveryRateCents => $composableBuilder(
    column: $table.longSingleDeliveryRateCents,
    builder: (column) => column,
  );

  GeneratedColumn<String> get effectiveFrom => $composableBuilder(
    column: $table.effectiveFrom,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCurrent =>
      $composableBuilder(column: $table.isCurrent, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$EarningsConfigTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EarningsConfigTableTable,
          EarningsConfigTableData,
          $$EarningsConfigTableTableFilterComposer,
          $$EarningsConfigTableTableOrderingComposer,
          $$EarningsConfigTableTableAnnotationComposer,
          $$EarningsConfigTableTableCreateCompanionBuilder,
          $$EarningsConfigTableTableUpdateCompanionBuilder,
          (
            EarningsConfigTableData,
            BaseReferences<
              _$AppDatabase,
              $EarningsConfigTableTable,
              EarningsConfigTableData
            >,
          ),
          EarningsConfigTableData,
          PrefetchHooks Function()
        > {
  $$EarningsConfigTableTableTableManager(
    _$AppDatabase db,
    $EarningsConfigTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EarningsConfigTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EarningsConfigTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$EarningsConfigTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> baseRateCents = const Value.absent(),
                Value<int> longSingleDeliveryRateCents = const Value.absent(),
                Value<String> effectiveFrom = const Value.absent(),
                Value<bool> isCurrent = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
              }) => EarningsConfigTableCompanion(
                id: id,
                baseRateCents: baseRateCents,
                longSingleDeliveryRateCents: longSingleDeliveryRateCents,
                effectiveFrom: effectiveFrom,
                isCurrent: isCurrent,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> baseRateCents = const Value.absent(),
                Value<int> longSingleDeliveryRateCents = const Value.absent(),
                required String effectiveFrom,
                Value<bool> isCurrent = const Value.absent(),
                required String createdAt,
              }) => EarningsConfigTableCompanion.insert(
                id: id,
                baseRateCents: baseRateCents,
                longSingleDeliveryRateCents: longSingleDeliveryRateCents,
                effectiveFrom: effectiveFrom,
                isCurrent: isCurrent,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EarningsConfigTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EarningsConfigTableTable,
      EarningsConfigTableData,
      $$EarningsConfigTableTableFilterComposer,
      $$EarningsConfigTableTableOrderingComposer,
      $$EarningsConfigTableTableAnnotationComposer,
      $$EarningsConfigTableTableCreateCompanionBuilder,
      $$EarningsConfigTableTableUpdateCompanionBuilder,
      (
        EarningsConfigTableData,
        BaseReferences<
          _$AppDatabase,
          $EarningsConfigTableTable,
          EarningsConfigTableData
        >,
      ),
      EarningsConfigTableData,
      PrefetchHooks Function()
    >;
typedef $$AppConfigTableTableCreateCompanionBuilder =
    AppConfigTableCompanion Function({
      Value<int> id,
      Value<String> driverName,
      Value<String> pizzeriaAddress,
      Value<String> ifoodUrl,
      Value<String> ifoodFieldSelector,
      Value<bool> ocrContrastEnabled,
      Value<int?> activeRouteId,
      Value<int?> activeDeliveryIndex,
      Value<int> dailyGoalCents,
      Value<String> homeAddress,
      required String createdAt,
      required String updatedAt,
    });
typedef $$AppConfigTableTableUpdateCompanionBuilder =
    AppConfigTableCompanion Function({
      Value<int> id,
      Value<String> driverName,
      Value<String> pizzeriaAddress,
      Value<String> ifoodUrl,
      Value<String> ifoodFieldSelector,
      Value<bool> ocrContrastEnabled,
      Value<int?> activeRouteId,
      Value<int?> activeDeliveryIndex,
      Value<int> dailyGoalCents,
      Value<String> homeAddress,
      Value<String> createdAt,
      Value<String> updatedAt,
    });

class $$AppConfigTableTableFilterComposer
    extends Composer<_$AppDatabase, $AppConfigTableTable> {
  $$AppConfigTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get driverName => $composableBuilder(
    column: $table.driverName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pizzeriaAddress => $composableBuilder(
    column: $table.pizzeriaAddress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ifoodUrl => $composableBuilder(
    column: $table.ifoodUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ifoodFieldSelector => $composableBuilder(
    column: $table.ifoodFieldSelector,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get ocrContrastEnabled => $composableBuilder(
    column: $table.ocrContrastEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get activeRouteId => $composableBuilder(
    column: $table.activeRouteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get activeDeliveryIndex => $composableBuilder(
    column: $table.activeDeliveryIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dailyGoalCents => $composableBuilder(
    column: $table.dailyGoalCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get homeAddress => $composableBuilder(
    column: $table.homeAddress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppConfigTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AppConfigTableTable> {
  $$AppConfigTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get driverName => $composableBuilder(
    column: $table.driverName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pizzeriaAddress => $composableBuilder(
    column: $table.pizzeriaAddress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ifoodUrl => $composableBuilder(
    column: $table.ifoodUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ifoodFieldSelector => $composableBuilder(
    column: $table.ifoodFieldSelector,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get ocrContrastEnabled => $composableBuilder(
    column: $table.ocrContrastEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get activeRouteId => $composableBuilder(
    column: $table.activeRouteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get activeDeliveryIndex => $composableBuilder(
    column: $table.activeDeliveryIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dailyGoalCents => $composableBuilder(
    column: $table.dailyGoalCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get homeAddress => $composableBuilder(
    column: $table.homeAddress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppConfigTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppConfigTableTable> {
  $$AppConfigTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get driverName => $composableBuilder(
    column: $table.driverName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pizzeriaAddress => $composableBuilder(
    column: $table.pizzeriaAddress,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ifoodUrl =>
      $composableBuilder(column: $table.ifoodUrl, builder: (column) => column);

  GeneratedColumn<String> get ifoodFieldSelector => $composableBuilder(
    column: $table.ifoodFieldSelector,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get ocrContrastEnabled => $composableBuilder(
    column: $table.ocrContrastEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<int> get activeRouteId => $composableBuilder(
    column: $table.activeRouteId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get activeDeliveryIndex => $composableBuilder(
    column: $table.activeDeliveryIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dailyGoalCents => $composableBuilder(
    column: $table.dailyGoalCents,
    builder: (column) => column,
  );

  GeneratedColumn<String> get homeAddress => $composableBuilder(
    column: $table.homeAddress,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppConfigTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppConfigTableTable,
          AppConfigTableData,
          $$AppConfigTableTableFilterComposer,
          $$AppConfigTableTableOrderingComposer,
          $$AppConfigTableTableAnnotationComposer,
          $$AppConfigTableTableCreateCompanionBuilder,
          $$AppConfigTableTableUpdateCompanionBuilder,
          (
            AppConfigTableData,
            BaseReferences<
              _$AppDatabase,
              $AppConfigTableTable,
              AppConfigTableData
            >,
          ),
          AppConfigTableData,
          PrefetchHooks Function()
        > {
  $$AppConfigTableTableTableManager(
    _$AppDatabase db,
    $AppConfigTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppConfigTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppConfigTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppConfigTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> driverName = const Value.absent(),
                Value<String> pizzeriaAddress = const Value.absent(),
                Value<String> ifoodUrl = const Value.absent(),
                Value<String> ifoodFieldSelector = const Value.absent(),
                Value<bool> ocrContrastEnabled = const Value.absent(),
                Value<int?> activeRouteId = const Value.absent(),
                Value<int?> activeDeliveryIndex = const Value.absent(),
                Value<int> dailyGoalCents = const Value.absent(),
                Value<String> homeAddress = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
              }) => AppConfigTableCompanion(
                id: id,
                driverName: driverName,
                pizzeriaAddress: pizzeriaAddress,
                ifoodUrl: ifoodUrl,
                ifoodFieldSelector: ifoodFieldSelector,
                ocrContrastEnabled: ocrContrastEnabled,
                activeRouteId: activeRouteId,
                activeDeliveryIndex: activeDeliveryIndex,
                dailyGoalCents: dailyGoalCents,
                homeAddress: homeAddress,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> driverName = const Value.absent(),
                Value<String> pizzeriaAddress = const Value.absent(),
                Value<String> ifoodUrl = const Value.absent(),
                Value<String> ifoodFieldSelector = const Value.absent(),
                Value<bool> ocrContrastEnabled = const Value.absent(),
                Value<int?> activeRouteId = const Value.absent(),
                Value<int?> activeDeliveryIndex = const Value.absent(),
                Value<int> dailyGoalCents = const Value.absent(),
                Value<String> homeAddress = const Value.absent(),
                required String createdAt,
                required String updatedAt,
              }) => AppConfigTableCompanion.insert(
                id: id,
                driverName: driverName,
                pizzeriaAddress: pizzeriaAddress,
                ifoodUrl: ifoodUrl,
                ifoodFieldSelector: ifoodFieldSelector,
                ocrContrastEnabled: ocrContrastEnabled,
                activeRouteId: activeRouteId,
                activeDeliveryIndex: activeDeliveryIndex,
                dailyGoalCents: dailyGoalCents,
                homeAddress: homeAddress,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppConfigTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppConfigTableTable,
      AppConfigTableData,
      $$AppConfigTableTableFilterComposer,
      $$AppConfigTableTableOrderingComposer,
      $$AppConfigTableTableAnnotationComposer,
      $$AppConfigTableTableCreateCompanionBuilder,
      $$AppConfigTableTableUpdateCompanionBuilder,
      (
        AppConfigTableData,
        BaseReferences<_$AppDatabase, $AppConfigTableTable, AppConfigTableData>,
      ),
      AppConfigTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ShiftsTableTableTableManager get shiftsTable =>
      $$ShiftsTableTableTableManager(_db, _db.shiftsTable);
  $$RoutesTableTableTableManager get routesTable =>
      $$RoutesTableTableTableManager(_db, _db.routesTable);
  $$DeliveriesTableTableTableManager get deliveriesTable =>
      $$DeliveriesTableTableTableManager(_db, _db.deliveriesTable);
  $$ReceiptsTableTableTableManager get receiptsTable =>
      $$ReceiptsTableTableTableManager(_db, _db.receiptsTable);
  $$EarningsEntriesTableTableTableManager get earningsEntriesTable =>
      $$EarningsEntriesTableTableTableManager(_db, _db.earningsEntriesTable);
  $$EarningsConfigTableTableTableManager get earningsConfigTable =>
      $$EarningsConfigTableTableTableManager(_db, _db.earningsConfigTable);
  $$AppConfigTableTableTableManager get appConfigTable =>
      $$AppConfigTableTableTableManager(_db, _db.appConfigTable);
}
