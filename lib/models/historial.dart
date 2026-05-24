import 'package:cloud_firestore/cloud_firestore.dart';
import 'enums.dart';

class Historial {
  final String id;
  final String entidadId;
  final String tipoEntidad;
  final String accion;
  final String usuarioId;
  final DateTime fechaCreacion;
  final SyncStatus syncStatus;

  Historial({
    required this.id,
    required this.entidadId,
    required this.tipoEntidad,
    required this.accion,
    required this.usuarioId,
    required this.fechaCreacion,
    this.syncStatus = SyncStatus.synced,
  });

  factory Historial.fromMap(String id, Map<String, dynamic> data) {
    return Historial(
      id: id,
      entidadId: data['entidadId'] ?? '',
      tipoEntidad: data['tipoEntidad'] ?? '',
      accion: data['accion'] ?? '',
      usuarioId: data['usuarioId'] ?? '',
      fechaCreacion: _convertirFecha(data['fechaCreacion']),
      syncStatus: SyncStatus.values.firstWhere(
        (estado) => estado.name == data['syncStatus'],
        orElse: () => SyncStatus.synced,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'entidadId': entidadId,
      'tipoEntidad': tipoEntidad,
      'accion': accion,
      'usuarioId': usuarioId,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
      'syncStatus': syncStatus.name,
    };
  }

  static DateTime _convertirFecha(dynamic fecha) {
    if (fecha is Timestamp) {
      return fecha.toDate();
    }

    if (fecha is DateTime) {
      return fecha;
    }

    return DateTime.now();
  }
}