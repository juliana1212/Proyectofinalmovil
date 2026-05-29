import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/activo.dart';
import '../models/enums.dart';
import '../models/perfil_usuario.dart';
import '../services/servicio_activos.dart';

class GestionActivosPage extends StatefulWidget {
  const GestionActivosPage({super.key});

  @override
  State<GestionActivosPage> createState() => _GestionActivosPageState();
}

class _GestionActivosPageState extends State<GestionActivosPage> {
  final ServicioActivos servicioActivos = ServicioActivos();

  late Future<PerfilUsuario?> perfilFuture;
  bool procesando = false;

  @override
  void initState() {
    super.initState();
    perfilFuture = _obtenerPerfilActual();
  }

  Future<PerfilUsuario?> _obtenerPerfilActual() async {
    final usuario = FirebaseAuth.instance.currentUser;

    if (usuario == null) {
      return null;
    }

    final documento = await FirebaseFirestore.instance
        .collection('users')
        .doc(usuario.uid)
        .get();

    if (!documento.exists || documento.data() == null) {
      return null;
    }

    return PerfilUsuario.fromMap(documento.data()!, usuario.uid);
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

  String _textoCategoria(String categoria) {
    switch (categoria.trim().toLowerCase()) {
      case 'tablets':
        return 'Tablets';
      case 'audio':
        return 'Audio';
      case 'electronica':
      case 'electrónica':
        return 'Electrónica';
      case 'computadoras':
        return 'Computadoras';
      case 'tecnologicos':
      case 'tecnológicos':
        return 'Tecnológicos';
      default:
        return categoria;
    }
  }

  Future<void> _ejecutarAccion(
    Future<void> Function() accion,
    String mensajeExito,
  ) async {
    setState(() {
      procesando = true;
    });

    try {
      await accion();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensajeExito),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      final mensaje = error.toString().replaceFirst('Exception: ', '');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          procesando = false;
        });
      }
    }
  }

  Future<void> _confirmarDarDeBaja(Activo activo) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Dar de baja unidad'),
          content: Text(
            '¿Estás seguro de dar de baja una unidad de "${activo.nombre}"? '
            'La unidad será retirada definitivamente del inventario disponible.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Dar de baja'),
            ),
          ],
        );
      },
    );

    if (confirmado != true) {
      return;
    }

    await _ejecutarAccion(
      () => servicioActivos.darDeBaja(activo.id),
      'Una unidad de ${activo.nombre} fue dada de baja.',
    );
  }

  Widget _botonesGestion(Activo activo) {
    if (procesando) {
      return const SizedBox.shrink();
    }

    final hayDisponibles = activo.cantidadDisponible > 0;
    final hayEnMantenimiento = activo.cantidadMantenimiento > 0;
    final todasDadasDeBaja =
        activo.cantidadBaja >= activo.cantidadTotal;

    if (todasDadasDeBaja) {
      return const Text(
        'Todas las unidades fueron retiradas definitivamente del inventario.',
        style: TextStyle(
          color: Colors.black54,
          fontSize: 13,
        ),
      );
    }

    final botones = <Widget>[];

    if (hayDisponibles) {
      botones.add(
        OutlinedButton.icon(
          onPressed: () {
            _ejecutarAccion(
              () => servicioActivos.enviarAMantenimiento(activo.id),
              'Una unidad de ${activo.nombre} fue enviada a mantenimiento.',
            );
          },
          icon: const Icon(Icons.build_outlined),
          label: const Text('Mantenimiento'),
        ),
      );

      botones.add(
        FilledButton.tonalIcon(
          onPressed: () {
            _confirmarDarDeBaja(activo);
          },
          icon: const Icon(Icons.block_outlined),
          label: const Text('Dar de baja'),
        ),
      );
    }

    if (hayEnMantenimiento) {
      botones.add(
        FilledButton.icon(
          onPressed: () {
            _ejecutarAccion(
              () => servicioActivos.habilitarActivo(activo.id),
              'Una unidad de ${activo.nombre} fue habilitada nuevamente.',
            );
          },
          icon: const Icon(Icons.check_circle_outline),
          label: const Text('Habilitar unidad'),
        ),
      );
    }

    if (botones.isNotEmpty) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: botones,
      );
    }

    if (activo.cantidadPrestada > 0) {
      return const Text(
        'No hay unidades libres para gestionar mientras estén prestadas.',
        style: TextStyle(
          color: Colors.orange,
          fontSize: 13,
        ),
      );
    }

    return const Text(
      'No hay unidades disponibles para gestionar.',
      style: TextStyle(
        color: Colors.black54,
        fontSize: 13,
      ),
    );
  }

  Widget _indicadorCantidad({
    required String titulo,
    required int cantidad,
    required IconData icono,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(22),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withAlpha(70),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icono,
            size: 17,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            '$titulo: $cantidad',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _listaActivos() {
    return StreamBuilder<List<Activo>>(
      stream: servicioActivos.obtenerActivos(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error al cargar activos: ${snapshot.error}',
              textAlign: TextAlign.center,
            ),
          );
        }

        final activos = snapshot.data ?? [];

        if (activos.isEmpty) {
          return const Center(
            child: Text('No hay activos registrados.'),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: activos.length,
          separatorBuilder: (context, index) {
            return const SizedBox(height: 12);
          },
          itemBuilder: (context, index) {
            final activo = activos[index];
            final color = _colorEstado(activo.estado);

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          color: color,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            activo.nombre,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Chip(
                          label: Text(
                            _textoEstado(activo.estado),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          backgroundColor: color,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_textoCategoria(activo.categoria)} • ${activo.descripcion}',
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Referencia: ${activo.referencia}',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      children: [
                        _indicadorCantidad(
                          titulo: 'Disponibles',
                          cantidad: activo.cantidadDisponible,
                          icono: Icons.check_circle_outline,
                          color: Colors.green,
                        ),
                        _indicadorCantidad(
                          titulo: 'Prestadas',
                          cantidad: activo.cantidadPrestada,
                          icono: Icons.assignment_outlined,
                          color: Colors.orange,
                        ),
                        _indicadorCantidad(
                          titulo: 'Mantenimiento',
                          cantidad: activo.cantidadMantenimiento,
                          icono: Icons.build_outlined,
                          color: Colors.blueGrey,
                        ),
                        _indicadorCantidad(
                          titulo: 'Baja',
                          cantidad: activo.cantidadBaja,
                          icono: Icons.block_outlined,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Total registrado: ${activo.cantidadTotal}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _botonesGestion(activo),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PerfilUsuario?>(
      future: perfilFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final perfil = snapshot.data;

        final puedeGestionar = perfil != null &&
            perfil.estado == AccountStatus.active &&
            perfil.role == UserRole.encargadoInventario;

        if (!puedeGestionar) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Gestión de activos'),
            ),
            body: const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Acceso restringido. Solo el encargado de inventario '
                  'puede gestionar activos.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Gestión de inventario'),
          ),
          body: _listaActivos(),
        );
      },
    );
  }
}