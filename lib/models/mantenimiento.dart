import 'package:cloud_firestore/cloud_firestore.dart';
import 'enums.dart';

class Mantenimiento {
  final String id;
  final String activoId;
  final String devolucionId;
  final String descripcion;
  final String creadoPor;
  final DateTime fechaCreacion;
  final String estado;
  final SyncStatus syncStatus;

  Mantenimiento({
    required this.id,
    required this.activoId,
    required this.devolucionId,
    required this.descripcion,
    required this.creadoPor,
    required this.fechaCreacion,
    this.estado = 'pendiente',
    this.syncStatus = SyncStatus.synced,
  });

  factory Mantenimiento.fromMap(String id, Map<String, dynamic> data) {
    return Mantenimiento(
      id: id,
      activoId: data['activoId'] ?? '',
      devolucionId: data['devolucionId'] ?? '',
      descripcion: data['descripcion'] ?? '',
      creadoPor: data['creadoPor'] ?? '',
      fechaCreacion: _convertirFecha(data['fechaCreacion']),
      estado: data['estado'] ?? 'pendiente',
      syncStatus: SyncStatus.values.firstWhere(
        (estado) => estado.name == data['syncStatus'],
        orElse: () => SyncStatus.synced,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'activoId': activoId,
      'devolucionId': devolucionId,
      'descripcion': descripcion,
      'creadoPor': creadoPor,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
      'estado': estado,
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