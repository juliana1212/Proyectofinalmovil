import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/enums.dart';
import '../models/perfil_usuario.dart';

class HistorialPrestamosPage extends StatefulWidget {
  const HistorialPrestamosPage({super.key});

  @override
  State<HistorialPrestamosPage> createState() =>
      _HistorialPrestamosPageState();
}

class _HistorialPrestamosPageState
    extends State<HistorialPrestamosPage> {
  late Future<PerfilUsuario?> perfilFuture;

  String filtroEstado = 'todos';

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

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'activo':
        return Colors.blue;
      case 'vencido':
        return Colors.red;
      case 'devuelto':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _iconoEstado(String estado) {
    switch (estado) {
      case 'activo':
        return Icons.assignment_outlined;
      case 'vencido':
        return Icons.warning_amber_outlined;
      case 'devuelto':
        return Icons.assignment_turned_in_outlined;
      default:
        return Icons.help_outline;
    }
  }

  String _textoEstado(String estado) {
    switch (estado) {
      case 'activo':
        return 'Activo';
      case 'vencido':
        return 'Vencido';
      case 'devuelto':
        return 'Devuelto';
      default:
        return estado;
    }
  }

  DateTime? _convertirFecha(dynamic fecha) {
    if (fecha is Timestamp) {
      return fecha.toDate();
    }

    if (fecha is DateTime) {
      return fecha;
    }

    return null;
  }

  String _formatearFecha(dynamic fecha) {
    final fechaConvertida = _convertirFecha(fecha);

    if (fechaConvertida == null) {
      return 'Sin registro';
    }

    final dia = fechaConvertida.day.toString().padLeft(2, '0');
    final mes = fechaConvertida.month.toString().padLeft(2, '0');
    final anio = fechaConvertida.year.toString();

    final hora = fechaConvertida.hour.toString().padLeft(2, '0');
    final minutos = fechaConvertida.minute.toString().padLeft(2, '0');

    return '$dia/$mes/$anio - $hora:$minutos';
  }

  Widget _filtros() {
    final filtros = [
      {'valor': 'todos', 'texto': 'Todos'},
      {'valor': 'activo', 'texto': 'Activos'},
      {'valor': 'vencido', 'texto': 'Vencidos'},
      {'valor': 'devuelto', 'texto': 'Devueltos'},
    ];

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
          children: filtros.map((filtro) {
            final valor = filtro['valor']!;
            final texto = filtro['texto']!;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(texto),
                selected: filtroEstado == valor,
                onSelected: (seleccionado) {
                  if (seleccionado) {
                    setState(() {
                      filtroEstado = valor;
                    });
                  }
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<List<DocumentSnapshot<Map<String, dynamic>>>>
      _obtenerDatosRelacionados(
    String activoId,
    String usuarioId,
  ) {
    return Future.wait([
      FirebaseFirestore.instance
          .collection('activos')
          .doc(activoId)
          .get(),
      FirebaseFirestore.instance
          .collection('users')
          .doc(usuarioId)
          .get(),
    ]);
  }

  Widget _tarjetaPrestamo(
    QueryDocumentSnapshot<Map<String, dynamic>> documento,
  ) {
    final datos = documento.data();

    final activoId = (datos['activoId'] ?? '').toString();
    final usuarioId = (datos['usuarioId'] ?? '').toString();
    final estado = (datos['estado'] ?? '').toString();

    final colorEstado = _colorEstado(estado);

    return FutureBuilder<List<DocumentSnapshot<Map<String, dynamic>>>>(
      future: _obtenerDatosRelacionados(activoId, usuarioId),
      builder: (context, snapshot) {
        final datosActivo = snapshot.data?[0].data();
        final datosUsuario = snapshot.data?[1].data();

        final nombreActivo =
            (datosActivo?['nombre'] ?? 'Activo: $activoId').toString();

        final nombreUsuario =
            (datosUsuario?['nombre'] ?? 'Usuario: $usuarioId').toString();

        final correoUsuario =
            (datosUsuario?['correo'] ?? datosUsuario?['email'] ?? '')
                .toString();

        return Card(
          margin: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 7,
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _iconoEstado(estado),
                      color: colorEstado,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        nombreActivo,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Chip(
                      label: Text(
                        _textoEstado(estado),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      backgroundColor: colorEstado,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Solicitado por: $nombreUsuario',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (correoUsuario.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    correoUsuario,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 13,
                    ),
                  ),
                ],
                const Divider(height: 24),
                Text(
                  'Fecha de solicitud: ${_formatearFecha(datos['fechaSolicitud'])}',
                ),
                const SizedBox(height: 5),
                Text(
                  'Fecha límite: ${_formatearFecha(datos['fechaVencimiento'])}',
                ),
                if (estado == 'devuelto') ...[
                  const SizedBox(height: 5),
                  Text(
                    'Fecha de devolución: ${_formatearFecha(datos['fechaDevolucion'])}',
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _listaHistorial() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('prestamos')
          .snapshots(),
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
                'Error al cargar historial: ${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final documentos = snapshot.data?.docs ?? [];

        final filtrados = documentos.where((documento) {
          if (filtroEstado == 'todos') {
            return true;
          }

          return documento.data()['estado'] == filtroEstado;
        }).toList();

        filtrados.sort((a, b) {
          final fechaA = _convertirFecha(a.data()['fechaSolicitud']);
          final fechaB = _convertirFecha(b.data()['fechaSolicitud']);

          if (fechaA == null && fechaB == null) {
            return 0;
          }

          if (fechaA == null) {
            return 1;
          }

          if (fechaB == null) {
            return -1;
          }

          return fechaB.compareTo(fechaA);
        });

        if (filtrados.isEmpty) {
          return const Center(
            child: Text(
              'No hay préstamos registrados para este filtro.',
              textAlign: TextAlign.center,
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(
            top: 8,
            bottom: 18,
          ),
          itemCount: filtrados.length,
          itemBuilder: (context, index) {
            return _tarjetaPrestamo(filtrados[index]);
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

        final puedeConsultar = perfil != null &&
            perfil.estado == AccountStatus.active &&
            perfil.role == UserRole.encargadoInventario;

        if (!puedeConsultar) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Historial de préstamos'),
            ),
            body: const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Acceso restringido. Solo el encargado de inventario '
                  'puede consultar el historial.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Historial de préstamos'),
          ),
          body: Column(
            children: [
              _filtros(),
              Expanded(
                child: _listaHistorial(),
              ),
            ],
          ),
        );
      },
    );
  }
}