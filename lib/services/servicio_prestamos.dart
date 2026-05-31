import 'package:cloud_firestore/cloud_firestore.dart';

import 'servicio_notificaciones.dart';

class ServicioPrestamos {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final ServicioNotificaciones _notificaciones = ServicioNotificaciones();

  final CollectionReference _prestamosRef = FirebaseFirestore.instance
      .collection('prestamos');

  Future<DateTime> solicitarPrestamo(String activoId, String usuarioId) async {
    // 1. Validar límite de 2 préstamos activos por usuario
    final permitido = await puedeSolicitar(usuarioId);

    if (!permitido) {
      throw Exception('No puedes tener más de 2 préstamos activos');
    }

    // 2. Validar que el usuario no tenga actualmente el mismo activo
    final yaTieneActivo = await usuarioTieneActivoPrestado(activoId, usuarioId);

    if (yaTieneActivo) {
      throw Exception(
        'Ya tienes un préstamo pendiente de devolución para este activo.',
      );
    }

    // 3. Calcular fechas del préstamo
    final fechaSolicitud = DateTime.now();

    final fechaVencimiento = fechaSolicitud.add(const Duration(hours: 4));

    // 4. Crear las referencias necesarias para la transacción
    final activoRef = _db.collection('activos').doc(activoId);
    final prestamoRef = _prestamosRef.doc();

    // 5. Validar inventario, crear préstamo y descontar cantidad
    // dentro de una misma transacción.
    String nombreActivo = 'activo institucional';
    await _db.runTransaction((transaction) async {
      final activoDoc = await transaction.get(activoRef);

      if (!activoDoc.exists || activoDoc.data() == null) {
        throw Exception('El activo no existe');
      }

      final datosActivo = activoDoc.data() as Map<String, dynamic>;
      nombreActivo = (datosActivo['nombre'] ?? 'activo institucional')
          .toString();

      final estadoActual = (datosActivo['estado'] ?? '').toString();

      final cantidadDisponible =
          (datosActivo['cantidadDisponible'] as num?)?.toInt() ??
          (estadoActual == 'disponible' ? 1 : 0);

      if (estadoActual == 'mantenimiento') {
        throw Exception('El activo se encuentra en mantenimiento');
      }

      if (estadoActual == 'dadoDeBaja') {
        throw Exception('El activo fue dado de baja');
      }

      if (cantidadDisponible <= 0) {
        throw Exception('No hay unidades disponibles para préstamo');
      }

      final nuevaCantidadDisponible = cantidadDisponible - 1;

      final nuevoEstado = nuevaCantidadDisponible > 0
          ? 'disponible'
          : 'prestado';

      // 6. Crear documento de préstamo con vencimiento de 4 horas
      transaction.set(prestamoRef, {
        'activoId': activoId,
        'usuarioId': usuarioId,
        'fechaSolicitud': Timestamp.fromDate(fechaSolicitud),
        'fechaVencimiento': Timestamp.fromDate(fechaVencimiento),
        'estado': 'activo',
      });

      // 7. Descontar una unidad del inventario del activo
      transaction.update(activoRef, {
        'cantidadDisponible': nuevaCantidadDisponible,
        'estado': nuevoEstado,
      });
    });
    await _notificaciones.crearNotificacion(
      usuarioId: usuarioId,
      titulo: 'Préstamo registrado',
      mensaje:
          'Solicitaste el activo $nombreActivo. Recuerda devolverlo antes de ${_formatearFecha(fechaVencimiento)}.',
      tipo: 'prestamo',
    );
    return fechaVencimiento;
  }

  /// Devuelve true si el usuario tiene menos de 2 préstamos activos.
  Future<bool> puedeSolicitar(String usuarioId) async {
    final snapshot = await _prestamosRef
        .where('usuarioId', isEqualTo: usuarioId)
        .where('estado', isEqualTo: 'activo')
        .get();

    return snapshot.docs.length < 2;
  }

  /// Devuelve true si el usuario ya tiene prestado el mismo activo
  /// y todavía no lo ha devuelto.
  Future<bool> usuarioTieneActivoPrestado(
    String activoId,
    String usuarioId,
  ) async {
    final snapshot = await _prestamosRef
        .where('usuarioId', isEqualTo: usuarioId)
        .where('activoId', isEqualTo: activoId)
        .where('estado', whereIn: ['activo', 'vencido'])
        .get();

    return snapshot.docs.isNotEmpty;
  }

  /// Devuelve el número de préstamos activos del usuario.
  Future<int> contarPrestamosActivos(String usuarioId) async {
    final snapshot = await _prestamosRef
        .where('usuarioId', isEqualTo: usuarioId)
        .where('estado', isEqualTo: 'activo')
        .get();

    return snapshot.docs.length;
  }

  String _formatearFecha(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    final anio = fecha.year.toString();

    final hora = fecha.hour.toString().padLeft(2, '0');
    final minutos = fecha.minute.toString().padLeft(2, '0');

    return '$dia/$mes/$anio a las $hora:$minutos';
  }
}
