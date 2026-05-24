import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/enums.dart';
import '../models/perfil_usuario.dart';
import '../services/servicio_devoluciones.dart';

class DevolucionesPage extends StatefulWidget {
  const DevolucionesPage({super.key});

  @override
  State<DevolucionesPage> createState() => _DevolucionesPageState();
}

class _DevolucionesPageState extends State<DevolucionesPage> {
  final ServicioDevoluciones servicioDevoluciones = ServicioDevoluciones();

  late Future<PerfilUsuario?> perfilFuture;

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

  Future<void> _abrirFormularioDevolucion({
    required String prestamoId,
    required String activoId,
    required PerfilUsuario encargado,
  }) async {
    bool tieneNovedad = false;
    String? mensajeValidacion;
    final controladorNovedad = TextEditingController();

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Confirmar devolución'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Verifica el estado en el que fue entregado el activo.',
                    ),
                    const SizedBox(height: 16),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('El activo presenta novedad'),
                      value: tieneNovedad,
                      onChanged: (valor) {
                        setDialogState(() {
                          tieneNovedad = valor ?? false;
                          mensajeValidacion = null;

                          if (!tieneNovedad) {
                            controladorNovedad.clear();
                          }
                        });
                      },
                    ),
                    if (tieneNovedad) ...[
                      const SizedBox(height: 8),
                      TextField(
                        controller: controladorNovedad,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Descripción de la novedad',
                          hintText: 'Ejemplo: pantalla rota o cargador faltante',
                          border: const OutlineInputBorder(),
                          errorText: mensajeValidacion,
                        ),
                      ),
                    ],
                  ],
                ),
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
                    if (tieneNovedad &&
                        controladorNovedad.text.trim().isEmpty) {
                      setDialogState(() {
                        mensajeValidacion =
                            'Debes describir la novedad encontrada.';
                      });
                      return;
                    }

                    Navigator.pop(dialogContext, true);
                  },
                  child: const Text('Confirmar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmado != true) {
      controladorNovedad.dispose();
      return;
    }

    try {
      await servicioDevoluciones.confirmarDevolucion(
        prestamoId: prestamoId,
        activoId: activoId,
        encargado: encargado,
        tieneNovedad: tieneNovedad,
        descripcionNovedad: controladorNovedad.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tieneNovedad
                ? 'Devolución confirmada. El activo pasó a mantenimiento.'
                : 'Devolución confirmada. El activo está disponible.',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      final mensaje =
          error.toString().replaceFirst('Exception: ', '');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      controladorNovedad.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PerfilUsuario?>(
      future: perfilFuture,
      builder: (context, perfilSnapshot) {
        if (perfilSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (perfilSnapshot.hasError) {
          return const Scaffold(
            body: Center(
              child: Text('Error al consultar el perfil del usuario.'),
            ),
          );
        }

        final perfil = perfilSnapshot.data;

        if (perfil == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Devoluciones')),
            body: const Center(
              child: Text('No se encontró el perfil del usuario.'),
            ),
          );
        }

        final puedeConfirmar =
            perfil.estado == AccountStatus.active &&
            perfil.role == UserRole.encargadoInventario;

        if (!puedeConfirmar) {
          return Scaffold(
            appBar: AppBar(title: const Text('Devoluciones')),
            body: const Center(
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
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Confirmar devoluciones'),
          ),
          body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: servicioDevoluciones.obtenerPrestamosPorDevolver(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error al cargar préstamos: ${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                );
              }

              final documentos = snapshot.data?.docs ?? [];

              if (documentos.isEmpty) {
                return const Center(
                  child: Text(
                    'No hay préstamos pendientes por devolver.',
                    textAlign: TextAlign.center,
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: documentos.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final prestamoDocumento = documentos[index];
                  final datos = prestamoDocumento.data();
                  final activoId = (datos['activoId'] ?? '').toString();
                  final estado = (datos['estado'] ?? '').toString();

                  return Card(
                    child: ListTile(
                      leading: Icon(
                        estado == 'vencido'
                            ? Icons.warning_amber_outlined
                            : Icons.assignment_return_outlined,
                        color: estado == 'vencido'
                            ? Colors.red
                            : Colors.blue,
                      ),
                      title: FutureBuilder<
                          DocumentSnapshot<Map<String, dynamic>>>(
                        future: FirebaseFirestore.instance
                            .collection('activos')
                            .doc(activoId)
                            .get(),
                        builder: (context, activoSnapshot) {
                          final nombre = activoSnapshot.data
                                  ?.data()?['nombre']
                                  ?.toString() ??
                              'Activo $activoId';

                          return Text(
                            nombre,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                      subtitle: Text(
                        estado == 'vencido'
                            ? 'Préstamo vencido'
                            : 'Préstamo activo',
                      ),
                      trailing: FilledButton(
                        onPressed: () {
                          _abrirFormularioDevolucion(
                            prestamoId: prestamoDocumento.id,
                            activoId: activoId,
                            encargado: perfil,
                          );
                        },
                        child: const Text('Devolver'),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}