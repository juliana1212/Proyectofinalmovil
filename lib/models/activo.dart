// lib/models/activo.dart
 
class Activo {
  final String id;
  final String nombre;
  final String descripcion;
  final String categoria;
  final String estado; // "disponible", "prestado", "vencido"
  final String syncStatus;
  final DateTime? fechaVencimiento;
 
  Activo({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.categoria,
    required this.estado,
    this.syncStatus = 'synced',
    this.fechaVencimiento,
  });
 
  factory Activo.fromMap(String id, Map<String, dynamic> data) {
    return Activo(
      id: id,
      nombre: data['nombre'] ?? '',
      descripcion: data['descripcion'] ?? '',
      categoria: data['categoria'] ?? '',
      estado: data['estado'] ?? 'disponible',
      syncStatus: data['syncStatus'] ?? 'synced',
      fechaVencimiento: data['fechaVencimiento'] != null
          ? (data['fechaVencimiento'] as dynamic).toDate()
          : null,
    );
  }
 
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'categoria': categoria,
      'estado': estado,
      'syncStatus': syncStatus,
      if (fechaVencimiento != null) 'fechaVencimiento': fechaVencimiento,
    };
  }
}