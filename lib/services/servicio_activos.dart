// lib/services/servicio_activos.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/activo.dart';
 
class ServicioActivos {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'activos';
 
  /// Stream en tiempo real de todos los activos
  Stream<List<Activo>> obtenerActivos() {
    return _db.collection(_collection).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => Activo.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }
 
  // Obtiene activos pertenecientes a una categoria.
  Stream<List<Activo>> obtenerActivosPorCategoria(String categoria) {
    return _db
        .collection(_collection)
        .where('categoria', isEqualTo: categoria)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Activo.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }
 
  /// Obtiene un activo puntual por su ID (Future, no stream)
  Future<Activo?> obtenerActivoPorId(String id) async {
    final doc = await _db.collection(_collection).doc(id).get();
    if (!doc.exists) return null;
    return Activo.fromMap(doc.id, doc.data()!);
  }
 
  /// Guarda (crea o sobreescribe) un activo
  Future<void> guardarActivo(Activo activo) async {
    if (activo.nombre.trim().isEmpty) {
      throw Exception('El nombre del activo es obligatorio.');
    }

    if (activo.categoria.trim().isEmpty) {
      throw Exception('La categoria del activo es obligatoria.');
    }

    if (activo.cantidadTotal <= 0) {
      throw Exception('La cantidad total debe ser mayor que cero.');
    }

    if (activo.cantidadDisponible < 0) {
      throw Exception('La cantidad disponible no puede ser negativa.');
    }

    if (activo.cantidadDisponible > activo.cantidadTotal) {
      throw Exception(
        'La cantidad disponible no puede superar la cantidad total.',
      );
    }

    await _db.collection(_collection).doc(activo.id).set(activo.toMap());
  }
 
  /// Cambia el estado de un activo ("disponible", "prestado", "vencido", etc.)
  Future<void> cambiarEstado(String id, String nuevoEstado) async {
    await _db
        .collection(_collection)
        .doc(id)
        .update({'estado': nuevoEstado});
  }

  /// Envía un activo a mantenimiento si no se encuentra prestado
  Future<void> enviarAMantenimiento(String id) async {
    final referenciaActivo = _db.collection(_collection).doc(id);

    await _db.runTransaction((transaction) async {
      final doc = await transaction.get(referenciaActivo);

      if (!doc.exists || doc.data() == null) {
        throw Exception('El activo no existe.');
      }

      final datos = doc.data()!;
      final estadoActual = datos['estado'] ?? '';
      final cantidadTotal = datos['cantidadTotal'] ?? 1;
      final cantidadDisponible = datos['cantidadDisponible'] ?? 1;

      if (estadoActual == 'dadoDeBaja') {
        throw Exception(
          'El activo ya fue dado de baja y no puede enviarse a mantenimiento.',
        );
      }

      if (cantidadDisponible < cantidadTotal) {
        throw Exception(
          'No se puede enviar a mantenimiento porque el activo se encuentra prestado.',
        );
      }

      transaction.update(referenciaActivo, {
        'estado': 'mantenimiento',
        'cantidadDisponible': 0,
      });
    });
  }

  /// Da de baja un activo si no se encuentra prestado
  Future<void> darDeBaja(String id) async {
    final referenciaActivo = _db.collection(_collection).doc(id);

    await _db.runTransaction((transaction) async {
      final doc = await transaction.get(referenciaActivo);

      if (!doc.exists || doc.data() == null) {
        throw Exception('El activo no existe.');
      }

      final datos = doc.data()!;
      final estadoActual = datos['estado'] ?? '';
      final cantidadTotal = datos['cantidadTotal'] ?? 1;
      final cantidadDisponible = datos['cantidadDisponible'] ?? 1;

      if (estadoActual == 'dadoDeBaja') {
        throw Exception('El activo ya fue dado de baja.');
      }

      if (cantidadDisponible < cantidadTotal) {
        throw Exception(
          'No se puede dar de baja porque el activo se encuentra prestado.',
        );
      }

      transaction.update(referenciaActivo, {
        'estado': 'dadoDeBaja',
        'cantidadDisponible': 0,
      });
    });
  }

  /// Habilita nuevamente un activo que estaba en mantenimiento
  Future<void> habilitarActivo(String id) async {
    final referenciaActivo = _db.collection(_collection).doc(id);

    await _db.runTransaction((transaction) async {
      final doc = await transaction.get(referenciaActivo);

      if (!doc.exists || doc.data() == null) {
        throw Exception('El activo no existe.');
      }

      final datos = doc.data()!;
      final estadoActual = datos['estado'] ?? '';
      final cantidadTotal = datos['cantidadTotal'] ?? 1;

      if (estadoActual == 'dadoDeBaja') {
        throw Exception(
          'Un activo dado de baja no puede volver a habilitarse.',
        );
      }

      if (estadoActual != 'mantenimiento') {
        throw Exception(
          'El activo no se encuentra en mantenimiento.',
        );
      }

      transaction.update(referenciaActivo, {
        'estado': 'disponible',
        'cantidadDisponible': cantidadTotal,
      });
    });
  }
}