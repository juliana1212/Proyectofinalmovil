import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/activo.dart';
import '../services/servicio_activos.dart';
import '../services/servicio_prestamos.dart';

class ActivosPage extends StatefulWidget {
  const ActivosPage({super.key});

  @override
  State<ActivosPage> createState() => _ActivosPageState();
}

class _ActivosPageState extends State<ActivosPage> {
  final ServicioActivos servicioActivos = ServicioActivos();
  final ServicioPrestamos servicioPrestamos = ServicioPrestamos();

  String categoriaSeleccionada = 'todos';

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

  String _categoriaNormalizada(String categoria) {
  String texto = categoria.trim().toLowerCase();

  if (texto.isEmpty) {
    return 'sin categoria';
  }

  texto = texto
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u');

  return texto;
}

  String _textoCategoria(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'tablets':
        return 'Tablets';
      case 'audio':
        return 'Audio';
      case 'electronica':
        return 'Electrónica';
      case 'computadoras':
        return 'Computadoras';
      case 'tecnologicos':
        return 'Tecnológicos';
      case 'sin categoria':
        return 'Sin categoría';
      default:
        if (categoria.isEmpty) {
          return categoria;
        }

        return '${categoria[0].toUpperCase()}${categoria.substring(1)}';
    }
  }

  Future<void> _solicitarPrestamo(
    BuildContext context,
    Activo activo,
    String usuarioId,
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

      final mensaje = error.toString().replaceFirst('Exception: ', '');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _filtrosCategorias(
    List<Activo> activos,
    List<String> categorias,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            ChoiceChip(
              label: Text('Todos (${activos.length})'),
              selected: categoriaSeleccionada == 'todos',
              onSelected: (seleccionado) {
                if (seleccionado) {
                  setState(() {
                    categoriaSeleccionada = 'todos';
                  });
                }
              },
            ),
            const SizedBox(width: 8),
            ...categorias.map((categoria) {
              final cantidad = activos
                  .where(
                    (activo) =>
                        _categoriaNormalizada(activo.categoria) ==
                        categoria,
                  )
                  .length;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(
                    '${_textoCategoria(categoria)} ($cantidad)',
                  ),
                  selected: categoriaSeleccionada == categoria,
                  onSelected: (seleccionado) {
                    if (seleccionado) {
                      setState(() {
                        categoriaSeleccionada = categoria;
                      });
                    }
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _listaActivos(
    List<Activo> activos,
    String usuarioId,
  ) {
    if (activos.isEmpty) {
      return const Center(
        child: Text(
          'No hay activos en esta categoría.',
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: activos.length,
      separatorBuilder: (context, index) =>
          const Divider(height: 1),
      itemBuilder: (context, index) {
        final activo = activos[index];

        final disponible = activo.estado == 'disponible' &&
            activo.cantidadDisponible > 0;

        final sinUnidades = activo.estado == 'disponible' &&
            activo.cantidadDisponible <= 0;

        final colorEstado = sinUnidades
            ? Colors.grey
            : _colorEstado(activo.estado);

        final textoEstado = sinUnidades
            ? 'Sin unidades'
            : _textoEstado(activo.estado);

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 6,
          ),
          leading: Icon(
            sinUnidades
                ? Icons.inventory_2_outlined
                : _iconoEstado(activo.estado),
            color: colorEstado,
          ),
          title: Text(
            activo.nombre,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: disponible ? Colors.black87 : Colors.grey,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                '${_textoCategoria(_categoriaNormalizada(activo.categoria))} • ${activo.descripcion}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 5),
              Text(
                'Disponibles: ${activo.cantidadDisponible} de ${activo.cantidadTotal}',
                style: TextStyle(
                  color: activo.cantidadDisponible > 0
                      ? Colors.green.shade700
                      : Colors.red.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          trailing: Chip(
            label: Text(
              textoEstado,
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
                  )
              : null,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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

          final categorias = activos
              .map(
                (activo) => _categoriaNormalizada(activo.categoria),
              )
              .toSet()
              .toList()
            ..sort();

          final activosFiltrados = categoriaSeleccionada == 'todos'
              ? activos
              : activos
                  .where(
                    (activo) =>
                        _categoriaNormalizada(activo.categoria) ==
                        categoriaSeleccionada,
                  )
                  .toList();

          return Column(
            children: [
              _filtrosCategorias(activos, categorias),
              Expanded(
                child: _listaActivos(
                  activosFiltrados,
                  usuarioId,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}