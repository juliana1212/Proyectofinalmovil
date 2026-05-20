import 'enums.dart';

class Prestamo {
  final String id;
  final String activoId;
  final String usuarioId;
  final DateTime fechaSolicitud;
  final DateTime fechaVencimiento;
  final LoanStatus estado;
  final SyncStatus syncStatus;

  Prestamo({
    required this.id,
    required this.activoId,
    required this.usuarioId,
    required this.fechaSolicitud,
    required this.fechaVencimiento,
    required this.estado,
    required this.syncStatus,
  });
}