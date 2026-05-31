# Pruebas realizadas

## Proyecto

**Equipo 3 - Control de activos y préstamos institucionales**

La aplicación permite administrar activos universitarios y controlar préstamos, devoluciones, vencimientos y mantenimiento. Las pruebas se realizaron sobre los flujos principales de la app, validando roles, permisos, reglas de negocio, sincronización y estados visuales.

## 1. Pruebas automatizadas

Se ejecutaron las pruebas automatizadas del proyecto con el comando:

```bash
flutter test
```

Resultado obtenido:

```text
00:30 +10: All tests passed!
```

Esto confirma que las pruebas existentes se ejecutaron correctamente.

### Archivos de pruebas revisados

```text
test/unit/servicio_permisos_test.dart
test/widget/widgets_devoluciones_test.dart
test/widget_test.dart
```

### Tipos de pruebas incluidas

* Pruebas unitarias sobre reglas de permisos.
* Pruebas de widgets relacionados con devoluciones.
* Pruebas básicas de carga de componentes.

## 2. Pruebas manuales por rol

### 2.1 Rol solicitante

**Objetivo:** validar que el usuario estudiante pueda consultar activos y solicitar préstamos.

**Pasos realizados:**

1. Iniciar sesión con un usuario solicitante activo.
2. Entrar al home del estudiante.
3. Revisar la lista de activos disponibles.
4. Seleccionar un activo.
5. Solicitar el préstamo.

**Resultado esperado:**

* El sistema muestra los activos disponibles.
* El usuario puede solicitar un activo disponible.
* El préstamo queda registrado en Firestore.
* El activo descuenta una unidad disponible.
* Se muestra un mensaje de confirmación.
* Se crea una notificación interna para el usuario.

**Resultado obtenido:** correcto.

---

### 2.2 Rol encargado de inventario

**Objetivo:** validar que el encargado pueda confirmar devoluciones.

**Pasos realizados:**

1. Iniciar sesión con usuario encargado.
2. Entrar al módulo de devoluciones.
3. Seleccionar un préstamo activo o vencido.
4. Confirmar la devolución.
5. Elegir si el activo tiene novedad o no.

**Resultado esperado:**

* Solo el encargado puede confirmar devoluciones.
* Si no hay novedad, el activo vuelve a estar disponible.
* Si hay novedad, se genera mantenimiento.
* La devolución queda registrada.
* Se crea historial del movimiento.
* Se muestra mensaje de éxito.

**Resultado obtenido:** correcto.

---

### 2.3 Rol administrador

**Objetivo:** validar la gestión de usuarios.

**Pasos realizados:**

1. Iniciar sesión como administrador.
2. Entrar a gestión de usuarios.
3. Revisar usuarios pendientes, activos y bloqueados.
4. Aprobar, bloquear o activar usuarios.
5. Revisar activos asignados a un usuario.

**Resultado esperado:**

* El administrador puede aprobar usuarios pendientes.
* El administrador puede bloquear usuarios.
* El administrador puede activar usuarios bloqueados.
* Los usuarios bloqueados no pueden acceder al módulo principal.
* Se puede consultar qué usuario tiene activos asignados.

**Resultado obtenido:** correcto.

## 3. Pruebas de reglas de negocio

### Regla 1: no prestar activos no disponibles

**Condición:** el activo está prestado, vencido, en mantenimiento, dado de baja o sin unidades disponibles.

**Resultado esperado:** el sistema no permite solicitar el préstamo.

**Resultado obtenido:** correcto.

---

### Regla 2: máximo dos préstamos activos por usuario

**Condición:** el usuario ya tiene dos préstamos activos.

**Resultado esperado:** el sistema muestra un mensaje indicando que no puede tener más de dos préstamos activos.

**Resultado obtenido:** correcto.

---

### Regla 3: no duplicar préstamo del mismo activo

**Condición:** el usuario ya tiene prestado el mismo activo.

**Resultado esperado:** el sistema no permite solicitar otra vez el mismo activo mientras esté pendiente de devolución.

**Resultado obtenido:** correcto.

---

### Regla 4: devolución con novedad genera mantenimiento

**Condición:** el encargado confirma una devolución marcando que el activo tiene novedad.

**Resultado esperado:** el activo no vuelve directamente a disponible y se crea un registro de mantenimiento.

**Resultado obtenido:** correcto.

---

### Regla 5: devolución sin novedad devuelve el activo al inventario

**Condición:** el encargado confirma una devolución sin novedad.

**Resultado esperado:** el activo aumenta su cantidad disponible y el préstamo queda como devuelto.

