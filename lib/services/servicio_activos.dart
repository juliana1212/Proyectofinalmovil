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
    if (activo.referencia.trim().isEmpty) {
      throw Exception('La referencia del activo es obligatoria.');
    }

    if (activo.nombre.trim().isEmpty) {
      throw Exception('El nombre del activo es obligatorio.');
    }

    if (activo.categoria.trim().isEmpty) {
      throw Exception('La categoria del activo es obligatoria.');
    }

    if (activo.cantidadTotal <= 0) {
      throw Exception('La cantidad total debe ser mayor que cero.');
    }

    if (activo.cantidadDisponible < 0 ||
        activo.cantidadMantenimiento < 0 ||
        activo.cantidadBaja < 0) {
      throw Exception('Las cantidades no pueden ser negativas.');
    }

    final cantidadesFueraDePrestamo = activo.cantidadDisponible +
        activo.cantidadMantenimiento +
        activo.cantidadBaja;

    if (cantidadesFueraDePrestamo > activo.cantidadTotal) {
      throw Exception(
        'La suma de cantidades disponibles, en mantenimiento y dadas '
        'de baja no puede superar la cantidad total.',
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

  /// Envía una unidad disponible del activo a mantenimiento
  /// Envía una unidad disponible del activo a mantenimiento
  Future<void> enviarAMantenimiento(String id) async {
    final referenciaActivo = _db.collection(_collection).doc(id);

    await _db.runTransaction((transaction) async {
      final doc = await transaction.get(referenciaActivo);

      if (!doc.exists || doc.data() == null) {
        throw Exception('El activo no existe.');
      }

      final datos = doc.data()!;

      final cantidadTotal =
          (datos['cantidadTotal'] as num?)?.toInt() ?? 1;

      final cantidadDisponible =
          (datos['cantidadDisponible'] as num?)?.toInt() ?? 0;

      final cantidadMantenimiento =
          (datos['cantidadMantenimiento'] as num?)?.toInt() ?? 0;

      final cantidadBaja =
          (datos['cantidadBaja'] as num?)?.toInt() ?? 0;

      if (cantidadDisponible <= 0) {
        throw Exception(
          'No hay unidades disponibles para enviar a mantenimiento.',
        );
      }

      final nuevaCantidadDisponible = cantidadDisponible - 1;
      final nuevaCantidadMantenimiento = cantidadMantenimiento + 1;

      final nuevoEstado = _calcularEstado(
        cantidadTotal: cantidadTotal,
        cantidadDisponible: nuevaCantidadDisponible,
        cantidadMantenimiento: nuevaCantidadMantenimiento,
        cantidadBaja: cantidadBaja,
      );

      transaction.update(referenciaActivo, {
        'estado': nuevoEstado,
        'cantidadDisponible': nuevaCantidadDisponible,
        'cantidadMantenimiento': nuevaCantidadMantenimiento,
      });
    });
  }

  /// Da de baja una unidad disponible del activo
  Future<void> darDeBaja(String id) async {
    final referenciaActivo = _db.collection(_collection).doc(id);

    await _db.runTransaction((transaction) async {
      final doc = await transaction.get(referenciaActivo);

      if (!doc.exists || doc.data() == null) {
        throw Exception('El activo no existe.');
      }

      final datos = doc.data()!;

      final cantidadTotal =
          (datos['cantidadTotal'] as num?)?.toInt() ?? 1;

      final cantidadDisponible =
          (datos['cantidadDisponible'] as num?)?.toInt() ?? 0;

      final cantidadMantenimiento =
          (datos['cantidadMantenimiento'] as num?)?.toInt() ?? 0;

      final cantidadBaja =
          (datos['cantidadBaja'] as num?)?.toInt() ?? 0;

      if (cantidadDisponible <= 0) {
        throw Exception(
          'No hay unidades disponibles para dar de baja.',
        );
      }

      final nuevaCantidadDisponible = cantidadDisponible - 1;
      final nuevaCantidadBaja = cantidadBaja + 1;

      final nuevoEstado = _calcularEstado(
        cantidadTotal: cantidadTotal,
        cantidadDisponible: nuevaCantidadDisponible,
        cantidadMantenimiento: cantidadMantenimiento,
        cantidadBaja: nuevaCantidadBaja,
      );

      transaction.update(referenciaActivo, {
        'estado': nuevoEstado,
        'cantidadDisponible': nuevaCantidadDisponible,
        'cantidadBaja': nuevaCantidadBaja,
      });
    });
  }

  /// Habilita una unidad que estaba en mantenimiento
  Future<void> habilitarActivo(String id) async {
    final referenciaActivo = _db.collection(_collection).doc(id);

    await _db.runTransaction((transaction) async {
      final doc = await transaction.get(referenciaActivo);

      if (!doc.exists || doc.data() == null) {
        throw Exception('El activo no existe.');
      }

      final datos = doc.data()!;

      final cantidadTotal =
          (datos['cantidadTotal'] as num?)?.toInt() ?? 1;

      final cantidadDisponible =
          (datos['cantidadDisponible'] as num?)?.toInt() ?? 0;

      final cantidadMantenimiento =
          (datos['cantidadMantenimiento'] as num?)?.toInt() ?? 0;

      final cantidadBaja =
          (datos['cantidadBaja'] as num?)?.toInt() ?? 0;

      if (cantidadMantenimiento <= 0) {
        throw Exception(
          'No hay unidades en mantenimiento para habilitar.',
        );
      }

      final nuevaCantidadDisponible = cantidadDisponible + 1;
      final nuevaCantidadMantenimiento = cantidadMantenimiento - 1;

      final nuevoEstado = _calcularEstado(
        cantidadTotal: cantidadTotal,
        cantidadDisponible: nuevaCantidadDisponible,
        cantidadMantenimiento: nuevaCantidadMantenimiento,
        cantidadBaja: cantidadBaja,
      );

      transaction.update(referenciaActivo, {
        'estado': nuevoEstado,
        'cantidadDisponible': nuevaCantidadDisponible,
        'cantidadMantenimiento': nuevaCantidadMantenimiento,
      });
    });
  }

  /// Calcula el estado general visible de la referencia según sus unidades.
  String _calcularEstado({
    required int cantidadTotal,
    required int cantidadDisponible,
    required int cantidadMantenimiento,
    required int cantidadBaja,
  }) {
    final cantidadPrestada = cantidadTotal -
        cantidadDisponible -
        cantidadMantenimiento -
        cantidadBaja;

    if (cantidadDisponible > 0) {
      return 'disponible';
    }

    if (cantidadPrestada > 0) {
      return 'prestado';
    }

    if (cantidadMantenimiento > 0) {
      return 'mantenimiento';
    }

    if (cantidadBaja >= cantidadTotal) {
      return 'dadoDeBaja';
    }

    return 'disponible';
  }
}