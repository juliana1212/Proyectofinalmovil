import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/activo.dart';
import '../services/servicio_activos.dart';
import '../services/servicio_prestamos.dart';

class ActivosPage extends StatelessWidget {
  const ActivosPage({super.key});

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'disponible':
        return Colors.green;
      case 'prestado':
        return Colors.orange;
      case 'vencido':
        return Colors.red;
      case 'mantenimiento':
        return Colors.blueGrey;
      case 'dadoDeBaja':
        return Colors.black54;
      default:
        return Colors.grey;
    }
  }

  IconData _iconoEstado(String estado) {
    switch (estado) {
      case 'disponible':
        return Icons.check_circle_outline;
      case 'prestado':
        return Icons.lock_outline;
      case 'vencido':
        return Icons.warning_amber_outlined;
      case 'mantenimiento':
        return Icons.build_outlined;
      case 'dadoDeBaja':
        return Icons.block_outlined;
      default:
        return Icons.help_outline;
    }
  }

  String _textoEstado(String estado) {
    switch (estado) {
      case 'disponible':
        return 'Disponible';
      case 'prestado':
        return 'Prestado';
      case 'vencido':
        return 'Vencido';
      case 'mantenimiento':
        return 'En mantenimiento';
      case 'dadoDeBaja':
        return 'Dado de baja';
      default:
        return estado;
    }
  }

  Future<void> _solicitarPrestamo(
    BuildContext context,
    Activo activo,
    String usuarioId,
    ServicioPrestamos servicioPrestamos,
  ) async {
    try {
      await servicioPrestamos.solicitarPrestamo(activo.id, usuarioId);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${activo.nombre} solicitado con éxito.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      if (!context.mounted) return;

      final mensaje =
          error.toString().replaceFirst('Exception: ', '');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final servicioActivos = ServicioActivos();
    final servicioPrestamos = ServicioPrestamos();
    final usuarioId = FirebaseAuth.instance.currentUser?.uid;

    if (usuarioId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Activos disponibles'),
        ),
        body: const Center(
          child: Text(
            'Sesión no válida. Por favor inicia sesión de nuevo.',
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activos disponibles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.assignment_return_outlined),
            tooltip: 'Devoluciones',
            onPressed: () {
              Navigator.pushNamed(context, '/devoluciones');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();

              if (!context.mounted) return;

              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Activo>>(
        stream: servicioActivos.obtenerActivos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Error al cargar activos: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No hay activos registrados.'),
            );
          }

          final activos = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: activos.length,
            separatorBuilder: (context, index) =>
                const Divider(height: 1),
            itemBuilder: (context, index) {
              final activo = activos[index];
              final disponible = activo.estado == 'disponible';
              final colorEstado = _colorEstado(activo.estado);

              return ListTile(
                leading: Icon(
                  _iconoEstado(activo.estado),
                  color: colorEstado,
                ),
                title: Text(
                  activo.nombre,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: disponible ? Colors.black87 : Colors.grey,
                  ),
                ),
                subtitle: Text(
                  '${activo.categoria}  •  ${activo.descripcion}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Chip(
                  label: Text(
                    _textoEstado(activo.estado),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                  backgroundColor: colorEstado,
                  padding: EdgeInsets.zero,
                ),
                enabled: disponible,
                onTap: disponible
                    ? () => _solicitarPrestamo(
                          context,
                          activo,
                          usuarioId,
                          servicioPrestamos,
                        )
                    : null,
              );
            },
          );
        },
      ),
    );
  }
}