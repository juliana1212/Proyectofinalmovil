import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../data/app_database.dart';
import '../models/devolucion.dart';
import '../models/enums.dart';
import '../models/perfil_usuario.dart';
import 'servicio_permisos.dart';
import 'servicio_sincronizacion.dart';

class ResultadoDevolucion {
  final bool sincronizada;
  final String mensaje;

  ResultadoDevolucion({
    required this.sincronizada,
    required this.mensaje,
  });
}

class ServicioDevoluciones {
  final FirebaseFirestore _db;
  final AppDatabase _database;
  final ServicioPermisos _servicioPermisos;
  final Connectivity _connectivity;
  late final ServicioSincronizacion _servicioSincronizacion;

  ServicioDevoluciones({
    FirebaseFirestore? db,
    AppDatabase? database,
    ServicioPermisos? servicioPermisos,
    Connectivity? connectivity,
  })  : _db = db ?? FirebaseFirestore.instance,
        _database = database ?? AppDatabase(),
        _servicioPermisos = servicioPermisos ?? ServicioPermisos(),
        _connectivity = connectivity ?? Connectivity() {
    _servicioSincronizacion = ServicioSincronizacion(
      db: _db,
      database: _database,
    );
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> obtenerPrestamosPorDevolver() {
    return _db
        .collection('prestamos')
        .where('estado', whereIn: ['activo', 'vencido'])
        .snapshots();
  }

  Stream<List<DevolucionesPendiente>> observarPendientes() {
    return _servicioSincronizacion.observarPendientes();
  }

  Future<int> contarPendientes() {
    return _servicioSincronizacion.contarPendientes();
  }

  Future<ResultadoSincronizacion> sincronizarPendientes() {
    return _servicioSincronizacion.sincronizarPendientes();
  }

  Future<ResultadoDevolucion> confirmarDevolucion({
    required String prestamoId,
    required String activoId,
    required PerfilUsuario encargado,
    required bool tieneNovedad,
    String? descripcionNovedad,
  }) async {
    if (!_servicioPermisos.puedeConfirmarDevolucion(encargado)) {
      throw Exception(
        'Solo el encargado de inventario puede confirmar devoluciones.',
      );
    }

    final novedad = descripcionNovedad?.trim() ?? '';

    if (tieneNovedad && novedad.isEmpty) {
      throw Exception(
        'Debes escribir la novedad encontrada en el activo.',
      );
    }

    final devolucion = Devolucion(
      id: _db.collection('devoluciones').doc().id,
      prestamoId: prestamoId,
      activoId: activoId,
      recibidoPor: encargado.uid,
      fechaDevolucion: DateTime.now(),
      tieneNovedad: tieneNovedad,
      descripcionNovedad: tieneNovedad ? novedad : null,
      syncStatus: SyncStatus.synced,
    );

    final hayConexion = await _hayConexionDeRed();

    if (!hayConexion) {
      await _guardarPendiente(
        devolucion,
        'Sin conexión a internet.',
      );

      return ResultadoDevolucion(
        sincronizada: false,
        mensaje:
            'Sin conexión. La devolución quedó pendiente de sincronización.',
      );
    }

    try {
      await _servicioSincronizacion.enviarDevolucionAFirestore(
        devolucion,
      );

      return ResultadoDevolucion(
        sincronizada: true,
        mensaje: tieneNovedad
            ? 'Devolución confirmada. El activo pasó a mantenimiento.'
            : 'Devolución confirmada. El activo está disponible.',
      );
    } catch (error) {
      if (!_esErrorTemporalDeConexion(error)) {
        rethrow;
      }

      await _guardarPendiente(
        devolucion,
        error.toString(),
      );

      return ResultadoDevolucion(
        sincronizada: false,
        mensaje:
            'Error temporal de conexión. La devolución quedó pendiente de sincronización.',
      );
    }
  }

  Future<bool> _hayConexionDeRed() async {
    final resultados = await _connectivity.checkConnectivity();

    return !resultados.contains(ConnectivityResult.none);
  }

  Future<void> _guardarPendiente(
    Devolucion devolucion,
    String mensajeError,
  ) async {
    await _database.guardarDevolucionPendiente(
      id: devolucion.id,
      prestamoId: devolucion.prestamoId,
      activoId: devolucion.activoId,
      recibidoPor: devolucion.recibidoPor,
      fechaDevolucion: devolucion.fechaDevolucion,
      tieneNovedad: devolucion.tieneNovedad,
      descripcionNovedad: devolucion.descripcionNovedad,
      mensajeError: mensajeError,
    );
  }

  bool _esErrorTemporalDeConexion(Object error) {
    if (error is FirebaseException) {
      return error.code == 'unavailable' ||
          error.code == 'deadline-exceeded' ||
          error.code == 'network-request-failed' ||
          error.code == 'unknown';
    }

    final mensaje = error.toString().toLowerCase();

    return mensaje.contains('network') ||
        mensaje.contains('internet') ||
        mensaje.contains('failed to fetch') ||
        mensaje.contains('unavailable') ||
        mensaje.contains('connection') ||
        mensaje.contains('converted future');
  }

  Future<void> cerrarBaseLocal() {
    return _database.close();
  }
}