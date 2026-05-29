// lib/services/servicio_prestamos.dart
import 'package:cloud_firestore/cloud_firestore.dart';
 
class ServicioPrestamos {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final CollectionReference _prestamosRef =
      FirebaseFirestore.instance.collection('prestamos');
 
  /// Solicita un préstamo para [activoId] en nombre de [usuarioId].
  ///
  /// Lanza [Exception] si el usuario ya tiene 2 préstamos activos,
  /// si ya tiene prestado el mismo activo o si no hay inventario disponible.
  /// Retorna `true` si la operación fue exitosa.
  Future<bool> solicitarPrestamo(String activoId, String usuarioId) async {
    // 1. Validar límite de 2 préstamos activos por usuario
    final permitido = await puedeSolicitar(usuarioId);
    if (!permitido) {
      throw Exception('No puedes tener más de 2 préstamos activos');
    }

    // 2. Validar que el usuario no tenga actualmente el mismo activo
    final yaTieneActivo = await usuarioTieneActivoPrestado(
      activoId,
      usuarioId,
    );

    if (yaTieneActivo) {
      throw Exception(
        'Ya tienes un préstamo pendiente de devolución para este activo.',
      );
    }

    // 3. Crear las referencias necesarias para la transacción
    final activoRef = _db.collection('activos').doc(activoId);
    final prestamoRef = _prestamosRef.doc();

    // 4. Validar inventario, crear préstamo y descontar cantidad
    //    dentro de una misma transacción.
    await _db.runTransaction((transaction) async {
      final activoDoc = await transaction.get(activoRef);

      if (!activoDoc.exists || activoDoc.data() == null) {
        throw Exception('El activo no existe');
      }

      final datosActivo = activoDoc.data() as Map<String, dynamic>;
      final estadoActual = datosActivo['estado'] ?? '';
      final cantidadDisponible =
          datosActivo['cantidadDisponible'] ??
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

      // 5. Crear documento de préstamo
      transaction.set(prestamoRef, {
        'activoId': activoId,
        'usuarioId': usuarioId,
        'fechaSolicitud': FieldValue.serverTimestamp(),
        'fechaVencimiento': Timestamp.fromDate(
          DateTime.now().add(const Duration(days: 7)),
        ),
        'estado': 'activo',
      });

      // 6. Descontar una unidad del inventario del activo
      transaction.update(activoRef, {
        'cantidadDisponible': nuevaCantidadDisponible,
        'estado': nuevoEstado,
      });
    });
 
    return true;
  }
 
  /// Devuelve `true` si el usuario tiene menos de 2 préstamos activos.
  Future<bool> puedeSolicitar(String usuarioId) async {
    final snapshot = await _prestamosRef
        .where('usuarioId', isEqualTo: usuarioId)
        .where('estado', isEqualTo: 'activo')
        .get();
    return snapshot.docs.length < 2;
  }

  /// Devuelve `true` si el usuario ya tiene prestado el mismo activo
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
}