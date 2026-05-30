import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/enums.dart';
import '../models/perfil_usuario.dart';

class HistorialColors {
  static const Color fondoGeneral = Color(0xFFF3F5FC);
  static const Color fondoTarjeta = Color(0xFFFFFFFF);

  static const Color acentoPrincipal = Color(0xFFFF8A73);
  static const Color acentoSuave = Color(0xFFFFE5DE);

  static const Color azulSuave = Color(0xFFE9EEFF);
  static const Color cremaSuave = Color(0xFFFFF1E4);
  static const Color verdeSuave = Color(0xFFE8F6EC);
  static const Color grisSuave = Color(0xFFF1F2F6);

  static const Color textoPrincipal = Color(0xFF24324A);
  static const Color textoSecundario = Color(0xFF8C93A8);

  static const Color verde = Color(0xFF45B75A);
  static const Color naranja = Color(0xFFFF9800);
  static const Color rojo = Color(0xFFE85D5D);
  static const Color gris = Color(0xFF8C8C8C);
  static const Color azul = Color(0xFF4C79D8);
}

class HistorialPrestamosPage extends StatefulWidget {
  const HistorialPrestamosPage({super.key});

  @override
  State<HistorialPrestamosPage> createState() =>
      _HistorialPrestamosPageState();
}

class _HistorialPrestamosPageState extends State<HistorialPrestamosPage> {
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

