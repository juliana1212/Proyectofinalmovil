// lib/services/servicio_prestamos.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ServicioPrestamos {
  final CollectionReference prestamosRef =
      FirebaseFirestore.instance.collection('prestamos');

  // Solicitar un préstamo
  Future<bool> solicitarPrestamo(String activoId, String usuarioId) async {
    // Validar límite de 2 préstamos activos
    bool permitido = await puedeSolicitar(usuarioId);
    if (!permitido) {
      return false;
    }

    // Crear documento de préstamo
    await prestamosRef.add({
      'activoId': activoId,
      'usuarioId': usuarioId,
      'fecha': FieldValue.serverTimestamp(),
      'estado': 'activo',
    });

    // Actualizar estado del activo a "prestado"
    await FirebaseFirestore.instance
        .collection('activos')
        .doc(activoId)
        .update({'estado': 'prestado'});

    return true;
  }

  // Verifica si el usuario puede solicitar un préstamo (menos de 2 activos activos)
  Future<bool> puedeSolicitar(String usuarioId) async {
    final snapshot = await prestamosRef
        .where('usuarioId', isEqualTo: usuarioId)
        .where('estado', isEqualTo: 'activo')
        .get();
    return snapshot.docs.length < 2;
  }
}