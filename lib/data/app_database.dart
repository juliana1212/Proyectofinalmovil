import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class DevolucionesPendientes extends Table {
  TextColumn get id => text()();

  TextColumn get prestamoId => text()();

  TextColumn get activoId => text()();

  TextColumn get recibidoPor => text()();

  DateTimeColumn get fechaDevolucion => dateTime()();

  BoolColumn get tieneNovedad => boolean()();

  TextColumn get descripcionNovedad => text().nullable()();

  TextColumn get syncStatus =>
      text().withDefault(const Constant('pending'))();

  TextColumn get mensajeError => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(tables: [DevolucionesPendientes])
class AppDatabase extends _$AppDatabase {
  AppDatabase()
      : super(
          driftDatabase(
            name: 'control_activos_local',
            web: DriftWebOptions(
              sqlite3Wasm: Uri.parse('sqlite3.wasm'),
              driftWorker: Uri.parse('drift_worker.js'),
            ),
          ),
        );

  @override
  int get schemaVersion => 1;

  Future<void> guardarDevolucionPendiente({
    required String id,
    required String prestamoId,
    required String activoId,
    required String recibidoPor,
    required DateTime fechaDevolucion,
    required bool tieneNovedad,
    String? descripcionNovedad,
    String? mensajeError,
  }) async {
    await into(devolucionesPendientes).insertOnConflictUpdate(
      DevolucionesPendientesCompanion.insert(
        id: id,
        prestamoId: prestamoId,
        activoId: activoId,
        recibidoPor: recibidoPor,
        fechaDevolucion: fechaDevolucion,
        tieneNovedad: tieneNovedad,
        descripcionNovedad: Value(descripcionNovedad),
        mensajeError: Value(mensajeError),
      ),
    );
  }

  Stream<List<DevolucionesPendiente>> observarPendientes() {
    return (select(devolucionesPendientes)
          ..where((registro) => registro.syncStatus.equals('pending'))
          ..orderBy([
            (registro) => OrderingTerm.asc(registro.fechaDevolucion),
          ]))
        .watch();
  }

  Future<List<DevolucionesPendiente>> obtenerPendientes() {
    return (select(devolucionesPendientes)
          ..where((registro) => registro.syncStatus.equals('pending')))
        .get();
  }

  Future<int> contarPendientes() async {
    final registros = await obtenerPendientes();
    return registros.length;
  }

  Future<void> marcarSincronizada(String id) async {
    await (update(devolucionesPendientes)
          ..where((registro) => registro.id.equals(id)))
        .write(
      const DevolucionesPendientesCompanion(
        syncStatus: Value('synced'),
        mensajeError: Value(null),
      ),
    );
  }

  Future<void> marcarFallida(String id, String mensajeError) async {
    await (update(devolucionesPendientes)
          ..where((registro) => registro.id.equals(id)))
        .write(
      DevolucionesPendientesCompanion(
        syncStatus: const Value('failed'),
        mensajeError: Value(mensajeError),
      ),
    );
  }

  Future<void> dejarPendiente(String id, String mensajeError) async {
    await (update(devolucionesPendientes)
          ..where((registro) => registro.id.equals(id)))
        .write(
      DevolucionesPendientesCompanion(
        syncStatus: const Value('pending'),
        mensajeError: Value(mensajeError),
      ),
    );
  }

  Future<void> eliminarSincronizada(String id) async {
    await (delete(devolucionesPendientes)
          ..where((registro) => registro.id.equals(id)))
        .go();
  }
}