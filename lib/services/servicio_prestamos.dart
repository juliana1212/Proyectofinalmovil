// lib/services/servicio_prestamos.dart
import 'package:cloud_firestore/cloud_firestore.dart';
 
class ServicioPrestamos {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final CollectionReference _prestamosRef =
      FirebaseFirestore.instance.collection('prestamos');
 
  /// Solicita un préstamo para [activoId] en nombre de [usuarioId].
  ///
  /// Lanza [Exception] si el usuario ya tiene 2 préstamos activos.
  /// Retorna `true` si la operación fue exitosa.
  Future<bool> solicitarPrestamo(String activoId, String usuarioId) async {
    // 1. Validar límite de 2 préstamos activos por usuario
    final permitido = await puedeSolicitar(usuarioId);
    if (!permitido) {
      throw Exception('No puedes tener más de 2 préstamos activos');
    }
 
    // 2. Verificar que el activo sigue disponible (condición de carrera)
    final activoDoc =
        await _db.collection('activos').doc(activoId).get();
    if (!activoDoc.exists) {
      throw Exception('El activo no existe');
    }
    final estadoActual = activoDoc.data()?['estado'] ?? '';
    if (estadoActual != 'disponible') {
      throw Exception('El activo ya no está disponible');
    }
 
    // 3. Crear documento de préstamo
    await _prestamosRef.add({
      'activoId': activoId,
      'usuarioId': usuarioId,
      'fechaSolicitud': FieldValue.serverTimestamp(),
      'fechaVencimiento': Timestamp.fromDate(
        DateTime.now().add(const Duration(days: 7)),
      ),
      'estado': 'activo',
    });
 
    // 4. Marcar el activo como "prestado"
    await _db
        .collection('activos')
        .doc(activoId)
        .update({'estado': 'prestado'});
 
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
 
  /// Devuelve el número de préstamos activos del usuario.
  Future<int> contarPrestamosActivos(String usuarioId) async {
    final snapshot = await _prestamosRef
        .where('usuarioId', isEqualTo: usuarioId)
        .where('estado', isEqualTo: 'activo')
        .get();
    return snapshot.docs.length;
  }
}