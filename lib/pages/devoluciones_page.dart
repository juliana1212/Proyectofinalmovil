import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../data/app_database.dart';
import '../models/enums.dart';
import '../models/perfil_usuario.dart';
import '../services/servicio_devoluciones.dart';
import '../widgets/widgets_devoluciones.dart';

class DevolucionesColors {
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
}

class DevolucionesPage extends StatefulWidget {
  const DevolucionesPage({super.key});

  @override
  State<DevolucionesPage> createState() => _DevolucionesPageState();
}

class _DevolucionesPageState extends State<DevolucionesPage> {
  final ServicioDevoluciones servicioDevoluciones = ServicioDevoluciones();

  late Future<PerfilUsuario?> perfilFuture;
  bool sincronizando = false;

  @override
  void initState() {
    super.initState();
    perfilFuture = _obtenerPerfilActual();
  }

  @override
  void dispose() {
    servicioDevoluciones.cerrarBaseLocal();
    super.dispose();
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

  String _textoCategoria(String categoria) {
    final texto = _normalizarTexto(categoria);

    switch (texto) {
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

  IconData _iconoCategoria(String categoria) {
    final texto = _normalizarTexto(categoria);

    switch (texto) {
      case 'audio':
        return Icons.mic_none_outlined;
      case 'computadoras':
        return Icons.laptop_mac;
      case 'electronica':
        return Icons.devices_other_outlined;
      case 'tablets':
        return Icons.tablet_android;
      case 'tecnologicos':
        return Icons.memory_outlined;
      default:
        return Icons.inventory_2_outlined;
    }
  }

  String? _imagenActivo({
    required String categoria,
    required String nombreActivo,
  }) {
    final categoriaNormalizada = _normalizarTexto(categoria);
    final nombreNormalizado = _normalizarTexto(nombreActivo);

    if (categoriaNormalizada == 'audio') {
      if (nombreNormalizado.contains('microfono')) {
        return 'assets/images/activos/micropic.png';
      }

      return 'assets/images/activos/parlantepic.png';
    }

    switch (categoriaNormalizada) {
      case 'computadoras':
        return 'assets/images/activos/laptoppic.png';
      case 'tablets':
        return 'assets/images/activos/tabletpic.png';
      case 'electronica':
        return 'assets/images/activos/proyechdpic.png';
      default:
        return null;
    }
  }

  Color _colorDecorativo(int index) {
    if (index % 4 == 0) {
      return DevolucionesColors.azulSuave;
    }

    if (index % 4 == 1) {
      return DevolucionesColors.cremaSuave;
    }

    if (index % 4 == 2) {
      return DevolucionesColors.verdeSuave;
    }

    return DevolucionesColors.acentoSuave;
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

  Future<void> _sincronizarPendientes() async {
    setState(() {
      sincronizando = true;
    });

    try {
      final resultado = await servicioDevoluciones.sincronizarPendientes();

      if (!mounted) return;

      final mensaje = resultado.pendientes == 0
          ? '${resultado.sincronizadas} devolución(es) sincronizada(s) correctamente.'
          : '${resultado.sincronizadas} sincronizada(s). ${resultado.pendientes} continúa(n) pendiente(s).';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: resultado.pendientes == 0
              ? DevolucionesColors.verde
              : DevolucionesColors.naranja,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo sincronizar: $error'),
          backgroundColor: DevolucionesColors.rojo,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          sincronizando = false;
        });
      }
    }
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
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(22),
              child: Container(
                width: 520,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: DevolucionesColors.fondoTarjeta,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(18),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: DevolucionesColors.acentoSuave,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.assignment_return_outlined,
                              color: DevolucionesColors.acentoPrincipal,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Confirmar devolución',
                                  style: TextStyle(
                                    color: DevolucionesColors.textoPrincipal,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Verifica el estado del activo recibido.',
                                  style: TextStyle(
                                    color: DevolucionesColors.textoSecundario,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: DevolucionesColors.azulSuave,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: const Text(
                          'Marca si el activo presenta alguna novedad. Si no tiene novedad, se registrará como devolución normal.',
                          style: TextStyle(
                            color: DevolucionesColors.textoPrincipal,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: tieneNovedad
                              ? DevolucionesColors.cremaSuave
                              : DevolucionesColors.grisSuave,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: CheckboxListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          activeColor: DevolucionesColors.acentoPrincipal,
                          title: const Text(
                            'El activo presenta novedad',
                            style: TextStyle(
                              color: DevolucionesColors.textoPrincipal,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: const Text(
                            'Ejemplo: daño físico, faltantes o mal funcionamiento.',
                            style: TextStyle(
                              color: DevolucionesColors.textoSecundario,
                            ),
                          ),
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
                      ),
                      if (tieneNovedad) ...[
                        const SizedBox(height: 16),
                        TextField(
                          controller: controladorNovedad,
                          maxLines: 4,
                          decoration: InputDecoration(
                            labelText: 'Descripción de la novedad',
                            hintText:
                                'Ejemplo: pantalla rota o cargador faltante',
                            errorText: mensajeValidacion,
                            filled: true,
                            fillColor: DevolucionesColors.grisSuave,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(
                                color: DevolucionesColors.acentoPrincipal,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor:
                                    DevolucionesColors.acentoPrincipal,
                                side: const BorderSide(
                                  color: DevolucionesColors.acentoPrincipal,
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(dialogContext, false);
                              },
                              child: const Text('Cancelar'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor:
                                    DevolucionesColors.acentoPrincipal,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
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
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
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
      final resultado = await servicioDevoluciones.confirmarDevolucion(
        prestamoId: prestamoId,
        activoId: activoId,
        encargado: encargado,
        tieneNovedad: tieneNovedad,
        descripcionNovedad: controladorNovedad.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resultado.mensaje),
          backgroundColor: resultado.sincronizada
              ? DevolucionesColors.verde
              : DevolucionesColors.naranja,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      final mensaje = error.toString().replaceFirst('Exception: ', '');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: DevolucionesColors.rojo,
        ),
      );
    } finally {
      controladorNovedad.dispose();
    }
  }

  Widget _resumenPendientes({
    required int cantidadRemota,
    required int cantidadLocal,
  }) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: DevolucionesColors.azulSuave,
              borderRadius: BorderRadius.circular(26),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: DevolucionesColors.fondoTarjeta,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.assignment_return_outlined,
                    color: DevolucionesColors.acentoPrincipal,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Por devolver',
                        style: TextStyle(
                          color: DevolucionesColors.textoSecundario,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$cantidadRemota',
                        style: const TextStyle(
                          color: DevolucionesColors.textoPrincipal,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: DevolucionesColors.cremaSuave,
              borderRadius: BorderRadius.circular(26),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: DevolucionesColors.fondoTarjeta,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.cloud_off_outlined,
                    color: DevolucionesColors.naranja,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pendientes sync',
                        style: TextStyle(
                          color: DevolucionesColors.textoSecundario,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$cantidadLocal',
                        style: const TextStyle(
                          color: DevolucionesColors.textoPrincipal,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _listaPendienteSinConexion(
    List<DevolucionesPendiente> pendientes,
  ) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 90),
      itemCount: pendientes.length,
      separatorBuilder: (context, index) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final pendiente = pendientes[index];

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: DevolucionesColors.fondoTarjeta,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: DevolucionesColors.cremaSuave,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.cloud_off_outlined,
                  color: DevolucionesColors.naranja,
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: TarjetaDevolucionPendiente(
                  nombreActivo: 'Activo: ${pendiente.activoId}',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _imagenTarjetaActivo({
    required String nombre,
    required String categoria,
    required int index,
    required bool pendienteLocal,
    required bool vencido,
  }) {
    final imagen = _imagenActivo(
      categoria: categoria,
      nombreActivo: nombre,
    );

    final fondo = _colorDecorativo(index);

    if (imagen == null) {
      return Container(
        width: 140,
        height: 160,
        decoration: BoxDecoration(
          color: fondo,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Icon(
          pendienteLocal
              ? Icons.cloud_off_outlined
              : vencido
                  ? Icons.warning_amber_outlined
                  : _iconoCategoria(categoria),
          color: pendienteLocal
              ? DevolucionesColors.naranja
              : vencido
                  ? DevolucionesColors.rojo
                  : DevolucionesColors.acentoPrincipal,
          size: 62,
        ),
      );
    }

    return SizedBox(
      width: 165,
      height: 180,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 8,
            child: Container(
              width: 140,
              height: 155,
              decoration: BoxDecoration(
                color: fondo,
                borderRadius: BorderRadius.circular(34),
              ),
            ),
          ),
          Positioned(
            top: -6,
            child: Image.asset(
              imagen,
              width: 150,
              height: 170,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _chipEstadoPrestamo({
    required bool pendienteLocal,
    required String estado,
  }) {
    Color color;
    String texto;
    IconData icono;

    if (pendienteLocal) {
      color = DevolucionesColors.naranja;
      texto = 'Pendiente sync';
      icono = Icons.cloud_off_outlined;
    } else if (estado == 'vencido') {
      color = DevolucionesColors.rojo;
      texto = 'Vencido';
      icono = Icons.warning_amber_outlined;
    } else {
      color = DevolucionesColors.verde;
      texto = 'Activo';
      icono = Icons.check_circle_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icono,
            size: 15,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            texto,
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

  Widget _tarjetaPrestamo({
    required PerfilUsuario perfil,
    required QueryDocumentSnapshot<Map<String, dynamic>> prestamoDocumento,
    required bool pendienteLocal,
    required int index,
  }) {
    final datos = prestamoDocumento.data();
    final activoId = (datos['activoId'] ?? '').toString();
    final estado = (datos['estado'] ?? '').toString();

    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance
          .collection('activos')
          .doc(activoId)
          .get(),
      builder: (context, activoSnapshot) {
        final datosActivo = activoSnapshot.data?.data();

        final nombre = datosActivo?['nombre']?.toString() ??
            'Activo $activoId';

        final categoria = datosActivo?['categoria']?.toString() ??
            'Sin categoría';

        final descripcion = datosActivo?['descripcion']?.toString() ??
            'Préstamo institucional';

        return Container(
          margin: const EdgeInsets.only(bottom: 18),
          padding: const EdgeInsets.fromLTRB(10, 14, 18, 14),
          decoration: BoxDecoration(
            color: DevolucionesColors.fondoTarjeta,
            borderRadius: BorderRadius.circular(34),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 18,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: Row(
            children: [
              _imagenTarjetaActivo(
                nombre: nombre,
                categoria: categoria,
                index: index,
                pendienteLocal: pendienteLocal,
                vencido: estado == 'vencido',
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombre,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: DevolucionesColors.textoPrincipal,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _textoCategoria(categoria),
                      style: const TextStyle(
                        color: DevolucionesColors.textoSecundario,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      descripcion,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: DevolucionesColors.textoSecundario,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _chipEstadoPrestamo(
                      pendienteLocal: pendienteLocal,
                      estado: estado,
                    ),
                    const SizedBox(height: 14),
                    if (pendienteLocal)
                      const Text(
                        'Esta devolución está guardada localmente y falta sincronizarla.',
                        style: TextStyle(
                          color: DevolucionesColors.naranja,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      )
                    else
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor:
                              DevolucionesColors.acentoPrincipal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 13,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: () {
                          _abrirFormularioDevolucion(
                            prestamoId: prestamoDocumento.id,
                            activoId: activoId,
                            encargado: perfil,
                          );
                        },
                        icon: const Icon(Icons.assignment_return_outlined),
                        label: const Text('Devolver'),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _listaPrestamos({
    required PerfilUsuario perfil,
    required List<DevolucionesPendiente> pendientes,
  }) {
    final prestamosPendientes =
        pendientes.map((registro) => registro.prestamoId).toSet();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: servicioDevoluciones.obtenerPrestamosPorDevolver(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: DevolucionesColors.acentoPrincipal,
            ),
          );
        }

        if (snapshot.hasError) {
          if (pendientes.isNotEmpty) {
            return _listaPendienteSinConexion(pendientes);
          }

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Error al cargar préstamos: ${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: DevolucionesColors.textoSecundario,
                ),
              ),
            ),
          );
        }

        final documentos = snapshot.data?.docs ?? [];

        if (documentos.isEmpty && pendientes.isEmpty) {
          return Center(
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: DevolucionesColors.fondoTarjeta,
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: DevolucionesColors.verde,
                    size: 54,
                  ),
                  SizedBox(height: 14),
                  Text(
                    'No hay préstamos pendientes por devolver.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: DevolucionesColors.textoPrincipal,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Cuando haya préstamos activos o vencidos aparecerán aquí.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: DevolucionesColors.textoSecundario,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(22, 4, 22, 90),
          children: [
            _resumenPendientes(
              cantidadRemota: documentos.length,
              cantidadLocal: pendientes.length,
            ),
            const SizedBox(height: 24),
            const Text(
              'Confirmar devoluciones',
              style: TextStyle(
                color: DevolucionesColors.textoPrincipal,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            if (pendientes.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: BannerPendientesSincronizacion(
                  cantidadPendientes: pendientes.length,
                  sincronizando: sincronizando,
                  onSincronizar: _sincronizarPendientes,
                ),
              ),
            ...documentos.asMap().entries.map(
                  (entry) {
                    final prestamoDocumento = entry.value;
                    final pendienteLocal =
                        prestamosPendientes.contains(prestamoDocumento.id);

                    return _tarjetaPrestamo(
                      perfil: perfil,
                      prestamoDocumento: prestamoDocumento,
                      pendienteLocal: pendienteLocal,
                      index: entry.key,
                    );
                  },
                ),
          ],
        );
      },
    );
  }

  Widget _pantallaCargando() {
    return const Scaffold(
      backgroundColor: DevolucionesColors.fondoGeneral,
      body: Center(
        child: CircularProgressIndicator(
          color: DevolucionesColors.acentoPrincipal,
        ),
      ),
    );
  }

  Widget _pantallaMensaje(String mensaje) {
    return Scaffold(
      backgroundColor: DevolucionesColors.fondoGeneral,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            mensaje,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: DevolucionesColors.textoSecundario,
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
      builder: (context, perfilSnapshot) {
        if (perfilSnapshot.connectionState == ConnectionState.waiting) {
          return _pantallaCargando();
        }

        if (perfilSnapshot.hasError) {
          return _pantallaMensaje(
            'Error al consultar el perfil del usuario.',
          );
        }

        final perfil = perfilSnapshot.data;

        if (perfil == null) {
          return _pantallaMensaje(
            'No se encontró el perfil del usuario.',
          );
        }

        final puedeConfirmar =
            perfil.estado == AccountStatus.active &&
            perfil.role == UserRole.encargadoInventario;

        if (!puedeConfirmar) {
          return const Scaffold(
            backgroundColor: DevolucionesColors.fondoGeneral,
            body: AccesoRestringidoDevoluciones(),
          );
        }

        return StreamBuilder<List<DevolucionesPendiente>>(
          stream: servicioDevoluciones.observarPendientes(),
          builder: (context, pendientesSnapshot) {
            final pendientes = pendientesSnapshot.data ?? [];

            return Scaffold(
              backgroundColor: DevolucionesColors.fondoGeneral,
              body: _listaPrestamos(
                perfil: perfil,
                pendientes: pendientes,
              ),
              floatingActionButton: FloatingActionButton.small(
                heroTag: 'sync_devoluciones',
                backgroundColor: DevolucionesColors.acentoSuave,
                foregroundColor: DevolucionesColors.acentoPrincipal,
                elevation: 0,
                tooltip: 'Sincronizar pendientes',
                onPressed: sincronizando ? null : _sincronizarPendientes,
                child: sincronizando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: DevolucionesColors.acentoPrincipal,
                        ),
                      )
                    : const Icon(Icons.sync),
              ),
            );
          },
        );
      },
    );
  }
}