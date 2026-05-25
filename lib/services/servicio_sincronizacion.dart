import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../data/app_database.dart';
import '../models/devolucion.dart';
import '../models/enums.dart';
import '../models/historial.dart';
import '../models/mantenimiento.dart';

class ResultadoSincronizacion {
  final int sincronizadas;
  final int pendientes;

  ResultadoSincronizacion({
    required this.sincronizadas,
    required this.pendientes,
  });
}

class ServicioSincronizacion {
  final FirebaseFirestore _db;
  final AppDatabase _database;
  final Connectivity _connectivity;

  ServicioSincronizacion({
    FirebaseFirestore? db,
    required AppDatabase database,
    Connectivity? connectivity,
  })  : _db = db ?? FirebaseFirestore.instance,
        _database = database,
        _connectivity = connectivity ?? Connectivity();

  /// Observa las devoluciones que están guardadas localmente
  /// y todavía no han sido sincronizadas.
  Stream<List<DevolucionesPendiente>> observarPendientes() {
    return _database.observarPendientes();
  }

  /// Cuenta cuántas devoluciones siguen pendientes en la base local.
  Future<int> contarPendientes() {
    return _database.contarPendientes();
  }

  /// Verifica si el dispositivo tiene alguna red disponible.
  ///
  /// Esta validación evita llamar a Firestore directamente
  /// cuando el equipo está claramente sin conexión.
  Future<bool> _hayConexionDeRed() async {
    final conexiones = await _connectivity.checkConnectivity();

    return !conexiones.contains(ConnectivityResult.none);
  }

  /// Envía una devolución a Firestore y realiza todos los cambios
  /// relacionados dentro de una transacción:
  /// - registra la devolución;
  /// - actualiza el préstamo;
  /// - actualiza el estado del activo;
  /// - crea mantenimiento si existe novedad;
  /// - registra el historial.
  Future<void> enviarDevolucionAFirestore(Devolucion devolucion) async {
    final prestamoRef =
        _db.collection('prestamos').doc(devolucion.prestamoId);

    final activoRef =
        _db.collection('activos').doc(devolucion.activoId);

    final devolucionRef =
        _db.collection('devoluciones').doc(devolucion.id);

    final mantenimientoRef =
        _db.collection('mantenimientos').doc('mant_${devolucion.id}');

    final historialRef =
        _db.collection('historial').doc('hist_${devolucion.id}');

    await _db.runTransaction((transaction) async {
      final devolucionExistente = await transaction.get(devolucionRef);

      // Evita crear dos veces la misma devolución al reintentar sincronizar.
      if (devolucionExistente.exists) {
        return;
      }

      final prestamoDocumento = await transaction.get(prestamoRef);
      final activoDocumento = await transaction.get(activoRef);

      if (!prestamoDocumento.exists) {
        throw Exception('El préstamo seleccionado no existe.');
      }

      if (!activoDocumento.exists) {
        throw Exception('El activo seleccionado no existe.');
      }

      final estadoPrestamo =
          (prestamoDocumento.data()?['estado'] ?? '').toString();

      if (estadoPrestamo != LoanStatus.activo.name &&
          estadoPrestamo != LoanStatus.vencido.name) {
        throw Exception(
          'El préstamo ya fue devuelto o no puede procesarse.',
        );
      }

      final estadoActivo =
          (activoDocumento.data()?['estado'] ?? '').toString();

      if (estadoActivo != AssetStatus.prestado.name &&
          estadoActivo != AssetStatus.vencido.name) {
        throw Exception(
          'El activo no está registrado como prestado o vencido.',
        );
      }

      transaction.set(
        devolucionRef,
        devolucion.toMap(),
      );

      transaction.update(
        prestamoRef,
        {
          'estado': LoanStatus.devuelto.name,
          'fechaDevolucion': Timestamp.fromDate(
            devolucion.fechaDevolucion,
          ),
        },
      );

      if (devolucion.tieneNovedad) {
        transaction.update(
          activoRef,
          {
            'estado': AssetStatus.mantenimiento.name,
          },
        );

        final mantenimiento = Mantenimiento(
          id: mantenimientoRef.id,
          activoId: devolucion.activoId,
          devolucionId: devolucion.id,
          descripcion: devolucion.descripcionNovedad ?? '',
          creadoPor: devolucion.recibidoPor,
          fechaCreacion: devolucion.fechaDevolucion,
          estado: 'pendiente',
          syncStatus: SyncStatus.synced,
        );

        transaction.set(
          mantenimientoRef,
          mantenimiento.toMap(),
        );
      } else {
        transaction.update(
          activoRef,
          {
            'estado': AssetStatus.disponible.name,
          },
        );
      }

      final historial = Historial(
        id: historialRef.id,
        entidadId: devolucion.activoId,
        tipoEntidad: 'activo',
        accion: devolucion.tieneNovedad
            ? 'Devolución confirmada con novedad. Activo enviado a mantenimiento.'
            : 'Devolución confirmada sin novedad. Activo disponible nuevamente.',
        usuarioId: devolucion.recibidoPor,
        fechaCreacion: devolucion.fechaDevolucion,
        syncStatus: SyncStatus.synced,
      );

      transaction.set(
        historialRef,
        historial.toMap(),
      );
    });
  }

  /// Intenta sincronizar todas las devoluciones pendientes.
  ///
  /// Si no hay conexión, no llama a Firestore y conserva los registros
  /// localmente como pendientes.
  Future<ResultadoSincronizacion> sincronizarPendientes() async {
    final registrosPendientes = await _database.obtenerPendientes();

    if (registrosPendientes.isEmpty) {
      return ResultadoSincronizacion(
        sincronizadas: 0,
        pendientes: 0,
      );
    }

    final hayConexion = await _hayConexionDeRed();

    if (!hayConexion) {
      return ResultadoSincronizacion(
        sincronizadas: 0,
        pendientes: registrosPendientes.length,
      );
    }

    int sincronizadas = 0;
    int pendientes = 0;

    for (final registro in registrosPendientes) {
      final devolucion = Devolucion(
        id: registro.id,
        prestamoId: registro.prestamoId,
        activoId: registro.activoId,
        recibidoPor: registro.recibidoPor,
        fechaDevolucion: registro.fechaDevolucion,
        tieneNovedad: registro.tieneNovedad,
        descripcionNovedad: registro.descripcionNovedad,
        syncStatus: SyncStatus.synced,
      );

      try {
        await enviarDevolucionAFirestore(devolucion);

        await _database.marcarSincronizada(registro.id);

        sincronizadas++;
      } catch (error) {
        final mensaje =
            error.toString().replaceFirst('Exception: ', '');

        await _database.dejarPendiente(
          registro.id,
          mensaje,
        );

        pendientes++;
      }
    }

    return ResultadoSincronizacion(
      sincronizadas: sincronizadas,
      pendientes: pendientes,
    );
  }
}