**Resultado obtenido:** correcto.

---

### Regla 6: solo el encargado confirma devoluciones

**Condición:** un usuario sin rol de encargado intenta ingresar al módulo de devoluciones.

**Resultado esperado:** se muestra acceso restringido.

**Resultado obtenido:** correcto.

## 4. Pruebas de estados visuales

Se validaron los siguientes estados visuales:

| Estado                      | Resultado                                                         |
| --------------------------- | ----------------------------------------------------------------- |
| Cargando                    | Se muestra indicador de carga al consultar datos.                 |
| Vacío                       | Se muestra mensaje cuando no hay préstamos o activos disponibles. |
| Error                       | Se muestra mensaje si falla la consulta.                          |
| Datos cargados              | Se muestran activos, préstamos, usuarios o devoluciones.          |
| Acceso restringido          | Se muestra cuando el usuario no tiene permisos.                   |
| Sin conexión                | La devolución queda pendiente de sincronización.                  |
| Pendiente de sincronización | Se muestra banner con cantidad pendiente.                         |
| Operación exitosa           | Se muestra mensaje de confirmación.                               |

## 5. Prueba de sincronización y modo offline

**Objetivo:** validar que una devolución pueda quedar guardada localmente cuando no hay conexión.

**Pasos realizados:**

1. Iniciar sesión como encargado.
2. Entrar al módulo de devoluciones.
3. Desactivar la conexión.
4. Confirmar una devolución.
5. Verificar que quede pendiente de sincronización.
6. Activar nuevamente la conexión.
7. Presionar el botón “Sincronizar”.

**Resultado esperado:**

* La app no se bloquea sin conexión.
* La devolución queda guardada localmente.
* Se muestra el contador de pendientes.
* Al recuperar conexión, la devolución se sincroniza con Firestore.
* El contador de pendientes baja a cero.

**Resultado obtenido:** correcto.

## 6. Pruebas de notificaciones internas

Se agregó un módulo de notificaciones internas para que el usuario pueda ver eventos importantes dentro de la app.

### Eventos probados

| Evento                | Resultado esperado                           | Resultado obtenido |
| --------------------- | -------------------------------------------- | ------------------ |
| Registro de usuario   | Se crea notificación de bienvenida.          | Correcto           |
| Solicitud de préstamo | Se crea notificación de préstamo registrado. | Correcto           |
| Devolución confirmada | Se crea notificación de devolución.          | Correcto           |
| Marcar como leída     | La notificación cambia su estado a leída.    | Correcto           |

La colección `notificaciones` se crea automáticamente en Firestore cuando se genera la primera notificación.

## 7. Prueba de nivel de cumplimiento

Se agregó una tarjeta en la pantalla de préstamos del estudiante para mostrar su nivel de cumplimiento.

### Escenarios revisados

| Caso                                         | Resultado esperado             |
| -------------------------------------------- | ------------------------------ |
| Usuario sin historial                        | Muestra “Nuevo usuario”.       |
| Usuario con préstamos activos y sin vencidos | Muestra “En buen estado”.      |
| Usuario con devoluciones correctas           | Muestra “Usuario responsable”. |
| Usuario con vencidos                         | Muestra “Requiere atención”.   |

**Resultado obtenido:** correcto.

## 8. Prueba de prevención de doble solicitud

**Objetivo:** evitar que el usuario genere dos préstamos por tocar dos veces rápido el mismo activo.

**Pasos realizados:**

1. Entrar como estudiante.
2. Seleccionar un activo disponible.
3. Tocar varias veces rápido la tarjeta del activo.

**Resultado esperado:**

* Solo se procesa una solicitud.
* El sistema bloquea temporalmente la acción mientras se guarda el préstamo.
* No se crean préstamos duplicados.

**Resultado obtenido:** correcto.

## 9. Evidencia generada

Se dejaron archivos de evidencia en la carpeta `docs/`:

```text
docs/resultado_flutter_test.txt
docs/resultado_flutter_analyze.txt
```

Estos archivos contienen la salida de las pruebas automatizadas y del análisis estático del proyecto.

## 10. Conclusión

Las pruebas realizadas muestran que la aplicación cumple el flujo principal del Equipo 3: consultar activos disponibles, solicitar préstamos, controlar vencimientos, confirmar devoluciones, manejar mantenimiento, gestionar usuarios por rol y sincronizar devoluciones pendientes. También se validaron mejoras adicionales como notificaciones internas, prevención de doble solicitud y nivel de cumplimiento del estudiante.
