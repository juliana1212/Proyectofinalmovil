import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/devolucion.dart';
import '../models/enums.dart';
import '../models/historial.dart';
import '../models/mantenimiento.dart';
import '../models/perfil_usuario.dart';
import 'servicio_permisos.dart';

class ServicioDevoluciones {
  final FirebaseFirestore _db;
  final ServicioPermisos _servicioPermisos;

  ServicioDevoluciones({
    FirebaseFirestore? db,
    ServicioPermisos? servicioPermisos,
  })  : _db = db ?? FirebaseFirestore.instance,
        _servicioPermisos = servicioPermisos ?? ServicioPermisos();

  /// Permite observar los préstamos que todavía pueden ser devueltos.
  /// Se consideran los préstamos activos o vencidos.
  Stream<QuerySnapshot<Map<String, dynamic>>> obtenerPrestamosPorDevolver() {
    return _db
        .collection('prestamos')
        .where('estado', whereIn: ['activo', 'vencido'])
        .snapshots();
  }

  /// Confirma la devolución de un activo prestado.
  ///
  /// Reglas implementadas:
  /// - Solo el encargado de inventario con cuenta activa puede confirmar.
  /// - Si hay novedad, la descripción es obligatoria.
  /// - Sin novedad: el activo vuelve a disponible.
  /// - Con novedad: el activo queda en mantenimiento y se crea un registro.
  /// - Toda devolución genera historial.
  Future<void> confirmarDevolucion({
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

    final String novedad = descripcionNovedad?.trim() ?? '';

    if (tieneNovedad && novedad.isEmpty) {
      throw Exception(
        'Debes escribir la novedad encontrada en el activo.',
      );
    }

    final DocumentReference<Map<String, dynamic>> prestamoRef =
        _db.collection('prestamos').doc(prestamoId);

    final DocumentReference<Map<String, dynamic>> activoRef =
        _db.collection('activos').doc(activoId);

    final DocumentReference<Map<String, dynamic>> devolucionRef =
        _db.collection('devoluciones').doc();

    final DocumentReference<Map<String, dynamic>> historialRef =
        _db.collection('historial').doc();

    final DocumentReference<Map<String, dynamic>>? mantenimientoRef =
        tieneNovedad ? _db.collection('mantenimientos').doc() : null;

    final DateTime fechaActual = DateTime.now();

    await _db.runTransaction((transaction) async {
      final prestamoDocumento = await transaction.get(prestamoRef);
      final activoDocumento = await transaction.get(activoRef);

      if (!prestamoDocumento.exists) {
        throw Exception('El préstamo seleccionado no existe.');
      }

      if (!activoDocumento.exists) {
        throw Exception('El activo seleccionado no existe.');
      }

      final String estadoPrestamo =
          (prestamoDocumento.data()?['estado'] ?? '').toString();

      if (estadoPrestamo != LoanStatus.activo.name &&
          estadoPrestamo != LoanStatus.vencido.name) {
        throw Exception('El préstamo ya fue devuelto o no puede procesarse.');
      }

      final String estadoActivo =
          (activoDocumento.data()?['estado'] ?? '').toString();

      if (estadoActivo != AssetStatus.prestado.name &&
          estadoActivo != AssetStatus.vencido.name) {
        throw Exception(
          'El activo no está registrado como prestado o vencido.',
        );
      }

      final devolucion = Devolucion(
        id: devolucionRef.id,
        prestamoId: prestamoId,
        activoId: activoId,
        recibidoPor: encargado.uid,
        fechaDevolucion: fechaActual,
        tieneNovedad: tieneNovedad,
        descripcionNovedad: tieneNovedad ? novedad : null,
        syncStatus: SyncStatus.synced,
      );

      transaction.set(devolucionRef, devolucion.toMap());

      transaction.update(prestamoRef, {
        'estado': LoanStatus.devuelto.name,
        'fechaDevolucion': Timestamp.fromDate(fechaActual),
      });

      if (tieneNovedad) {
        transaction.update(activoRef, {
          'estado': AssetStatus.mantenimiento.name,
        });

        final mantenimiento = Mantenimiento(
          id: mantenimientoRef!.id,
          activoId: activoId,
          devolucionId: devolucionRef.id,
          descripcion: novedad,
          creadoPor: encargado.uid,
          fechaCreacion: fechaActual,
          estado: 'pendiente',
          syncStatus: SyncStatus.synced,
        );

        transaction.set(mantenimientoRef, mantenimiento.toMap());
      } else {
        transaction.update(activoRef, {
          'estado': AssetStatus.disponible.name,
        });
      }

      final historial = Historial(
        id: historialRef.id,
        entidadId: activoId,
        tipoEntidad: 'activo',
        accion: tieneNovedad
            ? 'Devolución confirmada con novedad. Activo enviado a mantenimiento.'
            : 'Devolución confirmada sin novedad. Activo disponible nuevamente.',
        usuarioId: encargado.uid,
        fechaCreacion: fechaActual,
        syncStatus: SyncStatus.synced,
      );

      transaction.set(historialRef, historial.toMap());
    });
  }
}