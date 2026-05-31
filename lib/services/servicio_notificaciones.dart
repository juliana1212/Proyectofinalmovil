import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ServicioNotificaciones {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const String enlaceEncuesta = 'https://forms.gle/Pendiente';

  Future<void> crearNotificacion({
    required String usuarioId,
    required String titulo,
    required String mensaje,
    required String tipo,
    String? enlace,
  }) async {
    if (usuarioId.trim().isEmpty) {
      return;
    }

    try {
      await _db.collection('notificaciones').add({
        'usuarioId': usuarioId,
        'titulo': titulo,
        'mensaje': mensaje,
        'tipo': tipo,
        'enlace': enlace,
        'leida': false,
        'fechaCreacion': FieldValue.serverTimestamp(),
      });
    } catch (error) {
      // La notificación es un valor agregado.
      // Si falla, no debe bloquear el registro, préstamo o devolución.
      debugPrint('No se pudo crear la notificación: $error');
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> obtenerNotificacionesUsuario(
    String usuarioId,
  ) {
    if (usuarioId.trim().isEmpty) {
      return const Stream.empty();
    }

    return _db
        .collection('notificaciones')
        .where('usuarioId', isEqualTo: usuarioId)
        .limit(10)
        .snapshots();
  }

  Future<void> marcarComoLeida(String notificacionId) async {
    if (notificacionId.trim().isEmpty) {
      return;
    }

    try {
      await _db.collection('notificaciones').doc(notificacionId).update({
        'leida': true,
      });
    } catch (error) {
      debugPrint('No se pudo marcar la notificación como leída: $error');
    }
  }
}
