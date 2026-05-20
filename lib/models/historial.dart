class Historial {
  final String id;
  final String entidadId;
  final String tipoEntidad;
  final String accion;
  final String usuarioId;
  final DateTime fechaCreacion;

  Historial({
    required this.id,
    required this.entidadId,
    required this.tipoEntidad,
    required this.accion,
    required this.usuarioId,
    required this.fechaCreacion,
  });
}