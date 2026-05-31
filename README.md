# Control de activos y préstamos institucionales

## Equipo 3

Aplicación móvil desarrollada en Flutter para administrar activos institucionales y controlar préstamos, devoluciones, vencimientos y mantenimiento dentro de un entorno universitario.

El sistema permite que los estudiantes consulten activos disponibles, soliciten préstamos y revisen sus préstamos activos. También permite que el encargado de inventario confirme devoluciones, registre novedades y gestione activos. El administrador puede aprobar, bloquear o activar cuentas de usuario.

## Descripción del problema

En una institución universitaria se prestan activos como tabletas, computadores, cámaras, micrófonos, proyectores u otros equipos. Si este proceso se realiza de forma manual, pueden aparecer problemas como pérdida de control sobre quién tiene cada activo, vencimientos no identificados, inventario desactualizado y poca claridad sobre el estado real de los usuarios y los préstamos.

Esta aplicación busca organizar ese proceso mediante una app móvil con autenticación, roles, control de inventario, reglas de negocio, historial, persistencia local y sincronización con Firebase.

## Tecnologías usadas

* Flutter
* Dart
* Firebase Authentication
* Cloud Firestore
* Drift / SQLite
* SharedPreferences
* connectivity_plus
* Flutter test
* Widget tests

## Roles implementados

| Rol                     | Descripción                                                                           |
| ----------------------- | ------------------------------------------------------------------------------------- |
| Solicitante             | Usuario estudiante que puede consultar activos disponibles y solicitar préstamos.     |
| Encargado de inventario | Usuario encargado de confirmar devoluciones, registrar novedades y gestionar activos. |
| Administrador           | Usuario que aprueba, bloquea o activa cuentas de usuario.                             |

## Estados de cuenta

| Estado          | Comportamiento                                                          |
| --------------- | ----------------------------------------------------------------------- |
| pendingApproval | El usuario está registrado, pero aún no puede usar el módulo principal. |
| active          | El usuario puede ingresar y usar la app según su rol.                   |
| blocked         | El usuario no puede acceder al módulo principal.                        |

## Entidades principales

| Entidad       | Descripción                                                              |
| ------------- | ------------------------------------------------------------------------ |
| Usuario       | Representa a cada persona registrada en la aplicación.                   |
| Activo        | Representa cada equipo o recurso institucional disponible para préstamo. |
| Préstamo      | Registra qué usuario solicitó un activo y hasta cuándo debe devolverlo.  |
| Devolución    | Registra la entrega del activo por parte del usuario.                    |
| Mantenimiento | Se crea cuando una devolución llega con novedad.                         |
| Historial     | Guarda acciones importantes del sistema.                                 |
| Notificación  | Mensaje interno para informar eventos al usuario.                        |

## Modelo en Firestore

La aplicación usa Cloud Firestore para guardar la información remota del sistema.

### Colecciones principales

```text
users
activos
prestamos
devoluciones
mantenimientos
historial
notificaciones
```

### users

Guarda la información del usuario autenticado.

Campos principales:

```text
uid
correo
nombre
role
status
creadoEn
```

### activos

Guarda la información de los activos institucionales.

Campos principales:

```text
nombre
categoria
descripcion
estado
cantidadTotal
cantidadDisponible
cantidadMantenimiento
cantidadBaja
```

### prestamos

Registra los préstamos realizados por los usuarios.

Campos principales:

```text
activoId
usuarioId
fechaSolicitud
fechaVencimiento
fechaDevolucion
estado
```

### devoluciones

Registra las devoluciones confirmadas.

Campos principales:

```text
prestamoId
activoId
recibidoPor
fechaDevolucion
tieneNovedad
descripcionNovedad
syncStatus
```

### mantenimientos

Se crea cuando una devolución tiene novedad.

Campos principales:

```text
activoId
devolucionId
descripcion
creadoPor
fechaCreacion
estado
syncStatus
```

### historial

Registra movimientos importantes sobre activos y devoluciones.

Campos principales:

```text
entidadId
tipoEntidad
accion
usuarioId
fechaCreacion
syncStatus
```

### notificaciones

Guarda mensajes internos para el usuario.

Campos principales:

```text
usuarioId
titulo
mensaje
tipo
enlace
leida
fechaCreacion
```

## Reglas de negocio

1. Un usuario nuevo queda registrado como solicitante y con estado `pendingApproval`.
2. Un usuario bloqueado no puede acceder al módulo principal.
3. Solo el administrador puede aprobar, bloquear o activar usuarios.
4. No se puede prestar un activo sin unidades disponibles.
5. No se puede prestar un activo en mantenimiento.
6. No se puede prestar un activo dado de baja.
7. Un usuario no puede tener más de dos préstamos activos.
8. Un usuario no puede solicitar el mismo activo si aún no lo ha devuelto.
9. Todo préstamo se crea con fecha de vencimiento de 4 horas.
10. Un préstamo vencido se muestra visualmente diferente.
11. Solo el encargado de inventario puede confirmar devoluciones.
12. Si una devolución no tiene novedad, el activo vuelve al inventario disponible.
13. Si una devolución tiene novedad, se crea un registro de mantenimiento.
14. Cada devolución genera un registro de historial.
15. Las devoluciones sin conexión quedan pendientes de sincronización.
16. Las notificaciones internas no bloquean el flujo principal si fallan.

