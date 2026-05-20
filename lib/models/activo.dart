import 'enums.dart';

class Activo {
  final String id;
  final String nombre;
  final String descripcion;
  final String categoria;
  final AssetStatus estado;
  final SyncStatus syncStatus;

  Activo({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.categoria,
    required this.estado,
    required this.syncStatus,
  });
}