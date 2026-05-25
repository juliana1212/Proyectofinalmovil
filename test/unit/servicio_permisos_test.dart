import 'package:flutter_test/flutter_test.dart';
import 'package:proyectofinalmovil/models/enums.dart';
import 'package:proyectofinalmovil/models/perfil_usuario.dart';
import 'package:proyectofinalmovil/services/servicio_permisos.dart';

void main() {
  late ServicioPermisos servicioPermisos;

  PerfilUsuario crearUsuario({
    required UserRole rol,
    required AccountStatus estado,
  }) {
    return PerfilUsuario(
      uid: 'usuario-prueba',
      correo: 'usuario@test.com',
      nombre: 'Usuario Prueba',
      role: rol,
      estado: estado,
    );
  }

  setUp(() {
    servicioPermisos = ServicioPermisos();
  });

  group('Permisos para confirmar devoluciones', () {
    test('encargado activo puede confirmar una devolución', () {
      final encargado = crearUsuario(
        rol: UserRole.encargadoInventario,
        estado: AccountStatus.active,
      );

      final resultado =
          servicioPermisos.puedeConfirmarDevolucion(encargado);

      expect(resultado, isTrue);
    });

    test('solicitante activo no puede confirmar una devolución', () {
      final solicitante = crearUsuario(
        rol: UserRole.solicitante,
        estado: AccountStatus.active,
      );

      final resultado =
          servicioPermisos.puedeConfirmarDevolucion(solicitante);

      expect(resultado, isFalse);
    });

    test('encargado bloqueado no puede confirmar una devolución', () {
      final encargadoBloqueado = crearUsuario(
        rol: UserRole.encargadoInventario,
        estado: AccountStatus.blocked,
      );

      final resultado =
          servicioPermisos.puedeConfirmarDevolucion(encargadoBloqueado);

      expect(resultado, isFalse);
    });
  });

  group('Permisos para solicitar préstamos', () {
    test('solicitante activo puede crear una solicitud de préstamo', () {
      final solicitante = crearUsuario(
        rol: UserRole.solicitante,
        estado: AccountStatus.active,
      );

      final resultado = servicioPermisos.puedeCrearSolicitud(solicitante);

      expect(resultado, isTrue);
    });

    test('solicitante pendiente no puede crear una solicitud', () {
      final solicitantePendiente = crearUsuario(
        rol: UserRole.solicitante,
        estado: AccountStatus.pendingApproval,
      );

      final resultado =
          servicioPermisos.puedeCrearSolicitud(solicitantePendiente);

      expect(resultado, isFalse);
    });
  });

  group('Permisos de administración', () {
    test('administrador activo puede gestionar usuarios', () {
      final administrador = crearUsuario(
        rol: UserRole.administrador,
        estado: AccountStatus.active,
      );

      final resultado =
          servicioPermisos.puedeGestionarUsuario(administrador);

      expect(resultado, isTrue);
    });
  });
}