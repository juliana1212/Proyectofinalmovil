// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $DevolucionesPendientesTable extends DevolucionesPendientes
    with TableInfo<$DevolucionesPendientesTable, DevolucionesPendiente> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DevolucionesPendientesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _prestamoIdMeta = const VerificationMeta(
    'prestamoId',
  );
  @override
  late final GeneratedColumn<String> prestamoId = GeneratedColumn<String>(
    'prestamo_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activoIdMeta = const VerificationMeta(
    'activoId',
  );
  @override
  late final GeneratedColumn<String> activoId = GeneratedColumn<String>(
    'activo_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recibidoPorMeta = const VerificationMeta(
    'recibidoPor',
  );
  @override
  late final GeneratedColumn<String> recibidoPor = GeneratedColumn<String>(
    'recibido_por',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fechaDevolucionMeta = const VerificationMeta(
    'fechaDevolucion',
  );
  @override
  late final GeneratedColumn<DateTime> fechaDevolucion =
      GeneratedColumn<DateTime>(
        'fecha_devolucion',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _tieneNovedadMeta = const VerificationMeta(
    'tieneNovedad',
  );
  @override
  late final GeneratedColumn<bool> tieneNovedad = GeneratedColumn<bool>(
    'tiene_novedad',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("tiene_novedad" IN (0, 1))',
    ),
  );
  static const VerificationMeta _descripcionNovedadMeta =
      const VerificationMeta('descripcionNovedad');
  @override
  late final GeneratedColumn<String> descripcionNovedad =
      GeneratedColumn<String>(
        'descripcion_novedad',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _mensajeErrorMeta = const VerificationMeta(
    'mensajeError',
  );
  @override
  late final GeneratedColumn<String> mensajeError = GeneratedColumn<String>(
    'mensaje_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    prestamoId,
    activoId,
    recibidoPor,
    fechaDevolucion,
    tieneNovedad,
    descripcionNovedad,
    syncStatus,
    mensajeError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'devoluciones_pendientes';
  @override
  VerificationContext validateIntegrity(
    Insertable<DevolucionesPendiente> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('prestamo_id')) {
      context.handle(
        _prestamoIdMeta,
        prestamoId.isAcceptableOrUnknown(data['prestamo_id']!, _prestamoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_prestamoIdMeta);
    }
    if (data.containsKey('activo_id')) {
      context.handle(
        _activoIdMeta,
        activoId.isAcceptableOrUnknown(data['activo_id']!, _activoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_activoIdMeta);
    }
    if (data.containsKey('recibido_por')) {
      context.handle(
        _recibidoPorMeta,
        recibidoPor.isAcceptableOrUnknown(
          data['recibido_por']!,
          _recibidoPorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recibidoPorMeta);
    }
    if (data.containsKey('fecha_devolucion')) {
      context.handle(
        _fechaDevolucionMeta,
        fechaDevolucion.isAcceptableOrUnknown(
          data['fecha_devolucion']!,
          _fechaDevolucionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fechaDevolucionMeta);
    }
    if (data.containsKey('tiene_novedad')) {
      context.handle(
        _tieneNovedadMeta,
        tieneNovedad.isAcceptableOrUnknown(
          data['tiene_novedad']!,
          _tieneNovedadMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_tieneNovedadMeta);
    }
    if (data.containsKey('descripcion_novedad')) {
      context.handle(
        _descripcionNovedadMeta,
        descripcionNovedad.isAcceptableOrUnknown(
          data['descripcion_novedad']!,
          _descripcionNovedadMeta,
        ),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('mensaje_error')) {
      context.handle(
        _mensajeErrorMeta,
        mensajeError.isAcceptableOrUnknown(
          data['mensaje_error']!,
          _mensajeErrorMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DevolucionesPendiente map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DevolucionesPendiente(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      prestamoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prestamo_id'],
      )!,
      activoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}activo_id'],
      )!,
      recibidoPor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recibido_por'],
      )!,
      fechaDevolucion: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha_devolucion'],
      )!,
      tieneNovedad: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}tiene_novedad'],
      )!,
      descripcionNovedad: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}descripcion_novedad'],
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      mensajeError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mensaje_error'],
      ),
    );
  }

  @override
  $DevolucionesPendientesTable createAlias(String alias) {
    return $DevolucionesPendientesTable(attachedDatabase, alias);
  }
}

class DevolucionesPendiente extends DataClass
    implements Insertable<DevolucionesPendiente> {
  final String id;
  final String prestamoId;
  final String activoId;
  final String recibidoPor;
  final DateTime fechaDevolucion;
  final bool tieneNovedad;
  final String? descripcionNovedad;
  final String syncStatus;
  final String? mensajeError;
  const DevolucionesPendiente({
    required this.id,
    required this.prestamoId,
    required this.activoId,
    required this.recibidoPor,
    required this.fechaDevolucion,
    required this.tieneNovedad,
    this.descripcionNovedad,
    required this.syncStatus,
    this.mensajeError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['prestamo_id'] = Variable<String>(prestamoId);
    map['activo_id'] = Variable<String>(activoId);
    map['recibido_por'] = Variable<String>(recibidoPor);
    map['fecha_devolucion'] = Variable<DateTime>(fechaDevolucion);
    map['tiene_novedad'] = Variable<bool>(tieneNovedad);
    if (!nullToAbsent || descripcionNovedad != null) {
      map['descripcion_novedad'] = Variable<String>(descripcionNovedad);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || mensajeError != null) {
      map['mensaje_error'] = Variable<String>(mensajeError);
    }
    return map;
  }

  DevolucionesPendientesCompanion toCompanion(bool nullToAbsent) {
    return DevolucionesPendientesCompanion(
      id: Value(id),
      prestamoId: Value(prestamoId),
      activoId: Value(activoId),
      recibidoPor: Value(recibidoPor),
      fechaDevolucion: Value(fechaDevolucion),
      tieneNovedad: Value(tieneNovedad),
      descripcionNovedad: descripcionNovedad == null && nullToAbsent
          ? const Value.absent()
          : Value(descripcionNovedad),
      syncStatus: Value(syncStatus),
      mensajeError: mensajeError == null && nullToAbsent
          ? const Value.absent()
          : Value(mensajeError),
    );
  }

  factory DevolucionesPendiente.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DevolucionesPendiente(
      id: serializer.fromJson<String>(json['id']),
      prestamoId: serializer.fromJson<String>(json['prestamoId']),
      activoId: serializer.fromJson<String>(json['activoId']),
      recibidoPor: serializer.fromJson<String>(json['recibidoPor']),
      fechaDevolucion: serializer.fromJson<DateTime>(json['fechaDevolucion']),
      tieneNovedad: serializer.fromJson<bool>(json['tieneNovedad']),
      descripcionNovedad: serializer.fromJson<String?>(
        json['descripcionNovedad'],
      ),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      mensajeError: serializer.fromJson<String?>(json['mensajeError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'prestamoId': serializer.toJson<String>(prestamoId),
      'activoId': serializer.toJson<String>(activoId),
      'recibidoPor': serializer.toJson<String>(recibidoPor),
      'fechaDevolucion': serializer.toJson<DateTime>(fechaDevolucion),
      'tieneNovedad': serializer.toJson<bool>(tieneNovedad),
      'descripcionNovedad': serializer.toJson<String?>(descripcionNovedad),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'mensajeError': serializer.toJson<String?>(mensajeError),
    };
  }

  DevolucionesPendiente copyWith({
    String? id,
    String? prestamoId,
    String? activoId,
    String? recibidoPor,
    DateTime? fechaDevolucion,
    bool? tieneNovedad,
    Value<String?> descripcionNovedad = const Value.absent(),
    String? syncStatus,
    Value<String?> mensajeError = const Value.absent(),
  }) => DevolucionesPendiente(
    id: id ?? this.id,
    prestamoId: prestamoId ?? this.prestamoId,
    activoId: activoId ?? this.activoId,
    recibidoPor: recibidoPor ?? this.recibidoPor,
    fechaDevolucion: fechaDevolucion ?? this.fechaDevolucion,
    tieneNovedad: tieneNovedad ?? this.tieneNovedad,
    descripcionNovedad: descripcionNovedad.present
        ? descripcionNovedad.value
        : this.descripcionNovedad,
    syncStatus: syncStatus ?? this.syncStatus,
    mensajeError: mensajeError.present ? mensajeError.value : this.mensajeError,
  );
  DevolucionesPendiente copyWithCompanion(
    DevolucionesPendientesCompanion data,
  ) {
    return DevolucionesPendiente(
      id: data.id.present ? data.id.value : this.id,
      prestamoId: data.prestamoId.present
          ? data.prestamoId.value
          : this.prestamoId,
      activoId: data.activoId.present ? data.activoId.value : this.activoId,
      recibidoPor: data.recibidoPor.present
          ? data.recibidoPor.value
          : this.recibidoPor,
      fechaDevolucion: data.fechaDevolucion.present
          ? data.fechaDevolucion.value
          : this.fechaDevolucion,
      tieneNovedad: data.tieneNovedad.present
          ? data.tieneNovedad.value
          : this.tieneNovedad,
      descripcionNovedad: data.descripcionNovedad.present
          ? data.descripcionNovedad.value
          : this.descripcionNovedad,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      mensajeError: data.mensajeError.present
          ? data.mensajeError.value
          : this.mensajeError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DevolucionesPendiente(')
          ..write('id: $id, ')
          ..write('prestamoId: $prestamoId, ')
          ..write('activoId: $activoId, ')
          ..write('recibidoPor: $recibidoPor, ')
          ..write('fechaDevolucion: $fechaDevolucion, ')
          ..write('tieneNovedad: $tieneNovedad, ')
          ..write('descripcionNovedad: $descripcionNovedad, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('mensajeError: $mensajeError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    prestamoId,
    activoId,
    recibidoPor,
    fechaDevolucion,
    tieneNovedad,
    descripcionNovedad,
    syncStatus,
    mensajeError,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DevolucionesPendiente &&
          other.id == this.id &&
          other.prestamoId == this.prestamoId &&
          other.activoId == this.activoId &&
          other.recibidoPor == this.recibidoPor &&
          other.fechaDevolucion == this.fechaDevolucion &&
          other.tieneNovedad == this.tieneNovedad &&
          other.descripcionNovedad == this.descripcionNovedad &&
          other.syncStatus == this.syncStatus &&
          other.mensajeError == this.mensajeError);
}

class DevolucionesPendientesCompanion
    extends UpdateCompanion<DevolucionesPendiente> {
  final Value<String> id;
  final Value<String> prestamoId;
  final Value<String> activoId;
  final Value<String> recibidoPor;
  final Value<DateTime> fechaDevolucion;
  final Value<bool> tieneNovedad;
  final Value<String?> descripcionNovedad;
  final Value<String> syncStatus;
  final Value<String?> mensajeError;
  final Value<int> rowid;
  const DevolucionesPendientesCompanion({
    this.id = const Value.absent(),
    this.prestamoId = const Value.absent(),
    this.activoId = const Value.absent(),
    this.recibidoPor = const Value.absent(),
    this.fechaDevolucion = const Value.absent(),
    this.tieneNovedad = const Value.absent(),
    this.descripcionNovedad = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.mensajeError = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DevolucionesPendientesCompanion.insert({
    required String id,
    required String prestamoId,
    required String activoId,
    required String recibidoPor,
    required DateTime fechaDevolucion,
    required bool tieneNovedad,
    this.descripcionNovedad = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.mensajeError = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       prestamoId = Value(prestamoId),
       activoId = Value(activoId),
       recibidoPor = Value(recibidoPor),
       fechaDevolucion = Value(fechaDevolucion),
       tieneNovedad = Value(tieneNovedad);
  static Insertable<DevolucionesPendiente> custom({
    Expression<String>? id,
    Expression<String>? prestamoId,
    Expression<String>? activoId,
    Expression<String>? recibidoPor,
    Expression<DateTime>? fechaDevolucion,
    Expression<bool>? tieneNovedad,
    Expression<String>? descripcionNovedad,
    Expression<String>? syncStatus,
    Expression<String>? mensajeError,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (prestamoId != null) 'prestamo_id': prestamoId,
      if (activoId != null) 'activo_id': activoId,
      if (recibidoPor != null) 'recibido_por': recibidoPor,
      if (fechaDevolucion != null) 'fecha_devolucion': fechaDevolucion,
      if (tieneNovedad != null) 'tiene_novedad': tieneNovedad,
      if (descripcionNovedad != null) 'descripcion_novedad': descripcionNovedad,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (mensajeError != null) 'mensaje_error': mensajeError,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DevolucionesPendientesCompanion copyWith({
    Value<String>? id,
    Value<String>? prestamoId,
    Value<String>? activoId,
    Value<String>? recibidoPor,
    Value<DateTime>? fechaDevolucion,
    Value<bool>? tieneNovedad,
    Value<String?>? descripcionNovedad,
    Value<String>? syncStatus,
    Value<String?>? mensajeError,
    Value<int>? rowid,
  }) {
    return DevolucionesPendientesCompanion(
      id: id ?? this.id,
      prestamoId: prestamoId ?? this.prestamoId,
      activoId: activoId ?? this.activoId,
      recibidoPor: recibidoPor ?? this.recibidoPor,
      fechaDevolucion: fechaDevolucion ?? this.fechaDevolucion,
      tieneNovedad: tieneNovedad ?? this.tieneNovedad,
      descripcionNovedad: descripcionNovedad ?? this.descripcionNovedad,
      syncStatus: syncStatus ?? this.syncStatus,
      mensajeError: mensajeError ?? this.mensajeError,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (prestamoId.present) {
      map['prestamo_id'] = Variable<String>(prestamoId.value);
    }
    if (activoId.present) {
      map['activo_id'] = Variable<String>(activoId.value);
    }
    if (recibidoPor.present) {
      map['recibido_por'] = Variable<String>(recibidoPor.value);
    }
    if (fechaDevolucion.present) {
      map['fecha_devolucion'] = Variable<DateTime>(fechaDevolucion.value);
    }
    if (tieneNovedad.present) {
      map['tiene_novedad'] = Variable<bool>(tieneNovedad.value);
    }
    if (descripcionNovedad.present) {
      map['descripcion_novedad'] = Variable<String>(descripcionNovedad.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (mensajeError.present) {
      map['mensaje_error'] = Variable<String>(mensajeError.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DevolucionesPendientesCompanion(')
          ..write('id: $id, ')
          ..write('prestamoId: $prestamoId, ')
          ..write('activoId: $activoId, ')
          ..write('recibidoPor: $recibidoPor, ')
          ..write('fechaDevolucion: $fechaDevolucion, ')
          ..write('tieneNovedad: $tieneNovedad, ')
          ..write('descripcionNovedad: $descripcionNovedad, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('mensajeError: $mensajeError, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DevolucionesPendientesTable devolucionesPendientes =
      $DevolucionesPendientesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [devolucionesPendientes];
}

typedef $$DevolucionesPendientesTableCreateCompanionBuilder =
    DevolucionesPendientesCompanion Function({
      required String id,
      required String prestamoId,
      required String activoId,
      required String recibidoPor,
      required DateTime fechaDevolucion,
      required bool tieneNovedad,
      Value<String?> descripcionNovedad,
      Value<String> syncStatus,
      Value<String?> mensajeError,
      Value<int> rowid,
    });
typedef $$DevolucionesPendientesTableUpdateCompanionBuilder =
    DevolucionesPendientesCompanion Function({
      Value<String> id,
      Value<String> prestamoId,
      Value<String> activoId,
      Value<String> recibidoPor,
      Value<DateTime> fechaDevolucion,
      Value<bool> tieneNovedad,
      Value<String?> descripcionNovedad,
      Value<String> syncStatus,
      Value<String?> mensajeError,
      Value<int> rowid,
    });

class $$DevolucionesPendientesTableFilterComposer
    extends Composer<_$AppDatabase, $DevolucionesPendientesTable> {
  $$DevolucionesPendientesTableFilterComposer({
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

  ColumnFilters<String> get prestamoId => $composableBuilder(
    column: $table.prestamoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activoId => $composableBuilder(
    column: $table.activoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recibidoPor => $composableBuilder(
    column: $table.recibidoPor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fechaDevolucion => $composableBuilder(
    column: $table.fechaDevolucion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get tieneNovedad => $composableBuilder(
    column: $table.tieneNovedad,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descripcionNovedad => $composableBuilder(
    column: $table.descripcionNovedad,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mensajeError => $composableBuilder(
    column: $table.mensajeError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DevolucionesPendientesTableOrderingComposer
    extends Composer<_$AppDatabase, $DevolucionesPendientesTable> {
  $$DevolucionesPendientesTableOrderingComposer({
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

  ColumnOrderings<String> get prestamoId => $composableBuilder(
    column: $table.prestamoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activoId => $composableBuilder(
    column: $table.activoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recibidoPor => $composableBuilder(
    column: $table.recibidoPor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fechaDevolucion => $composableBuilder(
    column: $table.fechaDevolucion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get tieneNovedad => $composableBuilder(
    column: $table.tieneNovedad,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descripcionNovedad => $composableBuilder(
    column: $table.descripcionNovedad,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mensajeError => $composableBuilder(
    column: $table.mensajeError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DevolucionesPendientesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DevolucionesPendientesTable> {
  $$DevolucionesPendientesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get prestamoId => $composableBuilder(
    column: $table.prestamoId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get activoId =>
      $composableBuilder(column: $table.activoId, builder: (column) => column);

  GeneratedColumn<String> get recibidoPor => $composableBuilder(
    column: $table.recibidoPor,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get fechaDevolucion => $composableBuilder(
    column: $table.fechaDevolucion,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get tieneNovedad => $composableBuilder(
    column: $table.tieneNovedad,
    builder: (column) => column,
  );

  GeneratedColumn<String> get descripcionNovedad => $composableBuilder(
    column: $table.descripcionNovedad,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mensajeError => $composableBuilder(
    column: $table.mensajeError,
    builder: (column) => column,
  );
}

class $$DevolucionesPendientesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DevolucionesPendientesTable,
          DevolucionesPendiente,
          $$DevolucionesPendientesTableFilterComposer,
          $$DevolucionesPendientesTableOrderingComposer,
          $$DevolucionesPendientesTableAnnotationComposer,
          $$DevolucionesPendientesTableCreateCompanionBuilder,
          $$DevolucionesPendientesTableUpdateCompanionBuilder,
          (
            DevolucionesPendiente,
            BaseReferences<
              _$AppDatabase,
              $DevolucionesPendientesTable,
              DevolucionesPendiente
            >,
          ),
          DevolucionesPendiente,
          PrefetchHooks Function()
        > {
  $$DevolucionesPendientesTableTableManager(
    _$AppDatabase db,
    $DevolucionesPendientesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DevolucionesPendientesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$DevolucionesPendientesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$DevolucionesPendientesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> prestamoId = const Value.absent(),
                Value<String> activoId = const Value.absent(),
                Value<String> recibidoPor = const Value.absent(),
                Value<DateTime> fechaDevolucion = const Value.absent(),
                Value<bool> tieneNovedad = const Value.absent(),
                Value<String?> descripcionNovedad = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<String?> mensajeError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DevolucionesPendientesCompanion(
                id: id,
                prestamoId: prestamoId,
                activoId: activoId,
                recibidoPor: recibidoPor,
                fechaDevolucion: fechaDevolucion,
                tieneNovedad: tieneNovedad,
                descripcionNovedad: descripcionNovedad,
                syncStatus: syncStatus,
                mensajeError: mensajeError,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String prestamoId,
                required String activoId,
                required String recibidoPor,
                required DateTime fechaDevolucion,
                required bool tieneNovedad,
                Value<String?> descripcionNovedad = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<String?> mensajeError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DevolucionesPendientesCompanion.insert(
                id: id,
                prestamoId: prestamoId,
                activoId: activoId,
                recibidoPor: recibidoPor,
                fechaDevolucion: fechaDevolucion,
                tieneNovedad: tieneNovedad,
                descripcionNovedad: descripcionNovedad,
                syncStatus: syncStatus,
                mensajeError: mensajeError,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DevolucionesPendientesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DevolucionesPendientesTable,
      DevolucionesPendiente,
      $$DevolucionesPendientesTableFilterComposer,
      $$DevolucionesPendientesTableOrderingComposer,
      $$DevolucionesPendientesTableAnnotationComposer,
      $$DevolucionesPendientesTableCreateCompanionBuilder,
      $$DevolucionesPendientesTableUpdateCompanionBuilder,
      (
        DevolucionesPendiente,
        BaseReferences<
          _$AppDatabase,
          $DevolucionesPendientesTable,
          DevolucionesPendiente
        >,
      ),
      DevolucionesPendiente,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DevolucionesPendientesTableTableManager get devolucionesPendientes =>
      $$DevolucionesPendientesTableTableManager(
        _db,
        _db.devolucionesPendientes,
      );
}
