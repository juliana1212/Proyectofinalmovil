import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/activo.dart';

class ServicioPrestamos {
  final CollectionReference prestamosRef =
      FirebaseFirestore.instance.collection('prestamos');

  // Solicitar un préstamo
  Future<bool> solicitarPrestamo(String activoId, String usuarioId) async {
    // Obtener todos los préstamos activos del usuario
    final snapshot = await prestamosRef
        .where('usuarioId', isEqualTo: usuarioId)
        .where('estado', isEqualTo: 'activo')
        .get();

    // Validar máximo 2 préstamos activos
    if (snapshot.docs.length >= 2) {
      return false; // No puede prestar más
    }

    // Registrar préstamo
    await prestamosRef.add({
      'activoId': activoId,
      'usuarioId': usuarioId,
      'fecha': FieldValue.serverTimestamp(),
      'estado': 'activo',
    });

    // Actualizar estado del activo
    await FirebaseFirestore.instance
        .collection('activos')
        .doc(activoId)
        .update({'estado': 'prestado'});

    return true;
  }
}