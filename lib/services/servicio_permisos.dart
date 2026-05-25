import '../models/enums.dart';
import '../models/perfil_usuario.dart';

class ServicioPermisos {
  // Permite al usuario acceder al módulo principal
  bool puedeAccederModuloPrincipal(PerfilUsuario usuario) {
    return usuario.estado == AccountStatus.active;
  }

  // Permite al solicitante crear una solicitud de préstamo
  bool puedeCrearSolicitud(PerfilUsuario usuario) {
    return usuario.estado == AccountStatus.active &&
        usuario.role == UserRole.solicitante;
  }

  // Permite al encargado de inventario aprobar o gestionar préstamos
  bool puedeAprobarSolicitud(PerfilUsuario usuario) {
    return usuario.estado == AccountStatus.active &&
        usuario.role == UserRole.encargadoInventario;
  }

  // Permite al administrador gestionar usuarios
  bool puedeGestionarUsuario(PerfilUsuario usuario) {
    return usuario.estado == AccountStatus.active &&
        usuario.role == UserRole.administrador;
  }

  // Permite únicamente al encargado de inventario confirmar devoluciones
  bool puedeConfirmarDevolucion(PerfilUsuario usuario) {
    return usuario.estado == AccountStatus.active &&
        usuario.role == UserRole.encargadoInventario;
  }
}