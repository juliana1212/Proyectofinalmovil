class Mantenimiento {
  final String id;
  final String activoId;
  final String descripcion;
  final String creadoPor;
  final DateTime fechaCreacion;
  final bool estaCerrado;

  Mantenimiento({
    required this.id,
    required this.activoId,
    required this.descripcion,
    required this.creadoPor,
    required this.fechaCreacion,
    required this.estaCerrado,
  });
}