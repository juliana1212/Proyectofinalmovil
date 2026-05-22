import 'enums.dart';

class PerfilUsuario {
  final String uid;
  final String correo;
  final String nombre;
  final UserRole role; // cambiar 'role' a 'UserRole'
  final AccountStatus estado;

  PerfilUsuario({
    required this.uid,
    required this.correo,
    required this.nombre,
    required this.role,
    required this.estado,
  });

  factory PerfilUsuario.fromMap(Map<String, dynamic> map, String uid) {
    return PerfilUsuario(
      uid: uid,
      correo: map['correo'] ?? '',
      nombre: map['nombre'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => UserRole.solicitante,
      ),
      estado: AccountStatus.values.firstWhere(
        (e) => e.name == map['estado'],
        orElse: () => AccountStatus.active,
      ),
    );
  }
}