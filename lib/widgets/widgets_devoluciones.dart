import 'package:flutter/material.dart';

class AccesoRestringidoDevoluciones extends StatelessWidget {
  const AccesoRestringidoDevoluciones({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline,
              size: 56,
              color: Colors.red,
            ),
            SizedBox(height: 16),
            Text(
              'Acceso restringido',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Solo el encargado de inventario puede confirmar devoluciones.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class BannerPendientesSincronizacion extends StatelessWidget {
  final int cantidadPendientes;
  final bool sincronizando;
  final VoidCallback? onSincronizar;

  const BannerPendientesSincronizacion({
    super.key,
    required this.cantidadPendientes,
    required this.sincronizando,
    required this.onSincronizar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: Colors.orange.shade100,
      child: Row(
        children: [
          const Icon(
            Icons.cloud_upload_outlined,
            color: Colors.orange,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$cantidadPendientes devolución(es) pendiente(s) de sincronización.',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          FilledButton.tonal(
            onPressed: sincronizando ? null : onSincronizar,
            child: sincronizando
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Text('Sincronizar'),
          ),
        ],
      ),
    );
  }
}

class TarjetaDevolucionPendiente extends StatelessWidget {
  final String nombreActivo;

  const TarjetaDevolucionPendiente({
    super.key,
    required this.nombreActivo,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(
          Icons.cloud_off_outlined,
          color: Colors.orange,
        ),
        title: Text(nombreActivo),
        subtitle: const Text('Pendiente de sincronización'),
        trailing: const Chip(
          label: Text('Pendiente'),
        ),
      ),
    );
  }
}

class FormularioNovedadDevolucion extends StatefulWidget {
  const FormularioNovedadDevolucion({super.key});

  @override
  State<FormularioNovedadDevolucion> createState() =>
      _FormularioNovedadDevolucionState();
}

class _FormularioNovedadDevolucionState
    extends State<FormularioNovedadDevolucion> {
  bool tieneNovedad = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CheckboxListTile(
          title: const Text('El activo presenta novedad'),
          value: tieneNovedad,
          onChanged: (valor) {
            setState(() {
              tieneNovedad = valor ?? false;
            });
          },
        ),
        if (tieneNovedad)
          const TextField(
            decoration: InputDecoration(
              labelText: 'Descripción de la novedad',
              border: OutlineInputBorder(),
            ),
          ),
      ],
    );
  }
}