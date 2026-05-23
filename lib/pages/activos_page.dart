// lib/pages/activos_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/servicio_activos.dart';
import '../services/servicio_prestamos.dart';
import '../models/activo.dart';
 
class ActivosPage extends StatelessWidget {
  const ActivosPage({Key? key}) : super(key: key);
 
  // ── Colores según estado ──────────────────────────────────────────────────
  Color _colorEstado(String estado) {
    switch (estado) {
      case 'disponible':
        return Colors.green;
      case 'prestado':
        return Colors.orange;
      case 'vencido':
        return Colors.red;
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
      default:
        return Icons.help_outline;
    }
  }
 
  // ── Lógica de solicitud ───────────────────────────────────────────────────
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
          content: Text('✅ ${activo.nombre} solicitado con éxito'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      // Extrae el mensaje limpio de la excepción
      final msg = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ $msg'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
 
  @override
  Widget build(BuildContext context) {
    final servicioActivos = ServicioActivos();
    final servicioPrestamos = ServicioPrestamos();
 
    // Obtiene el UID del usuario autenticado (Firebase Auth)
    final String? usuarioId = FirebaseAuth.instance.currentUser?.uid;
 
    if (usuarioId == null) {
      // No debería ocurrir si el login funciona correctamente,
      // pero lo manejamos por seguridad
      return Scaffold(
        appBar: AppBar(title: const Text('Activos Disponibles')),
        body: const Center(
          child: Text('Sesión no válida. Por favor inicia sesión de nuevo.'),
        ),
      );
    }
 
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activos Disponibles'),
        actions: [
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
          // ── Estados de conexión ─────────────────────────────────────────
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
 
          if (snapshot.hasError) {
            return Center(
              child: Text('Error al cargar activos: ${snapshot.error}'),
            );
          }
 
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No hay activos registrados.'),
            );
          }
 
          final activos = snapshot.data!;
 
          // ── Lista ───────────────────────────────────────────────────────
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: activos.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final activo = activos[index];
              final bool disponible = activo.estado == 'disponible';
              final Color colorEstado = _colorEstado(activo.estado);
 
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
                    activo.estado,
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
 