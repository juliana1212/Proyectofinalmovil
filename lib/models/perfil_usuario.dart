import 'enums.dart';

class PerfilUsuario {
  final String uid;
  final String correo;
  final String nombre;
  final UserRole role;
  final AccountStatus estado;

  PerfilUsuario({
    required this.uid,
    required this.correo,
    required this.nombre,
    required this.role,
    required this.estado,
  });

  factory PerfilUsuario.fromMap(Map<String, dynamic> map, String uid) {
    final String roleRaw =
        (map['role'] ?? map['rol'] ?? 'solicitante').toString().trim();

    final String estadoRaw =
        (map['status'] ?? map['estado'] ?? 'active')
            .toString()
            .trim()
            .toLowerCase();

    return PerfilUsuario(
      uid: uid,
      correo: (map['correo'] ?? map['email'] ?? '').toString(),
      nombre: (map['nombre'] ?? map['name'] ?? '').toString(),
      role: UserRole.values.firstWhere(
        (rol) => rol.name.toLowerCase() == roleRaw.toLowerCase(),
        orElse: () => UserRole.solicitante,
      ),
      estado: _convertirEstado(estadoRaw),
    );
  }

  static AccountStatus _convertirEstado(String estadoRaw) {
    if (estadoRaw == 'active' || estadoRaw == 'activo') {
      return AccountStatus.active;
    }

    if (estadoRaw == 'blocked' || estadoRaw == 'bloqueado') {
      return AccountStatus.blocked;
    }

    return AccountStatus.pendingApproval;
  }
}