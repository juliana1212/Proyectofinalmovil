import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PrestamosColors {
  static const Color fondoGeneral = Color(0xFFF3F5FC);
  static const Color fondoTarjeta = Color(0xFFFFFFFF);

  static const Color acentoPrincipal = Color(0xFFFF8A73);
  static const Color acentoSuave = Color(0xFFFFE5DE);

  static const Color azulSuave = Color(0xFFE9EEFF);
  static const Color cremaSuave = Color(0xFFFFF1E4);
  static const Color verdeSuave = Color(0xFFE8F6EC);

  static const Color textoPrincipal = Color(0xFF24324A);
  static const Color textoSecundario = Color(0xFF8C93A8);

  static const Color verde = Color(0xFF45B75A);
  static const Color rojo = Color(0xFFE85D5D);
}

class MisPrestamosPage extends StatelessWidget {
  const MisPrestamosPage({super.key});

  Stream<QuerySnapshot<Map<String, dynamic>>> _obtenerMisPrestamos(
    String usuarioId,
  ) {
    return FirebaseFirestore.instance
        .collection('prestamos')
        .where('usuarioId', isEqualTo: usuarioId)
        .snapshots();
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

  Widget _encabezado(int cantidad) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mis préstamos',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: PrestamosColors.textoPrincipal,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            cantidad == 0
                ? 'Aquí verás los activos que tengas prestados.'
                : 'Tienes $cantidad préstamo(s) activo(s) o por revisar.',
            style: const TextStyle(
              fontSize: 14,
              color: PrestamosColors.textoSecundario,
            ),
          ),
        ],
      ),
    );
  }

  Widget _estadoResumen(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    int activos = 0;
    int vencidos = 0;

    for (final doc in docs) {
      final fechaVencimiento = _convertirFecha(doc.data()['fechaVencimiento']);

      if (fechaVencimiento != null &&
          DateTime.now().isAfter(fechaVencimiento)) {
        vencidos++;
      } else {
        activos++;
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 6, 22, 18),
      child: Row(
        children: [
          _miniResumen(
            icono: Icons.assignment_ind_outlined,
            titulo: 'Activos',
            valor: '$activos',
            fondo: PrestamosColors.azulSuave,
          ),
          const SizedBox(width: 12),
          _miniResumen(
            icono: Icons.schedule_outlined,
            titulo: 'Vencidos',
            valor: '$vencidos',
            fondo: PrestamosColors.cremaSuave,
          ),
        ],
      ),
    );
  }

  Widget _nivelCumplimiento(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    int activos = 0;
    int vencidos = 0;
    int devueltos = 0;

    for (final doc in docs) {
      final datos = doc.data();
      final estado = (datos['estado'] ?? '').toString();

      final fechaVencimiento = _convertirFecha(datos['fechaVencimiento']);
      final vencidoPorFecha =
          fechaVencimiento != null && DateTime.now().isAfter(fechaVencimiento);

      if (estado == 'devuelto') {
        devueltos++;
      } else if (estado == 'vencido' || vencidoPorFecha) {
        vencidos++;
      } else if (estado == 'activo') {
        activos++;
      }
    }

    String titulo;
    String mensaje;
    IconData icono;
    Color fondo;
    Color color;

    if (docs.isEmpty) {
      titulo = 'Nuevo usuario';
      mensaje =
          'Aún no tienes historial de préstamos. Cuando solicites activos, tu nivel aparecerá aquí.';
      icono = Icons.school_outlined;
      fondo = PrestamosColors.azulSuave;
      color = PrestamosColors.acentoPrincipal;
    } else if (vencidos > 0) {
      titulo = 'Requiere atención';
      mensaje =
          'Tienes préstamos vencidos o pendientes por revisar. Devuélvelos para mejorar tu nivel.';
      icono = Icons.warning_amber_outlined;
      fondo = PrestamosColors.cremaSuave;
      color = PrestamosColors.rojo;
    } else if (devueltos >= 3) {
      titulo = 'Usuario responsable';
      mensaje =
          'Buen historial de devoluciones. Mantienes un comportamiento confiable en el sistema.';
      icono = Icons.verified_outlined;
      fondo = PrestamosColors.verdeSuave;
      color = PrestamosColors.verde;
    } else {
      titulo = 'En buen estado';
      mensaje =
          'No tienes préstamos vencidos. Sigue devolviendo los activos a tiempo.';
      icono = Icons.check_circle_outline;
      fondo = PrestamosColors.azulSuave;
      color = PrestamosColors.acentoPrincipal;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 6, 22, 18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: fondo,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(190),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icono, color: color, size: 30),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nivel de cumplimiento',
                    style: TextStyle(
                      color: PrestamosColors.textoSecundario,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    titulo,
                    style: const TextStyle(
                      color: PrestamosColors.textoPrincipal,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    mensaje,
                    style: const TextStyle(
                      color: PrestamosColors.textoSecundario,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _chipCumplimiento('Activos', activos),
                      _chipCumplimiento('Devueltos', devueltos),
                      _chipCumplimiento('Vencidos', vencidos),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniResumen({
    required IconData icono,
    required String titulo,
    required String valor,
    required Color fondo,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: fondo,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(170),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icono,
                color: PrestamosColors.acentoPrincipal,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      color: PrestamosColors.textoSecundario,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    valor,
                    style: const TextStyle(
                      color: PrestamosColors.textoPrincipal,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chipCumplimiento(String titulo, int valor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(180),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        '$titulo: $valor',
        style: const TextStyle(
          color: PrestamosColors.textoPrincipal,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _vacio() {
    return Expanded(
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(22),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: PrestamosColors.fondoTarjeta,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 34,
                backgroundColor: PrestamosColors.acentoSuave,
                child: Icon(
                  Icons.inventory_2_outlined,
                  color: PrestamosColors.acentoPrincipal,
                  size: 34,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'No tienes préstamos activos',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: PrestamosColors.textoPrincipal,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Cuando solicites un activo, aparecerá aquí con su tiempo restante y la fecha límite de devolución.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: PrestamosColors.textoSecundario,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final usuarioId = FirebaseAuth.instance.currentUser?.uid;

    if (usuarioId == null) {
      return const Scaffold(
        backgroundColor: PrestamosColors.fondoGeneral,
        body: Center(
          child: Text(
            'Sesión no válida. Inicia sesión nuevamente.',
            style: TextStyle(color: PrestamosColors.textoSecundario),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: PrestamosColors.fondoGeneral,
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _obtenerMisPrestamos(usuarioId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: PrestamosColors.acentoPrincipal,
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Error al cargar los préstamos: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: PrestamosColors.textoSecundario,
                    ),
                  ),
                ),
              );
            }

            final docs = snapshot.data?.docs ?? [];

            final prestamosVisibles = docs.where((doc) {
              final estado = (doc.data()['estado'] ?? '').toString();
              return estado == 'activo' || estado == 'vencido';
            }).toList();

            prestamosVisibles.sort((a, b) {
              final fechaA = _convertirFecha(a.data()['fechaVencimiento']);
              final fechaB = _convertirFecha(b.data()['fechaVencimiento']);

              if (fechaA == null && fechaB == null) return 0;
              if (fechaA == null) return 1;
              if (fechaB == null) return -1;

              return fechaA.compareTo(fechaB);
            });

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _encabezado(prestamosVisibles.length),
                _nivelCumplimiento(docs),
                if (prestamosVisibles.isNotEmpty)
                  _estadoResumen(prestamosVisibles),
                if (prestamosVisibles.isEmpty)
                  _vacio()
                else
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 26),
                      itemCount: prestamosVisibles.length,
                      separatorBuilder: (context, index) {
                        return const SizedBox(height: 22);
                      },
                      itemBuilder: (context, index) {
                        return TarjetaPrestamoConImagen(
                          prestamoDocumento: prestamosVisibles[index],
                          posicion: index,
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class TarjetaPrestamoConImagen extends StatefulWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> prestamoDocumento;
  final int posicion;

  const TarjetaPrestamoConImagen({
    super.key,
    required this.prestamoDocumento,
    required this.posicion,
  });

  @override
  State<TarjetaPrestamoConImagen> createState() =>
      _TarjetaPrestamoConImagenState();
}

class _TarjetaPrestamoConImagenState extends State<TarjetaPrestamoConImagen> {
  late Future<DocumentSnapshot<Map<String, dynamic>>> activoFuture;
  Timer? temporizador;
  bool estaEncima = false;

  @override
  void initState() {
    super.initState();

    final datosPrestamo = widget.prestamoDocumento.data();
    final activoId = (datosPrestamo['activoId'] ?? '').toString();

    activoFuture = FirebaseFirestore.instance
        .collection('activos')
        .doc(activoId)
        .get();

    temporizador = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    temporizador?.cancel();
    super.dispose();
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

  String _formatearFecha(DateTime? fecha) {
    if (fecha == null) {
      return 'Sin fecha registrada';
    }

    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    final anio = fecha.year.toString();

    final hora = fecha.hour.toString().padLeft(2, '0');
    final minuto = fecha.minute.toString().padLeft(2, '0');

    return '$dia/$mes/$anio • $hora:$minuto';
  }

  String _categoriaTexto(String categoria) {
    final texto = categoria.trim().toLowerCase();

    switch (texto) {
      case 'audio':
        return 'Audio';
      case 'computadoras':
        return 'Computadoras';
      case 'tablets':
        return 'Tablets';
      case 'electronica':
      case 'electrónica':
        return 'Electrónica';
      case 'tecnologicos':
      case 'tecnológicos':
        return 'Tecnológicos';
      default:
        return categoria.isEmpty ? 'Sin categoría' : categoria;
    }
  }

  IconData _iconoCategoria(String categoria) {
    final texto = categoria.trim().toLowerCase();

    switch (texto) {
      case 'audio':
        return Icons.speaker_outlined;
      case 'computadoras':
        return Icons.laptop_mac;
      case 'tablets':
        return Icons.tablet_android;
      case 'electronica':
      case 'electrónica':
        return Icons.videocam_outlined;
      case 'tecnologicos':
      case 'tecnológicos':
        return Icons.memory_outlined;
      default:
        return Icons.inventory_2_outlined;
    }
  }

  String? _imagenCategoria(String categoria) {
    final texto = categoria.trim().toLowerCase();

    switch (texto) {
      case 'audio':
        return 'assets/images/activos/parlantepic.png';
      case 'computadoras':
        return 'assets/images/activos/laptoppic.png';
      case 'tablets':
        return 'assets/images/activos/tabletpic.png';
      case 'electronica':
      case 'electrónica':
        return 'assets/images/activos/proyectorpic.png';
      default:
        return null;
    }
  }

  Color _colorDecorativo(int index) {
    if (index % 3 == 0) {
      return PrestamosColors.azulSuave;
    }

    if (index % 3 == 1) {
      return PrestamosColors.cremaSuave;
    }

    return PrestamosColors.verdeSuave;
  }

  bool _estaVencido(DateTime? fechaVencimiento) {
    if (fechaVencimiento == null) {
      return false;
    }

    return DateTime.now().isAfter(fechaVencimiento);
  }

  String _tiempoRestante(DateTime? fechaVencimiento) {
    if (fechaVencimiento == null) {
      return 'Sin fecha límite';
    }

    final diferencia = fechaVencimiento.difference(DateTime.now());

    if (diferencia.isNegative || diferencia.inSeconds <= 0) {
      return 'Vencido';
    }

    final horas = diferencia.inHours;
    final minutos = diferencia.inMinutes.remainder(60);
    final segundos = diferencia.inSeconds.remainder(60);

    return '${horas}h ${minutos}min ${segundos}s';
  }

  Color _colorTiempo(DateTime? fechaVencimiento) {
    if (fechaVencimiento == null) {
      return PrestamosColors.acentoPrincipal;
    }

    final diferencia = fechaVencimiento.difference(DateTime.now());

    if (diferencia.isNegative || diferencia.inSeconds <= 0) {
      return PrestamosColors.rojo;
    }

    if (diferencia.inMinutes <= 30) {
      return PrestamosColors.acentoPrincipal;
    }

    return PrestamosColors.verde;
  }

  double _progresoTiempo(DateTime? fechaSolicitud, DateTime? fechaVencimiento) {
    if (fechaSolicitud == null || fechaVencimiento == null) {
      return 0;
    }

    final total = fechaVencimiento.difference(fechaSolicitud).inSeconds;
    final usado = DateTime.now().difference(fechaSolicitud).inSeconds;

    if (total <= 0) {
      return 1;
    }

    final progreso = usado / total;

    if (progreso < 0) return 0;
    if (progreso > 1) return 1;

    return progreso;
  }

  Widget _imagenOIcono({
    required String categoria,
    required Color fondo,
    required bool vencido,
  }) {
    final imagen = _imagenCategoria(categoria);

    if (imagen == null) {
      return Container(
        width: 140,
        height: 180,
        decoration: BoxDecoration(
          color: fondo,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Icon(
          _iconoCategoria(categoria),
          color: vencido
              ? PrestamosColors.rojo
              : PrestamosColors.acentoPrincipal,
          size: 68,
        ),
      );
    }

    return SizedBox(
      width: 170,
      height: 200,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 8,
            child: Container(
              width: 145,
              height: 170,
              decoration: BoxDecoration(
                color: fondo,
                borderRadius: BorderRadius.circular(34),
              ),
            ),
          ),
          Positioned(
            top: 0,
            child: Image.asset(
              imagen,
              width: 150,
              height: 180,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final datosPrestamo = widget.prestamoDocumento.data();

    final fechaSolicitud = _convertirFecha(datosPrestamo['fechaSolicitud']);
    final fechaVencimiento = _convertirFecha(datosPrestamo['fechaVencimiento']);

    final vencido = _estaVencido(fechaVencimiento);
    final colorTiempo = _colorTiempo(fechaVencimiento);
    final progreso = _progresoTiempo(fechaSolicitud, fechaVencimiento);

    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: activoFuture,
      builder: (context, snapshotActivo) {
        final activo = snapshotActivo.data?.data();

        final nombreActivo = (activo?['nombre'] ?? 'Activo no encontrado')
            .toString();

        final categoria = (activo?['categoria'] ?? 'Sin categoría').toString();

        final descripcion = (activo?['descripcion'] ?? 'Préstamo institucional')
            .toString();

        final fondoLateral = _colorDecorativo(widget.posicion);

        return MouseRegion(
          onEnter: (_) {
            setState(() {
              estaEncima = true;
            });
          },
          onExit: (_) {
            setState(() {
              estaEncima = false;
            });
          },
          child: AnimatedScale(
            scale: estaEncima ? 1.012 : 1,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              padding: const EdgeInsets.fromLTRB(8, 12, 18, 12),
              decoration: BoxDecoration(
                color: PrestamosColors.fondoTarjeta,
                borderRadius: BorderRadius.circular(34),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(estaEncima ? 22 : 10),
                    blurRadius: estaEncima ? 24 : 18,
                    offset: const Offset(0, 9),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 6),
                  _imagenOIcono(
                    categoria: categoria,
                    fondo: fondoLateral,
                    vencido: vencido,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 2,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nombreActivo,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: PrestamosColors.textoPrincipal,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                _categoriaTexto(categoria),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: PrestamosColors.textoSecundario,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: vencido
                                      ? PrestamosColors.rojo.withAlpha(25)
                                      : PrestamosColors.acentoSuave,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Text(
                                  vencido ? 'Vencido' : 'Activo',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: vencido
                                        ? PrestamosColors.rojo
                                        : PrestamosColors.acentoPrincipal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            descripcion,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              color: PrestamosColors.textoSecundario,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _tiempoRestante(fechaVencimiento),
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                              color: colorTiempo,
                            ),
                          ),
                          const SizedBox(height: 9),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: LinearProgressIndicator(
                              value: progreso,
                              minHeight: 8,
                              backgroundColor: PrestamosColors.fondoGeneral,
                              color: colorTiempo,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(
                                Icons.schedule_outlined,
                                size: 16,
                                color: PrestamosColors.textoSecundario,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Devuélvelo antes de ${_formatearFecha(fechaVencimiento)}',
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    color: PrestamosColors.textoPrincipal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const Icon(
                                Icons.event_note_outlined,
                                size: 16,
                                color: PrestamosColors.textoSecundario,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Solicitado: ${_formatearFecha(fechaSolicitud)}',
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    color: PrestamosColors.textoSecundario,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