  String _normalizarTexto(String texto) {
    return texto
        .trim()
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u');
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

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'activo':
        return HistorialColors.azul;
      case 'vencido':
        return HistorialColors.rojo;
      case 'devuelto':
        return HistorialColors.verde;
      default:
        return HistorialColors.gris;
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

  String _textoCategoria(String categoria) {
    switch (_normalizarTexto(categoria)) {
      case 'audio':
        return 'Audio';
      case 'computadoras':
        return 'Computadoras';
      case 'electronica':
        return 'Electrónica';
      case 'tablets':
        return 'Tablets';
      case 'tecnologicos':
        return 'Tecnológicos';
      case 'sin categoria':
      case '':
        return 'Sin categoría';
      default:
        return categoria;
    }
  }

  IconData _iconoCategoria({
    required String categoria,
    required String nombreActivo,
  }) {
    final categoriaNormalizada = _normalizarTexto(categoria);
    final nombreNormalizado = _normalizarTexto(nombreActivo);

    if (categoriaNormalizada == 'audio') {
      if (nombreNormalizado.contains('microfono')) {
        return Icons.mic_none_outlined;
      }

      return Icons.speaker_outlined;
    }

    switch (categoriaNormalizada) {
      case 'computadoras':
        return Icons.laptop_mac;
      case 'electronica':
        return Icons.videocam_outlined;
      case 'tablets':
        return Icons.tablet_android;
      case 'tecnologicos':
        return Icons.memory_outlined;
      default:
        return Icons.inventory_2_outlined;
    }
  }

  Color _colorDecorativo(int index) {
    if (index % 4 == 0) {
      return HistorialColors.azulSuave;
    }

    if (index % 4 == 1) {
      return HistorialColors.cremaSuave;
    }

    if (index % 4 == 2) {
      return HistorialColors.verdeSuave;
    }

    return HistorialColors.acentoSuave;
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

    return '$dia/$mes/$anio · $hora:$minutos';
  }

  String _estadoVisible(Map<String, dynamic> datos) {
    final estadoOriginal = (datos['estado'] ?? '').toString();
    final fechaVencimiento = _convertirFecha(datos['fechaVencimiento']);

    final estaVencidoVisualmente = estadoOriginal == 'activo' &&
        fechaVencimiento != null &&
        DateTime.now().isAfter(fechaVencimiento);

    if (estaVencidoVisualmente) {
      return 'vencido';
    }

    return estadoOriginal;
  }

  String _mensajeRecordatorio({
    required String estado,
    required dynamic fechaVencimiento,
  }) {
    final fecha = _convertirFecha(fechaVencimiento);

    if (fecha == null) {
      return 'No hay fecha límite registrada.';
    }

    if (estado == 'vencido') {
      return 'Este préstamo ya superó la fecha límite de devolución.';
    }

    final diferencia = fecha.difference(DateTime.now());

    if (diferencia.isNegative) {
      return 'Este préstamo ya superó la fecha límite de devolución.';
    }

    final horas = diferencia.inHours;
    final minutos = diferencia.inMinutes.remainder(60);

    return 'Debe devolverse en ${horas}h ${minutos}min.';
  }

  Future<List<DocumentSnapshot<Map<String, dynamic>>>>
      _obtenerDatosRelacionados(
    String activoId,
    String usuarioId,
  ) {
    return Future.wait([
      FirebaseFirestore.instance.collection('activos').doc(activoId).get(),
      FirebaseFirestore.instance.collection('users').doc(usuarioId).get(),
    ]);
  }

  Widget _filtros() {
    final filtros = [
      {
        'valor': 'todos',
        'texto': 'Todos',
        'icono': Icons.done_all_outlined,
      },
      {
        'valor': 'activo',
        'texto': 'Activos',
        'icono': Icons.assignment_outlined,
      },
      {
        'valor': 'vencido',
        'texto': 'Vencidos',
        'icono': Icons.warning_amber_outlined,
      },
      {
        'valor': 'devuelto',
        'texto': 'Devueltos',
        'icono': Icons.assignment_turned_in_outlined,
      },
    ];

    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 12),
        itemCount: filtros.length,
        separatorBuilder: (context, index) {
          return const SizedBox(width: 12);
        },
        itemBuilder: (context, index) {
          final filtro = filtros[index];
          final valor = filtro['valor'] as String;
          final texto = filtro['texto'] as String;
          final icono = filtro['icono'] as IconData;
          final seleccionado = filtroEstado == valor;

          return GestureDetector(
            onTap: () {
              setState(() {
                filtroEstado = valor;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: seleccionado
                    ? HistorialColors.acentoSuave
                    : HistorialColors.fondoTarjeta,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(seleccionado ? 16 : 8),
                    blurRadius: seleccionado ? 14 : 8,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    seleccionado ? Icons.check : icono,
                    color: seleccionado
                        ? HistorialColors.acentoPrincipal
                        : HistorialColors.textoSecundario,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    texto,
                    style: TextStyle(
                      color: seleccionado
                          ? HistorialColors.acentoPrincipal
                          : HistorialColors.textoPrincipal,
                      fontWeight:
                          seleccionado ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _chipEstado(String estado) {
    final color = _colorEstado(estado);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(28),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _iconoEstado(estado),
            size: 15,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            _textoEstado(estado),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconoActivo({
    required String categoria,
    required String nombreActivo,
    required String estado,
    required int index,
  }) {
    final color = _colorEstado(estado);

    return Container(
      width: 92,
      height: 92,
      decoration: BoxDecoration(
        color: _colorDecorativo(index),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Icon(
        _iconoCategoria(
          categoria: categoria,
          nombreActivo: nombreActivo,
        ),
        color: color,
        size: 44,
      ),
    );
  }

  Widget _datoFecha({
    required IconData icono,
    required String titulo,
    required String fecha,
    Color? color,
  }) {
    return Row(
      children: [
        Icon(
          icono,
          size: 17,
          color: color ?? HistorialColors.textoSecundario,
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            '$titulo: $fecha',
            style: TextStyle(
              color: color ?? HistorialColors.textoSecundario,
              fontSize: 13,
              fontWeight: color == null ? FontWeight.normal : FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _tarjetaPrestamo(
    QueryDocumentSnapshot<Map<String, dynamic>> documento,
    int index,
  ) {
    final datos = documento.data();

    final activoId = (datos['activoId'] ?? '').toString();
    final usuarioId = (datos['usuarioId'] ?? '').toString();

    final estado = _estadoVisible(datos);
    final colorEstado = _colorEstado(estado);

    return FutureBuilder<List<DocumentSnapshot<Map<String, dynamic>>>>(
      future: _obtenerDatosRelacionados(activoId, usuarioId),
      builder: (context, snapshot) {
        final datosActivo = snapshot.data?[0].data();
        final datosUsuario = snapshot.data?[1].data();

        final nombreActivo =
            (datosActivo?['nombre'] ?? 'Activo: $activoId').toString();

        final categoria =
            (datosActivo?['categoria'] ?? 'Sin categoría').toString();

        final descripcion =
            (datosActivo?['descripcion'] ?? 'Préstamo institucional')
                .toString();

        final nombreUsuario =
            (datosUsuario?['nombre'] ?? 'Usuario: $usuarioId').toString();

        final correoUsuario =
            (datosUsuario?['correo'] ?? datosUsuario?['email'] ?? '')
                .toString();

        return Container(
          margin: const EdgeInsets.only(bottom: 18),
          padding: const EdgeInsets.fromLTRB(14, 14, 18, 14),
          decoration: BoxDecoration(
            color: HistorialColors.fondoTarjeta,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 18,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _iconoActivo(
                categoria: categoria,
                nombreActivo: nombreActivo,
                estado: estado,
                index: index,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombreActivo,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: HistorialColors.textoPrincipal,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${_textoCategoria(categoria)} • $descripcion',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: HistorialColors.textoSecundario,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _chipEstado(estado),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: HistorialColors.grisSuave,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            color: colorEstado,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Solicitado por: $nombreUsuario',
                                  style: const TextStyle(
                                    color: HistorialColors.textoPrincipal,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                if (correoUsuario.isNotEmpty) ...[
                                  const SizedBox(height: 3),
                                  Text(
                                    correoUsuario,
                                    style: const TextStyle(
                                      color:
                                          HistorialColors.textoSecundario,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _datoFecha(
                      icono: Icons.event_note_outlined,
                      titulo: 'Fecha de solicitud',
                      fecha: _formatearFecha(datos['fechaSolicitud']),
                    ),
                    const SizedBox(height: 7),
                    _datoFecha(
                      icono: Icons.schedule_outlined,
                      titulo: 'Fecha límite',
                      fecha: _formatearFecha(datos['fechaVencimiento']),
                      color: estado == 'vencido'
                          ? HistorialColors.rojo
                          : null,
                    ),
                    if (estado == 'devuelto') ...[
                      const SizedBox(height: 7),
                      _datoFecha(
                        icono: Icons.assignment_turned_in_outlined,
                        titulo: 'Fecha de devolución',
                        fecha: _formatearFecha(datos['fechaDevolucion']),
                        color: HistorialColors.verde,
                      ),
                    ],
                    if (estado == 'activo' || estado == 'vencido') ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: estado == 'vencido'
                              ? HistorialColors.rojo.withAlpha(18)
                              : HistorialColors.azulSuave,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          _mensajeRecordatorio(
                            estado: estado,
                            fechaVencimiento: datos['fechaVencimiento'],
                          ),
                          style: TextStyle(
                            color: estado == 'vencido'
                                ? HistorialColors.rojo
                                : HistorialColors.textoPrincipal,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _listaHistorial() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('prestamos').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: HistorialColors.acentoPrincipal,
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Error al cargar historial: ${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: HistorialColors.textoSecundario,
                ),
              ),
            ),
          );
        }

        final documentos = snapshot.data?.docs ?? [];

        final filtrados = documentos.where((documento) {
          if (filtroEstado == 'todos') {
            return true;
          }

          final datos = documento.data();
          final estadoVisible = _estadoVisible(datos);

          return estadoVisible == filtroEstado;
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
          return Center(
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: HistorialColors.fondoTarjeta,
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.manage_search_outlined,
                    color: HistorialColors.acentoPrincipal,
                    size: 54,
                  ),
                  SizedBox(height: 14),
                  Text(
                    'No hay préstamos registrados para este filtro.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: HistorialColors.textoPrincipal,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Cambia el filtro para consultar otros estados.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: HistorialColors.textoSecundario,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 26),
          itemCount: filtrados.length,
          itemBuilder: (context, index) {
            return _tarjetaPrestamo(filtrados[index], index);
          },
        );
      },
    );
  }

  Widget _pantallaCargando() {
    return const Scaffold(
      backgroundColor: HistorialColors.fondoGeneral,
      body: Center(
        child: CircularProgressIndicator(
          color: HistorialColors.acentoPrincipal,
        ),
      ),
    );
  }

  Widget _pantallaRestringida() {
    return Scaffold(
      backgroundColor: HistorialColors.fondoGeneral,
      appBar: AppBar(
        backgroundColor: HistorialColors.fondoGeneral,
        elevation: 0,
        foregroundColor: HistorialColors.textoPrincipal,
        title: const Text('Historial de préstamos'),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Acceso restringido. Solo el encargado de inventario puede consultar el historial.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: HistorialColors.textoSecundario,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PerfilUsuario?>(
      future: perfilFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _pantallaCargando();
        }

        final perfil = snapshot.data;

        final puedeConsultar = perfil != null &&
            perfil.estado == AccountStatus.active &&
            perfil.role == UserRole.encargadoInventario;

        if (!puedeConsultar) {
          return _pantallaRestringida();
        }

        return Scaffold(
          backgroundColor: HistorialColors.fondoGeneral,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 22, 8),
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: 'Volver',
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back),
                        color: HistorialColors.textoPrincipal,
                      ),
                      const SizedBox(width: 6),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Historial de préstamos',
                              style: TextStyle(
                                color: HistorialColors.textoPrincipal,
                                fontSize: 27,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Consulta préstamos activos, vencidos y devueltos.',
                              style: TextStyle(
                                color: HistorialColors.textoSecundario,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                _filtros(),
                Expanded(
                  child: _listaHistorial(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}