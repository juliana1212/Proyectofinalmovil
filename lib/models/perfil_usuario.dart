import 'enums.dart';

class PerfilUsuario {
  final String uid;
  final String nombre;
  final String correo;
  final UserRole rol;
  final AccountStatus estado;

  PerfilUsuario({
    required this.uid,
    required this.nombre,
    required this.correo,
    required this.rol,
    required this.estado,
  });
}