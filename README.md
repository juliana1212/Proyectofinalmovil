# Control de activos y préstamos institucionales

Aplicación móvil desarrollada en Flutter para administrar activos institucionales y controlar préstamos, devoluciones, vencimientos y mantenimientos.

## Integrantes

- Natalia
- Juliana
- Andrea
- Angie

## Proyecto asignado

Equipo 3 - Control de activos y préstamos institucionales.

## Roles mínimos

- Solicitante
- Encargado de inventario
- Administrador

## Entidades principales

- Usuario
- Activo
- Préstamo
- Devolución
- Mantenimiento
- Historial

## Estados mínimos

- Disponible
- Prestado
- Vencido
- Devuelto
- En mantenimiento
- Dado de baja

## Flujo principal esperado

Login → consultar activos disponibles → seleccionar activo → solicitar préstamo → validar préstamo pendiente o activo.

## Reglas de negocio mínimas

1. No se puede solicitar préstamo de un activo que esté prestado, vencido, en mantenimiento o dado de baja.
2. Un usuario no puede tener más de dos préstamos activos.
3. Una devolución con novedad debe crear automáticamente un registro de mantenimiento.
4. Un préstamo vencido debe aparecer con estado visual diferente.
5. Un activo devuelto debe volver a disponible solo si no tiene novedad.
6. Solo el encargado de inventario puede confirmar la devolución.