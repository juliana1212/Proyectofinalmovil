# Release checklist

## Proyecto

**Equipo 3 - Control de activos y préstamos institucionales**

Este checklist se usa para revisar si la aplicación está lista para entrega y sustentación.

## 1. Revisión general

| Ítem                                       | Estado     | Observación                                                                                   |
| ------------------------------------------ | ---------- | --------------------------------------------------------------------------------------------- |
| El proyecto abre correctamente en Flutter  | Completado | Se ejecutó desde Chrome y emulador.                                                           |
| La estructura del proyecto está organizada | Completado | Se separa en `models`, `pages`, `services`, `widgets`, `data` y `docs`.                       |
| La app no depende de login quemado         | Completado | Usa Firebase Authentication.                                                                  |
| La app usa Firestore                       | Completado | Maneja usuarios, activos, préstamos, devoluciones, mantenimiento, historial y notificaciones. |
| La app tiene roles funcionales             | Completado | Solicitante, encargado de inventario y administrador.                                         |
| La app tiene estados de cuenta             | Completado | `pendingApproval`, `active` y `blocked`.                                                      |

## 2. Autenticación y usuarios

| Ítem                                                | Estado     | Observación                             |
| --------------------------------------------------- | ---------- | --------------------------------------- |
| Login con correo y contraseña                       | Completado | Se valida con Firebase Auth.            |
| Registro de usuario                                 | Completado | El usuario queda como solicitante.      |
| Usuario nuevo queda pendiente de aprobación         | Completado | Se guarda con estado `pendingApproval`. |
| Usuario activo puede ingresar                       | Completado | Se redirige según su rol.               |
| Usuario bloqueado no puede usar el módulo principal | Completado | Se muestra acceso restringido.          |
| Cierre de sesión                                    | Completado | Disponible en los módulos principales.  |

## 3. Roles y permisos

| Rol                     | Funcionalidad validada                               | Estado     |
| ----------------------- | ---------------------------------------------------- | ---------- |
| Solicitante             | Consultar activos disponibles y solicitar préstamos. | Completado |
| Encargado de inventario | Confirmar devoluciones y registrar novedades.        | Completado |
| Administrador           | Aprobar, bloquear y activar usuarios.                | Completado |
| Administrador           | Ver activos asignados a un usuario.                  | Completado |

## 4. Flujo principal del Equipo 3

| Paso                                         | Estado     |
| -------------------------------------------- | ---------- |
| Login del usuario                            | Completado |
| Consulta de activos disponibles              | Completado |
| Selección de activo                          | Completado |
| Solicitud de préstamo                        | Completado |
| Registro del préstamo activo                 | Completado |
| Visualización de préstamo en “Mis préstamos” | Completado |
| Control de tiempo restante                   | Completado |
| Confirmación de devolución por encargado     | Completado |
| Actualización del inventario                 | Completado |
| Creación de mantenimiento cuando hay novedad | Completado |

## 5. Reglas de negocio

| Regla                                                                          | Estado     |
| ------------------------------------------------------------------------------ | ---------- |
| No se puede prestar un activo sin disponibilidad.                              | Completado |
| No se puede prestar un activo en mantenimiento.                                | Completado |
| No se puede prestar un activo dado de baja.                                    | Completado |
| Un usuario no puede tener más de dos préstamos activos.                        | Completado |
| Un usuario no puede solicitar dos veces el mismo activo si aún no lo devuelve. | Completado |
| Una devolución con novedad genera mantenimiento.                               | Completado |
| Una devolución sin novedad devuelve el activo al inventario disponible.        | Completado |
| Solo el encargado puede confirmar devoluciones.                                | Completado |
| El préstamo vencido se muestra visualmente diferente.                          | Completado |

## 6. Persistencia local y sincronización

| Ítem                                                     | Estado     | Observación                           |
| -------------------------------------------------------- | ---------- | ------------------------------------- |
| Existe base local con Drift                              | Completado | Se usa para devoluciones pendientes.  |
| Una devolución puede quedar pendiente si no hay conexión | Completado | Se guarda localmente.                 |
| La UI muestra pendientes de sincronización               | Completado | Se ve el contador y el banner.        |
| Existe botón de sincronización                           | Completado | Permite reintentar envío a Firestore. |
| La última sincronización queda registrada                | Completado | Se usa SharedPreferences.             |
| Se manejan errores temporales de conexión                | Completado | No se bloquea la app.                 |

## 7. Estados visuales

| Estado visual               | Estado     |
| --------------------------- | ---------- |
| Cargando                    | Completado |
| Error                       | Completado |
| Vacío                       | Completado |
| Datos cargados              | Completado |
| Operación exitosa           | Completado |
| Acceso restringido          | Completado |
| Sin conexión                | Completado |
| Pendiente de sincronización | Completado |

## 8. Funcionalidades adicionales

| Funcionalidad                        | Estado     | Observación                                   |
| ------------------------------------ | ---------- | --------------------------------------------- |
| Notificaciones internas              | Completado | Se crean al registrar, prestar o devolver.    |
| Campanita de notificaciones          | Completado | Visible en el home del estudiante.            |
| Marcar notificación como leída       | Completado | Cambia el estado `leida`.                     |
| Nivel de cumplimiento del estudiante | Completado | Se calcula con activos, devueltos y vencidos. |
| Prevención de doble solicitud        | Completado | Evita doble clic sobre el mismo préstamo.     |

## 9. Pruebas

| Ítem              | Estado     | Observación                                                 |
| ----------------- | ---------- | ----------------------------------------------------------- |
| Unit tests        | Completado | Se ejecutaron correctamente.                                |
| Widget tests      | Completado | Se ejecutaron correctamente.                                |
| `flutter test`    | Completado | Resultado: `All tests passed`.                              |
| `flutter analyze` | Completado | Evidencia guardada en `docs/resultado_flutter_analyze.txt`. |



## 10. README y documentación

| Documento                   | Estado     |
| --------------------------- | ---------- |
| `README.md`                 | Pendiente  |
| `docs/pruebas.md`           | Completado |
| `docs/release_checklist.md` | Completado |
| `docs/rc_candidate.md`      | Pendiente  |
| `docs/bugs-backlog.md`      | Pendiente  |

## 11. Decisión del equipo

La aplicación se considera funcional para pruebas finales porque ya permite ejecutar el flujo principal del Equipo 3: consultar activos, solicitar préstamo, visualizar préstamos activos o vencidos, confirmar devoluciones, actualizar inventario, manejar mantenimiento, gestionar usuarios por rol y sincronizar devoluciones pendientes.

Queda pendiente confirmar la generación del APK y terminar el README final.
