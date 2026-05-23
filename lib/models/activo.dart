class Activo {
  final String id;
  final String nombre;
  final String descripcion;
  final String categoria;
  String estado; // mutable para actualizar estado
  final String syncStatus;

  Activo({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.categoria,
    required this.estado,
    this.syncStatus = "synced",
  });

  factory Activo.fromMap(String id, Map<String, dynamic> data) {
    return Activo(
      id: id,
      nombre: data['nombre'] ?? '',
      descripcion: data['descripcion'] ?? '',
      categoria: data['categoria'] ?? '',
      estado: data['estado'] ?? 'disponible',
      syncStatus: data['syncStatus'] ?? 'synced',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'categoria': categoria,
      'estado': estado,
      'syncStatus': syncStatus,
    };
  }
}