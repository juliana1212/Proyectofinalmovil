import '../models/perfil_usuario.dart';
import '../models/enums.dart';

class ServicioPermisos {
  // Verifica si el usuario puede acceder al módulo principal
  bool puedeAccederModuloPrincipal(PerfilUsuario user) {
    return user.estado == AccountStatus.active;
  }

  // Verifica si el usuario puede crear una solicitud de préstamo
  bool puedeCrearSolicitud(PerfilUsuario user) {
    return user.estado == AccountStatus.active && user.role == UserRole.solicitante;
  }

  // Verifica si el usuario puede aprobar una solicitud de préstamo
  bool puedeAprobarSolicitud(PerfilUsuario user) {
    return user.estado == AccountStatus.active && user.role == UserRole.encargadoInventario;
  }

  // Verifica si el usuario puede gestionar usuarios (admin)
  bool puedeGestionarUsuarios(PerfilUsuario user) {
    return user.estado == AccountStatus.active && user.role == UserRole.administrador;
  }
}