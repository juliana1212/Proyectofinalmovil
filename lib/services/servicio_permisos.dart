// lib/services/servicio_permisos.dart
import '../models/perfil_usuario.dart';

class ServicioPermisos {
  // Permite al usuario acceder al módulo principal
  bool puedeAccederModuloPrincipal(PerfilUsuario user) {
    return user.estado == 'active';
  }

  // Permite al usuario solicitar un préstamo
  bool puedeCrearSolicitud(PerfilUsuario user) {
    return user.estado == 'active' && user.role == 'solicitante';
  }

  // Permite al usuario aprobar préstamos
  bool puedeAprobarSolicitud(PerfilUsuario user) {
    return user.estado == 'active' && user.role == 'encargadoInventario';
  }

  // Permite al usuario gestionar préstamos
  bool puedeGestionarUsuario(PerfilUsuario user) {
    return user.estado == 'active' && user.role == 'administrador';
  }
}