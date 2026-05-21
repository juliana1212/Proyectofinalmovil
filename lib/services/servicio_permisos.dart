import '../models/perfil_usuario.dart';
import '../models/enums.dart';

class ServicioPermisos {
  bool puedeAccederModuloPrincipal(PerfilUsuario user) {
    return user.estado == AccountStatus.active;
  }

  bool puedeCrearSolicitud(PerfilUsuario user) {
    return user.estado == AccountStatus.active &&
           user.rol == UserRole.solicitante;
  }

  bool puedeAprobarSolicitud(PerfilUsuario user) {
    return user.estado == AccountStatus.active &&
           user.rol == UserRole.encargadoInventario;
  }

  bool puedeGestionarUsuarios(PerfilUsuario user) {
    return user.estado == AccountStatus.active &&
           user.rol == UserRole.administrador;
  }
}