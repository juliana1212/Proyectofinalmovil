// lib/pages/activos_page.dart
import 'package:flutter/material.dart';
import '../services/servicio_activos.dart';
import '../services/servicio_prestamos.dart';
import '../models/activo.dart';

class ActivosPage extends StatelessWidget {
  const ActivosPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final servicioActivos = ServicioActivos();
    final servicioPrestamos = ServicioPrestamos();

    // ID del usuario logueado (temporal)
    final String usuarioId = 'olhl2pxznrZnHwdBz5IQ7CjyCNT2';

    return Scaffold(
      appBar: AppBar(title: const Text('Activos Disponibles')),
      body: StreamBuilder<List<Activo>>(
        stream: servicioActivos.obtenerActivos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay activos disponibles'));
          }

          final activos = snapshot.data!;
          return ListView.builder(
            itemCount: activos.length,
            itemBuilder: (context, index) {
              final activo = activos[index];
              bool disponible = activo.estado == "disponible";

              return ListTile(
                title: Text(
                  activo.nombre,
                  style: TextStyle(
                    color: disponible ? Colors.black : Colors.grey,
                  ),
                ),
                subtitle: Text("${activo.categoria} - ${activo.estado}"),
                enabled: disponible,
                onTap: disponible
                    ? () async {
                        try {
                          final success = await servicioPrestamos
                              .solicitarPrestamo(activo.id, usuarioId);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(success
                                  ? '${activo.nombre} solicitado con éxito'
                                  : 'No se pudo solicitar'),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.toString())),
                          );
                        }
                      }
                    : null,
              );
            },
          );
        },
      ),
    );
  }
}