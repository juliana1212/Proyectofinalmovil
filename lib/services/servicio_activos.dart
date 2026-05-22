import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/activo.dart';

class ServicioActivos {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = "activos";

  Stream<List<Activo>> obtenerActivos() {
    return _db.collection(_collection).snapshots().map(
      (snapshot) => snapshot.docs.map(
        (doc) => Activo.fromMap(doc.id, doc.data())
      ).toList()
    );
  }

  Future<void> guardarActivo(Activo activo) async {
    await _db.collection(_collection).doc(activo.id).set(activo.toMap());
  }

  Future<void> cambiarEstado(String id, String nuevoEstado) async {
    await _db.collection(_collection).doc(id).update({'estado': nuevoEstado});
  }
}