## Estados de negocio

### Activo

```text
disponible
prestado
mantenimiento
dadoDeBaja
```

### Préstamo

```text
activo
vencido
devuelto
```

### Usuario

```text
pendingApproval
active
blocked
```

### Sincronización

```text
synced
pendingSync
failedSync
```

## Flujo principal

1. El usuario inicia sesión.
2. La app consulta su perfil en Firestore.
3. Según el rol y el estado, se redirige al módulo correspondiente.
4. El solicitante consulta activos disponibles.
5. El solicitante selecciona un activo y solicita el préstamo.
6. El sistema valida disponibilidad, préstamos activos y préstamo duplicado.
7. Se registra el préstamo y se actualiza la cantidad disponible del activo.
8. El estudiante visualiza el préstamo y el tiempo restante.
9. El encargado confirma la devolución.
10. Si no hay novedad, el activo vuelve a disponible.
11. Si hay novedad, se crea mantenimiento.
12. La devolución se registra en historial.
13. Si no hay conexión, la devolución queda pendiente y se sincroniza después.

## Autenticación

La app usa Firebase Authentication con correo y contraseña. Después de iniciar sesión, se consulta el documento del usuario en la colección `users` para saber su rol y estado de cuenta.

No se usa login quemado en el código. El acceso depende del usuario real autenticado y de su perfil guardado en Firestore.

## Roles y permisos

El rol controla la navegación y las acciones disponibles.

* El solicitante puede consultar activos y solicitar préstamos.
* El encargado puede confirmar devoluciones y gestionar inventario.
* El administrador puede gestionar usuarios.
* Un usuario pendiente o bloqueado no puede usar el módulo principal.
* Un usuario sin rol correcto no puede ejecutar acciones críticas.

## Persistencia local

La aplicación usa Drift / SQLite para guardar devoluciones pendientes cuando no hay conexión. Esto permite que una acción importante no se pierda si Firebase falla o si el dispositivo queda sin internet.

También se usa SharedPreferences para guardar la fecha de la última sincronización.

## Sincronización con Firebase

Cuando el encargado confirma una devolución, el sistema intenta enviarla a Firestore. Si no hay conexión o ocurre un error temporal, la devolución queda guardada localmente como pendiente.

Después, desde el botón “Sincronizar”, la app intenta enviar esas devoluciones pendientes a Firestore. Si la sincronización es correcta, el registro local se marca como sincronizado.

## Funcionalidades adicionales

### Notificaciones internas

La app crea notificaciones internas para eventos importantes:

* Registro de usuario.
* Préstamo registrado.
* Devolución confirmada.
* Devolución con novedad.

El estudiante puede verlas desde una campanita en el home y marcarlas como leídas.

### Nivel de cumplimiento del estudiante

En la pantalla de préstamos se muestra un nivel de cumplimiento basado en el historial del usuario:

* Nuevo usuario.
* En buen estado.
* Usuario responsable.
* Requiere atención.

El cálculo tiene en cuenta préstamos activos, vencidos y devueltos.

### Prevención de doble solicitud

Cuando el estudiante toca un activo para solicitarlo, se bloquea temporalmente la acción mientras se procesa la solicitud. Esto evita que se creen préstamos duplicados por tocar dos veces rápido.

## Pruebas

Se ejecutaron pruebas automatizadas con:

```bash
flutter test
```

Resultado obtenido:

```text
00:30 +10: All tests passed!
```

También se ejecutó análisis estático con:

```bash
flutter analyze
```

Las evidencias se guardaron en:

```text
docs/resultado_flutter_test.txt
docs/resultado_flutter_analyze.txt
```

## Documentación adicional

La carpeta `docs/` contiene:

```text
docs/pruebas.md
docs/rc_candidate.md
docs/release_checklist.md
docs/bugs-backlog.md
docs/resultado_flutter_test.txt
docs/resultado_flutter_analyze.txt
```

## Cómo ejecutar el proyecto

1. Clonar el repositorio.

```bash
git clone https://github.com/juliana1212/Proyectofinalmovil.git
```

2. Entrar al proyecto.

```bash
cd Proyectofinalmovil
```

3. Instalar dependencias.

```bash
flutter pub get
```

4. Verificar dispositivos disponibles.

```bash
flutter devices
```

5. Ejecutar en Chrome.

```bash
flutter run -d chrome
```

6. Ejecutar en emulador Android.

```bash
flutter run -d emulator-5554
```

## Cómo generar el APK

Para generar un APK se puede ejecutar:

```bash
flutter build apk
```

La salida esperada es:

```text
build/app/outputs/flutter-apk/app-release.apk
```

Si se entrega APK debug, se debe indicar claramente en la entrega.

## Comandos útiles

```bash
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
flutter run -d emulator-5554
flutter build apk
```

## Credenciales y datos de prueba

Las credenciales de usuarios de prueba no se dejan directamente en este README. Se entregan en un archivo separado.



## Estado final

La aplicación permite ejecutar el flujo principal del Equipo 3 y cuenta con autenticación, roles, reglas de negocio, estados visuales, Firestore, persistencia local, sincronización, pruebas automatizadas y documentación técnica.
