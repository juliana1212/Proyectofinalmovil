class Devolucion {
  final String id;
  final String prestamoId;
  final String activoId;
  final String recibidoPor;
  final DateTime fechaDevolucion;
  final bool tieneNovedad;
  final String? descripcionNovedad;

  Devolucion({
    required this.id,
    required this.prestamoId,
    required this.activoId,
    required this.recibidoPor,
    required this.fechaDevolucion,
    required this.tieneNovedad,
    this.descripcionNovedad,
  });
}