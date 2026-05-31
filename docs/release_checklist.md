# Release Candidate

## Proyecto

**Equipo 3 - Control de activos y préstamos institucionales**

## Versión evaluada

**Versión candidata:** RC-1
**Fecha de revisión:** 2026
**Estado:** Lista para pruebas finales y sustentación, con validación pendiente de APK final.

## 1. Descripción de la versión

Esta versión candidata reúne las funcionalidades principales del sistema de control de activos y préstamos institucionales. La aplicación permite que los usuarios inicien sesión, consulten activos disponibles, soliciten préstamos, visualicen préstamos activos o vencidos, confirmen devoluciones, administren activos y gestionen usuarios según su rol.

La versión también incluye mejoras de experiencia como notificaciones internas, control visual de vencimientos, nivel de cumplimiento del estudiante y sincronización de devoluciones pendientes.

## 2. Funcionalidades incluidas

### Autenticación y usuarios

* Inicio de sesión con Firebase Authentication.
* Registro de usuarios con correo y contraseña.
* Creación del perfil del usuario en Firestore.
* Registro inicial del usuario como solicitante.
* Estado inicial `pendingApproval`.
* Validación de usuarios activos, pendientes o bloqueados.
* Cierre de sesión.

### Roles implementados

* Solicitante.
* Encargado de inventario.
* Administrador.

Cada rol tiene acceso a pantallas y acciones diferentes. El rol no se usa solo como texto, sino que afecta navegación, acciones permitidas y reglas del sistema.

### Gestión de usuarios

* Visualización de usuarios pendientes, activos y bloqueados.
* Aprobación de usuarios.
* Bloqueo de usuarios.
* Activación de usuarios bloqueados.
* Consulta de activos asignados a cada usuario.

### Gestión de activos

* Consulta de activos institucionales.
* Organización por categorías.
* Visualización de disponibilidad.
* Control de cantidades disponibles, prestadas, en mantenimiento y dadas de baja.
* Gestión de inventario por parte del encargado.

### Préstamos

* Consulta de activos disponibles.
* Solicitud de préstamo por parte del solicitante.
* Validación de disponibilidad.
* Validación de máximo dos préstamos activos por usuario.
* Validación para evitar préstamo duplicado del mismo activo.
* Control de fecha de vencimiento.
* Visualización del tiempo restante.
* Identificación visual de préstamos vencidos.

### Devoluciones

* Confirmación de devoluciones por parte del encargado de inventario.
* Devolución sin novedad: el activo vuelve al inventario disponible.
* Devolución con novedad: se crea mantenimiento.
* Registro de devolución.
* Actualización del préstamo a estado devuelto.
* Registro de historial.

### Persistencia local y sincronización

* Uso de base local para guardar devoluciones pendientes.
* Manejo de devoluciones sin conexión.
* Botón para sincronizar pendientes.
* Visualización de cantidad pendiente de sincronización.
* Registro de última sincronización.
* Manejo de errores temporales de conexión.

### Funcionalidades adicionales

* Notificaciones internas para eventos importantes.
* Campanita de notificaciones en el home del estudiante.
* Marcado de notificaciones como leídas.
* Nivel de cumplimiento del estudiante.
* Prevención de doble solicitud por doble clic.

## 3. Reglas de negocio validadas

| Regla                                                                   | Estado       |
| ----------------------------------------------------------------------- | ------------ |
| No se puede prestar un activo sin unidades disponibles.                 | Implementada |
| No se puede prestar un activo en mantenimiento.                         | Implementada |
| No se puede prestar un activo dado de baja.                             | Implementada |
| Un usuario no puede tener más de dos préstamos activos.                 | Implementada |
| Un usuario no puede solicitar el mismo activo si aún no lo devuelve.    | Implementada |
| Un préstamo vencido se muestra visualmente diferente.                   | Implementada |
| Solo el encargado de inventario puede confirmar devoluciones.           | Implementada |
| Una devolución con novedad genera mantenimiento.                        | Implementada |
| Una devolución sin novedad devuelve el activo al inventario disponible. | Implementada |
| Los usuarios bloqueados no pueden acceder al módulo principal.          | Implementada |

## 4. Estados de negocio

### Activo

* Disponible.
* Prestado.
* En mantenimiento.
* Dado de baja.
* Sin unidades disponibles.

### Préstamo

* Activo.
* Vencido.
* Devuelto.

### Usuario

* Pendiente de aprobación.
* Activo.
* Bloqueado.

### Devolución local

* Pendiente de sincronización.
* Sincronizada.
* Fallida o pendiente por error temporal.

## 5. Pruebas realizadas

Se ejecutaron pruebas automatizadas con:

```bash
flutter test
```

Resultado:

```text
00:30 +10: All tests passed!
```

También se ejecutó análisis estático con:

```bash
flutter analyze
```

La evidencia se dejó en la carpeta `docs`.

## 6. Riesgos conocidos

| Riesgo                                                                                              | Impacto | Estado                                             |
| --------------------------------------------------------------------------------------------------- | ------- | -------------------------------------------------- |
| La generación del APK puede tardar por descarga de Gradle o dependencias.                           | Medio   | Pendiente de confirmar al final.                   |
| Si las reglas de Firestore son muy restrictivas, pueden fallar escrituras en colecciones nuevas.    | Medio   | Revisado durante pruebas con notificaciones.       |
| En navegador, los datos locales de pruebas pueden quedar almacenados y mostrar pendientes antiguos. | Bajo    | Se corrigió el manejo de pendientes ya procesados. |
| Algunas pruebas manuales dependen de datos existentes en Firestore.                                 | Bajo    | Se probará con usuarios y activos preparados.      |

## 7. Funcionalidades pendientes o futuras

Estas funcionalidades no son necesarias para aprobar la versión, pero podrían agregarse en una versión posterior:

* Envío de correo real mediante backend o Cloud Functions.
* Generación automática de QR para encuesta externa.
* Panel administrativo de reportes por fechas.
* Exportación de historial.
* Notificaciones push reales.
* APK release firmado.

## 8. Decisión del equipo

La versión **RC-1** se considera apta para pruebas finales y sustentación porque cumple el flujo principal del Equipo 3: login, roles, activos, préstamos, devoluciones, mantenimiento, historial, sincronización y pruebas automatizadas.

