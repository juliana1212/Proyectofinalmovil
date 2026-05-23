import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/activo.dart';

class ServicioActivos {
  final CollectionReference activosRef =
      FirebaseFirestore.instance.collection('activos');

  Stream<List<Activo>> obtenerActivos() {
    return activosRef.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Activo.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    });
  }
}