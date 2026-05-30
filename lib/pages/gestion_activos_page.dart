import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/activo.dart';
import '../models/enums.dart';
import '../models/perfil_usuario.dart';
import '../services/servicio_activos.dart';

class GestionColors {
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
  static const Color azulGris = Color(0xFF607D8B);
}

class GestionActivosPage extends StatefulWidget {
  const GestionActivosPage({super.key});

  @override
  State<GestionActivosPage> createState() => _GestionActivosPageState();
}

class _GestionActivosPageState extends State<GestionActivosPage> {
  final ServicioActivos servicioActivos = ServicioActivos();

  late Future<PerfilUsuario?> perfilFuture;
  bool procesando = false;

  final List<String> categoriasDisponibles = [
    'tablets',
    'audio',
    'electronica',
    'computadoras',
    'tecnologicos',
  ];

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
        return GestionColors.verde;
      case 'prestado':
        return GestionColors.naranja;
      case 'vencido':
        return GestionColors.rojo;
      case 'mantenimiento':
        return GestionColors.azulGris;
      case 'dadoDeBaja':
        return GestionColors.gris;
      default:
        return GestionColors.textoSecundario;
    }
  }

  IconData _iconoEstado(String estado) {
    switch (estado) {
      case 'disponible':
        return Icons.check_circle_outline;
      case 'prestado':
        return Icons.assignment_outlined;
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

  String _textoCategoria(String categoria) {
    switch (_normalizarTexto(categoria)) {
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
      default:
        return categoria;
    }
  }

  IconData _iconoCategoria(String categoria) {
    switch (_normalizarTexto(categoria)) {
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
      return GestionColors.azulSuave;
    }

    if (index % 4 == 1) {
      return GestionColors.cremaSuave;
    }

    if (index % 4 == 2) {
      return GestionColors.verdeSuave;
    }

    return GestionColors.acentoSuave;
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
          backgroundColor: GestionColors.verde,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      final mensaje = error.toString().replaceFirst('Exception: ', '');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: GestionColors.rojo,
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

  InputDecoration _decoracionCampo({
    required String label,
    required String hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: GestionColors.grisSuave,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: GestionColors.acentoPrincipal,
          width: 1.5,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
    );
  }

  Future<void> _abrirFormularioRegistro() async {
    final referenciaController = TextEditingController();
    final nombreController = TextEditingController();
    final descripcionController = TextEditingController();
    final cantidadController = TextEditingController();

    String categoriaSeleccionada = 'tablets';
    String? mensajeError;

    final datos = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(22),
              child: Container(
                width: 540,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: GestionColors.fondoTarjeta,
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
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              color: GestionColors.acentoSuave,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.add_box_outlined,
                              color: GestionColors.acentoPrincipal,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Registrar activo',
                                  style: TextStyle(
                                    color: GestionColors.textoPrincipal,
                                    fontSize: 23,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Agrega un activo nuevo o suma unidades a una referencia existente.',
                                  style: TextStyle(
                                    color: GestionColors.textoSecundario,
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
                          color: GestionColors.azulSuave,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Si la referencia ya existe, las unidades se sumarán al inventario registrado.',
                          style: TextStyle(
                            fontSize: 13,
                            color: GestionColors.textoPrincipal,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      TextField(
                        controller: referenciaController,
                        textCapitalization: TextCapitalization.characters,
                        decoration: _decoracionCampo(
                          label: 'Referencia',
                          hint: 'Ejemplo: TAB-SAM-A9',
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: nombreController,
                        decoration: _decoracionCampo(
                          label: 'Nombre del activo',
                          hint: 'Ejemplo: Tablet Samsung A9',
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: descripcionController,
                        maxLines: 2,
                        decoration: _decoracionCampo(
                          label: 'Descripción',
                          hint: 'Ejemplo: Tablet para salas de estudio',
                        ),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        initialValue: categoriaSeleccionada,
                        decoration: _decoracionCampo(
                          label: 'Categoría',
                          hint: 'Selecciona una categoría',
                        ),
                        items: categoriasDisponibles.map((categoria) {
                          return DropdownMenuItem<String>(
                            value: categoria,
                            child: Text(_textoCategoria(categoria)),
                          );
                        }).toList(),
                        onChanged: (valor) {
                          if (valor != null) {
                            setDialogState(() {
                              categoriaSeleccionada = valor;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: cantidadController,
                        keyboardType: TextInputType.number,
                        decoration: _decoracionCampo(
                          label: 'Cantidad a ingresar',
                          hint: 'Ejemplo: 3',
                        ),
                      ),
                      if (mensajeError != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: GestionColors.rojo.withAlpha(20),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            mensajeError!,
                            style: const TextStyle(
                              color: GestionColors.rojo,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
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
                                    GestionColors.acentoPrincipal,
                                side: const BorderSide(
                                  color: GestionColors.acentoPrincipal,
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(dialogContext);
                              },
                              child: const Text('Cancelar'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor:
                                    GestionColors.acentoPrincipal,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              onPressed: () {
                                final referencia =
                                    referenciaController.text.trim();
                                final nombre =
                                    nombreController.text.trim();
                                final descripcion =
                                    descripcionController.text.trim();
                                final cantidad = int.tryParse(
                                  cantidadController.text.trim(),
                                );

                                if (referencia.isEmpty ||
                                    nombre.isEmpty ||
                                    descripcion.isEmpty ||
                                    cantidad == null ||
                                    cantidad <= 0) {
                                  setDialogState(() {
                                    mensajeError =
                                        'Completa todos los campos y escribe una cantidad válida.';
                                  });
                                  return;
                                }

                                Navigator.pop(dialogContext, {
                                  'referencia': referencia,
                                  'nombre': nombre,
                                  'descripcion': descripcion,
                                  'categoria': categoriaSeleccionada,
                                  'cantidad': cantidad,
                                });
                              },
                              icon: const Icon(Icons.save_outlined),
                              label: const Text('Guardar'),
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

    referenciaController.dispose();
    nombreController.dispose();
    descripcionController.dispose();
    cantidadController.dispose();

    if (datos == null) {
      return;
    }

    setState(() {
      procesando = true;
    });

    try {
      final resultado = await servicioActivos.registrarOSumarUnidades(
        referencia: datos['referencia'] as String,
        nombre: datos['nombre'] as String,
        descripcion: datos['descripcion'] as String,
        categoria: datos['categoria'] as String,
        cantidad: datos['cantidad'] as int,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resultado.mensaje),
          backgroundColor: GestionColors.verde,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      final mensaje = error.toString().replaceFirst('Exception: ', '');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: GestionColors.rojo,
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
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(22),
          child: Container(
            width: 460,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: GestionColors.fondoTarjeta,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: GestionColors.cremaSuave,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Icon(
                    Icons.block_outlined,
                    color: GestionColors.naranja,
                    size: 34,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Dar de baja unidad',
                  style: TextStyle(
                    color: GestionColors.textoPrincipal,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '¿Estás seguro de dar de baja una unidad de "${activo.nombre}"? La unidad será retirada definitivamente del inventario disponible.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: GestionColors.textoSecundario,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: GestionColors.acentoPrincipal,
                          side: const BorderSide(
                            color: GestionColors.acentoPrincipal,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
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
                          backgroundColor: GestionColors.acentoPrincipal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(dialogContext, true);
                        },
                        child: const Text('Dar de baja'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
          color: GestionColors.textoSecundario,
          fontSize: 13,
        ),
      );
    }

    final botones = <Widget>[];

    if (hayDisponibles) {
      botones.add(
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: GestionColors.azulGris,
            side: const BorderSide(color: GestionColors.azulGris),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
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
          style: FilledButton.styleFrom(
            backgroundColor: GestionColors.acentoSuave,
            foregroundColor: GestionColors.acentoPrincipal,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
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
          style: FilledButton.styleFrom(
            backgroundColor: GestionColors.verde,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
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
          color: GestionColors.naranja,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    return const Text(
      'No hay unidades disponibles para gestionar.',
      style: TextStyle(
        color: GestionColors.textoSecundario,
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
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icono,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            '$titulo: $cantidad',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagenTarjetaActivo({
    required Activo activo,
    required int index,
  }) {
    final imagen = _imagenActivo(
      categoria: activo.categoria,
      nombreActivo: activo.nombre,
    );

    final fondo = _colorDecorativo(index);
    final color = _colorEstado(activo.estado);

    if (imagen == null) {
      return Container(
        width: 150,
        height: 170,
        decoration: BoxDecoration(
          color: fondo,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Icon(
          _iconoCategoria(activo.categoria),
          color: color,
          size: 64,
        ),
      );
    }

    return SizedBox(
      width: 170,
      height: 190,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 8,
            child: Container(
              width: 145,
              height: 165,
              decoration: BoxDecoration(
                color: fondo,
                borderRadius: BorderRadius.circular(34),
              ),
            ),
          ),
          Positioned(
            top: -8,
            child: Image.asset(
              imagen,
              width: 158,
              height: 178,
              fit: BoxFit.contain,
            ),
          ),
        ],
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

  Widget _listaActivos() {
    return StreamBuilder<List<Activo>>(
      stream: servicioActivos.obtenerActivos(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: GestionColors.acentoPrincipal,
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error al cargar activos: ${snapshot.error}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: GestionColors.textoSecundario,
              ),
            ),
          );
        }

        final activos = snapshot.data ?? [];

        if (activos.isEmpty) {
          return const Center(
            child: Text(
              'No hay activos registrados.',
              style: TextStyle(
                color: GestionColors.textoSecundario,
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 110),
          itemCount: activos.length,
          separatorBuilder: (context, index) {
            return const SizedBox(height: 18);
          },
          itemBuilder: (context, index) {
            final activo = activos[index];

            return Container(
              padding: const EdgeInsets.fromLTRB(10, 14, 18, 14),
              decoration: BoxDecoration(
                color: GestionColors.fondoTarjeta,
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
                    activo: activo,
                    index: index,
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activo.nombre,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: GestionColors.textoPrincipal,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${_textoCategoria(activo.categoria)} • ${activo.descripcion}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: GestionColors.textoSecundario,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Referencia: ${activo.referencia}',
                          style: const TextStyle(
                            color: GestionColors.textoSecundario,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _chipEstado(activo.estado),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _indicadorCantidad(
                              titulo: 'Disp.',
                              cantidad: activo.cantidadDisponible,
                              icono: Icons.check_circle_outline,
                              color: GestionColors.verde,
                            ),
                            _indicadorCantidad(
                              titulo: 'Prest.',
                              cantidad: activo.cantidadPrestada,
                              icono: Icons.assignment_outlined,
                              color: GestionColors.naranja,
                            ),
                            _indicadorCantidad(
                              titulo: 'Mant.',
                              cantidad: activo.cantidadMantenimiento,
                              icono: Icons.build_outlined,
                              color: GestionColors.azulGris,
                            ),
                            _indicadorCantidad(
                              titulo: 'Baja',
                              cantidad: activo.cantidadBaja,
                              icono: Icons.block_outlined,
                              color: GestionColors.gris,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Total registrado: ${activo.cantidadTotal}',
                          style: const TextStyle(
                            color: GestionColors.textoPrincipal,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _botonesGestion(activo),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _pantallaRestringida() {
    return const Scaffold(
      backgroundColor: GestionColors.fondoGeneral,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Acceso restringido. Solo el encargado de inventario puede gestionar activos.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: GestionColors.textoSecundario,
            ),
          ),
        ),
      ),
    );
  }

  Widget _botonesFlotantes() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton.small(
          heroTag: 'historial_prestamos',
          backgroundColor: GestionColors.fondoTarjeta,
          foregroundColor: GestionColors.textoPrincipal,
          elevation: 2,
          tooltip: 'Historial de préstamos',
          onPressed: () {
            Navigator.pushNamed(
              context,
              '/historial-prestamos',
            );
          },
          child: const Icon(Icons.history_outlined),
        ),
        const SizedBox(height: 12),
        FloatingActionButton.extended(
          heroTag: 'registrar_activo',
          backgroundColor: GestionColors.acentoSuave,
          foregroundColor: GestionColors.acentoPrincipal,
          elevation: 3,
          onPressed: procesando ? null : _abrirFormularioRegistro,
          icon: const Icon(Icons.add),
          label: const Text('Registrar activo'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PerfilUsuario?>(
      future: perfilFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: GestionColors.fondoGeneral,
            body: Center(
              child: CircularProgressIndicator(
                color: GestionColors.acentoPrincipal,
              ),
            ),
          );
        }

        final perfil = snapshot.data;

        final puedeGestionar = perfil != null &&
            perfil.estado == AccountStatus.active &&
            perfil.role == UserRole.encargadoInventario;

        if (!puedeGestionar) {
          return _pantallaRestringida();
        }

        return Scaffold(
          backgroundColor: GestionColors.fondoGeneral,
          floatingActionButton: _botonesFlotantes(),
          body: _listaActivos(),
        );
      },
    );
  }
}