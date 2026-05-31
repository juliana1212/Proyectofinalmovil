# Bugs backlog

## Proyecto

**Equipo 3 - Control de activos y préstamos institucionales**

Este archivo registra errores encontrados durante el desarrollo y las pruebas de la aplicación. También se documenta su estado actual para dejar evidencia del proceso de revisión y corrección.

## 1. Errores corregidos

| ID     | Descripción                                                                                                                          | Prioridad | Responsable | Estado    | Solución aplicada                                                                                                 |
| ------ | ------------------------------------------------------------------------------------------------------------------------------------ | --------- | ----------- | --------- | ----------------------------------------------------------------------------------------------------------------- |
| BUG-01 | Al registrar un usuario, era necesario asegurar que quedara como solicitante y pendiente de aprobación.                              | Alta      | Equipo      | Corregido | Se guardó el usuario con `role: solicitante` y `status: pendingApproval`.                                         |
| BUG-02 | Algunos mensajes de login no eran claros para el usuario.                                                                            | Media     | Equipo      | Corregido | Se agregaron mensajes para contraseña incorrecta, usuario no encontrado, correo inválido y usuario deshabilitado. |
| BUG-03 | El conteo de categorías podía mostrar más activos de los realmente disponibles.                                                      | Media     | Equipo      | Corregido | Se ajustó el conteo para considerar solo activos disponibles y con cantidad mayor a cero.                         |
| BUG-04 | En devoluciones podía quedar una devolución local pendiente aunque el préstamo ya estuviera procesado.                               | Alta      | Juliana     | Corregido | Se ajustó la sincronización para limpiar registros locales cuando el préstamo ya está devuelto.                   |
| BUG-05 | La pantalla de devoluciones podía mostrar pendientes de sincronización antiguos guardados localmente.                                | Media     | Juliana     | Corregido | Se revisó el flujo de sincronización y se agregó manejo para registros ya procesados.                             |
| BUG-06 | Al tocar varias veces rápido un activo disponible, se podía intentar procesar más de una solicitud.                                  | Media     | Juliana     | Corregido | Se agregó bloqueo temporal mientras se procesa la solicitud de préstamo.                                          |
| BUG-07 | Las notificaciones internas no debían bloquear el flujo principal si Firestore fallaba.                                              | Media     | Juliana     | Corregido | Se manejó la creación de notificaciones dentro de `try/catch` para que no afecte registro, préstamo o devolución. |
| BUG-08 | La sección inicial de notificaciones ocupaba espacio en el home y podía afectar la visualización de activos.                         | Baja      | Juliana     | Corregido | Se cambió por una campanita de notificaciones con modal desplegable.                                              |
| BUG-09 | Al agregar el nivel de cumplimiento, la pantalla de préstamos debía seguir mostrando solo activos o vencidos, sin mezclar devueltos. | Media     | Juliana     | Corregido | Se separó la consulta general del historial y la lista visible de préstamos activos o vencidos.                   |
| BUG-10 | Algunos archivos requerían formato después de los cambios.                                                                           | Baja      | Equipo      | Corregido | Se ejecutó `dart format` en los archivos modificados.                                                             |

## 2. Riesgos conocidos

| ID      | Descripción                                                                                  | Prioridad | Estado                 | Observación                                                                     |
| ------- | -------------------------------------------------------------------------------------------- | --------- | ---------------------- | ------------------------------------------------------------------------------- |
| RISK-01 | La generación del APK puede tardar por descarga de Gradle.                                   | Media     | Pendiente de confirmar | Se debe probar antes de la entrega final.                                       |
| RISK-02 | Si Firestore tiene reglas muy restrictivas, podrían fallar escrituras en colecciones nuevas. | Media     | Controlado             | Durante las pruebas se verificó la creación de `notificaciones`.                |
| RISK-03 | En pruebas web, el navegador puede conservar datos locales antiguos.                         | Baja      | Controlado             | Se puede limpiar almacenamiento del sitio si se requiere una prueba desde cero. |
| RISK-04 | Algunos datos de prueba dependen de usuarios y activos cargados en Firestore.                | Baja      | Controlado             | Se recomienda mantener usuarios y activos de prueba antes de la sustentación.   |

## 3. Pendientes antes de entrega

| ID      | Tarea                                                          | Prioridad | Estado     |
| ------- | -------------------------------------------------------------- | --------- | ---------- |
| TODO-01 | Generar APK final o debug para entrega.                        | Alta      | Pendiente  |
| TODO-02 | Completar README con usuarios de prueba y explicación técnica. | Alta      | Pendiente  |
| TODO-03 | Ejecutar una prueba general con los tres roles.                | Alta      | Pendiente  |
| TODO-04 | Guardar evidencia final de `flutter test`.                     | Media     | Completado |
| TODO-05 | Guardar evidencia final de `flutter analyze`.                  | Media     | Completado |

## 4. Estado general

La mayoría de errores encontrados durante el desarrollo fueron corregidos. La aplicación ya permite ejecutar el flujo principal del sistema de préstamos institucionales: registro, aprobación de usuarios, consulta de activos, solicitud de préstamos, control de vencimientos, devolución, mantenimiento, historial, sincronización y notificaciones internas.

El punto principal pendiente antes de la entrega es confirmar la generación del APK y completar el README final.
