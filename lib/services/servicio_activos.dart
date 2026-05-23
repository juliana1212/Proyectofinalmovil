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
 
  /// Obtiene un activo puntual por su ID (Future, no stream)
  Future<Activo?> obtenerActivoPorId(String id) async {
    final doc = await _db.collection(_collection).doc(id).get();
    if (!doc.exists) return null;
    return Activo.fromMap(doc.id, doc.data()!);
  }
 
  /// Guarda (crea o sobreescribe) un activo
  Future<void> guardarActivo(Activo activo) async {
    await _db.collection(_collection).doc(activo.id).set(activo.toMap());
  }
 
  /// Cambia el estado de un activo ("disponible", "prestado", "vencido", etc.)
  Future<void> cambiarEstado(String id, String nuevoEstado) async {
    await _db
        .collection(_collection)
        .doc(id)
        .update({'estado': nuevoEstado});
  }
}