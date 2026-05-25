import 'package:cloud_firestore/cloud_firestore.dart';
import 'enums.dart';

class Devolucion {
  final String id;
  final String prestamoId;
  final String activoId;
  final String recibidoPor;
  final DateTime fechaDevolucion;
  final bool tieneNovedad;
  final String? descripcionNovedad;
  final SyncStatus syncStatus;

  Devolucion({
    required this.id,
    required this.prestamoId,
    required this.activoId,
    required this.recibidoPor,
    required this.fechaDevolucion,
    required this.tieneNovedad,
    this.descripcionNovedad,
    this.syncStatus = SyncStatus.synced,
  });

  factory Devolucion.fromMap(String id, Map<String, dynamic> data) {
    return Devolucion(
      id: id,
      prestamoId: data['prestamoId'] ?? '',
      activoId: data['activoId'] ?? '',
      recibidoPor: data['recibidoPor'] ?? '',
      fechaDevolucion: _convertirFecha(data['fechaDevolucion']),
      tieneNovedad: data['tieneNovedad'] ?? false,
      descripcionNovedad: data['descripcionNovedad'],
      syncStatus: SyncStatus.values.firstWhere(
        (estado) => estado.name == data['syncStatus'],
        orElse: () => SyncStatus.synced,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'prestamoId': prestamoId,
      'activoId': activoId,
      'recibidoPor': recibidoPor,
      'fechaDevolucion': Timestamp.fromDate(fechaDevolucion),
      'tieneNovedad': tieneNovedad,
      'descripcionNovedad': descripcionNovedad,
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