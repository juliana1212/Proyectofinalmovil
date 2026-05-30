import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/activo.dart';
import '../models/perfil_usuario.dart';
import '../services/servicio_activos.dart';
import '../services/servicio_prestamos.dart';
import 'mis_prestamos_page.dart';

class AppColors {
  static const Color fondoGeneral = Color(0xFFF3F5FC);
  static const Color fondoTarjeta = Color(0xFFFFFFFF);
  static const Color fondoDestacado = Color(0xFFE9EEFF);
  static const Color acentoPrincipal = Color(0xFFFF8A73);
  static const Color acentoSuave = Color(0xFFFFE5DE);
  static const Color textoPrincipal = Color(0xFF24324A);
  static const Color textoSecundario = Color(0xFF8C93A8);
  static const Color fondoChip = Color(0xFFF5F6FA);
}

class HomeEstudiantePage extends StatefulWidget {
  const HomeEstudiantePage({super.key});

  @override
  State<HomeEstudiantePage> createState() => _HomeEstudiantePageState();
}

class _HomeEstudiantePageState extends State<HomeEstudiantePage> {
  int paginaSeleccionada = 0;

  final List<Widget> paginas = const [
    InicioEstudianteDashboard(),
    MisPrestamosPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondoGeneral,
      body: IndexedStack(
        index: paginaSeleccionada,
        children: paginas,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: paginaSeleccionada,
        backgroundColor: AppColors.fondoTarjeta,
        indicatorColor: AppColors.acentoSuave,
        onDestinationSelected: (index) {
          setState(() {
            paginaSeleccionada = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(
              Icons.home,
              color: AppColors.acentoPrincipal,
            ),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_ind_outlined),
            selectedIcon: Icon(
              Icons.assignment_ind,
              color: AppColors.acentoPrincipal,
            ),
            label: 'Préstamos',
          ),
        ],
      ),
    );
  }
}

class InicioEstudianteDashboard extends StatefulWidget {
  const InicioEstudianteDashboard({super.key});

  @override
  State<InicioEstudianteDashboard> createState() =>
      _InicioEstudianteDashboardState();
}

class _InicioEstudianteDashboardState
    extends State<InicioEstudianteDashboard> {
  final ServicioActivos servicioActivos = ServicioActivos();
  final ServicioPrestamos servicioPrestamos = ServicioPrestamos();

  late Future<PerfilUsuario?> perfilFuture;
  late Stream<List<Activo>> activosStream;
  late Stream<QuerySnapshot<Map<String, dynamic>>> prestamosStream;

  final Map<String, Future<Map<String, dynamic>?>> activosConsultados = {};

  Timer? temporizador;

  String categoriaSeleccionada = 'todos';

  @override
  void initState() {
    super.initState();

    perfilFuture = _obtenerPerfilActual();
    activosStream = servicioActivos.obtenerActivos();
    prestamosStream = _crearStreamPrestamosUsuario();

    temporizador = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (mounted) {
          setState(() {});
        }
      },
    );
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

  String _formatearNombre(String nombre, String correo) {
    if (nombre.trim().isNotEmpty) {
      return nombre.trim();
    }

    if (correo.trim().isNotEmpty) {
      return correo.split('@').first;
    }

    return 'Estudiante';
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
    switch (_categoriaNormalizada(categoria)) {
      case 'todos':
        return 'Todos';
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
          return 'Otros';
        }

        return '${categoria[0].toUpperCase()}${categoria.substring(1)}';
    }
  }

  IconData _iconoCategoria(String categoria) {
    switch (_categoriaNormalizada(categoria)) {
      case 'todos':
        return Icons.apps_outlined;
      case 'tablets':
        return Icons.tablet_android;
      case 'audio':
        return Icons.mic_none_outlined;
      case 'electronica':
        return Icons.devices_other_outlined;
      case 'computadoras':
        return Icons.laptop_mac;
      case 'tecnologicos':
        return Icons.memory_outlined;
      default:
        return Icons.inventory_2_outlined;
    }
  }

  String? _imagenCategoria(String categoria) {
    switch (_categoriaNormalizada(categoria)) {
      case 'audio':
        return 'assets/images/activos/parlantepic.png';
      case 'computadoras':
        return 'assets/images/activos/laptoppic.png';
      case 'tablets':
        return 'assets/images/activos/tabletpic.png';
      case 'electronica':
        return 'assets/images/activos/proyectorpic.png';
      default:
        return null;
    }
  }

  String _formatearFecha(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    final anio = fecha.year.toString();

    final hora = fecha.hour.toString().padLeft(2, '0');
    final minutos = fecha.minute.toString().padLeft(2, '0');

    return '$dia/$mes/$anio a las $hora:$minutos';
  }

  String _tiempoRestante(DateTime? fechaVencimiento) {
    if (fechaVencimiento == null) {
      return 'Sin fecha límite';
    }

    final diferencia = fechaVencimiento.difference(DateTime.now());

    if (diferencia.isNegative || diferencia.inSeconds <= 0) {
      return 'Préstamo vencido';
    }

    final horas = diferencia.inHours;
    final minutos = diferencia.inMinutes.remainder(60);
    final segundos = diferencia.inSeconds.remainder(60);

    return 'Te quedan ${horas}h ${minutos}min ${segundos}s';
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

  Stream<QuerySnapshot<Map<String, dynamic>>> _crearStreamPrestamosUsuario() {
    final usuarioId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return FirebaseFirestore.instance
        .collection('prestamos')
        .where('usuarioId', isEqualTo: usuarioId)
        .where('estado', whereIn: ['activo', 'vencido'])
        .snapshots();
  }

  Future<Map<String, dynamic>?> _obtenerActivoPorId(String activoId) {
    if (activoId.isEmpty) {
      return Future.value(null);
    }

    if (!activosConsultados.containsKey(activoId)) {
      activosConsultados[activoId] = FirebaseFirestore.instance
          .collection('activos')
          .doc(activoId)
          .get()
          .then((documento) => documento.data());
    }

    return activosConsultados[activoId]!;
  }

  Future<void> _cerrarSesion() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<void> _solicitarPrestamo(Activo activo) async {
    final usuarioId = FirebaseAuth.instance.currentUser?.uid;

    if (usuarioId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sesión no válida. Inicia sesión nuevamente.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final fechaVencimiento = await servicioPrestamos.solicitarPrestamo(
        activo.id,
        usuarioId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${activo.nombre} solicitado con éxito. '
            'Recuerda devolverlo hasta el '
            '${_formatearFecha(fechaVencimiento)}.',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 6),
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
    }
  }

  Widget _encabezado() {
    return FutureBuilder<PerfilUsuario?>(
      future: perfilFuture,
      builder: (context, snapshot) {
        final perfil = snapshot.data;

        final nombre = _formatearNombre(
          perfil?.nombre ?? '',
          perfil?.correo ?? '',
        );

        return Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hola, $nombre',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textoPrincipal,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Bienvenido',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textoSecundario,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Cerrar sesión',
              style: IconButton.styleFrom(
                backgroundColor: AppColors.acentoSuave,
                foregroundColor: AppColors.acentoPrincipal,
                fixedSize: const Size(52, 52),
              ),
              onPressed: _cerrarSesion,
              icon: const Icon(Icons.logout),
            ),
          ],
        );
      },
    );
  }

  Widget _tarjetaSinPrestamos() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.fondoDestacado,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Último préstamo',
                  style: TextStyle(
                    color: AppColors.textoSecundario,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'No tienes préstamos activos',
                  style: TextStyle(
                    color: AppColors.textoPrincipal,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Cuando solicites un activo, aparecerá aquí.',
                  style: TextStyle(
                    color: AppColors.textoSecundario,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.acentoSuave,
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: AppColors.acentoPrincipal,
              size: 54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagenUltimoPrestamo(String categoria) {
    final imagen = _imagenCategoria(categoria);

    if (imagen == null) {
      return Container(
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          color: AppColors.acentoSuave,
          borderRadius: BorderRadius.circular(36),
        ),
        child: Icon(
          _iconoCategoria(categoria),
          color: AppColors.acentoPrincipal,
          size: 78,
        ),
      );
    }

    return SizedBox(
      width: 190,
      height: 170,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 0,
            child: Container(
              width: 165,
              height: 145,
              decoration: BoxDecoration(
                color: AppColors.acentoSuave,
                borderRadius: BorderRadius.circular(36),
              ),
            ),
          ),
          Positioned(
            top: -18,
            child: Image.asset(
              imagen,
              width: 185,
              height: 185,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tarjetaUltimoPrestamo() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: prestamosStream,
      builder: (context, snapshot) {
        final prestamos = snapshot.data?.docs ?? [];

        if (prestamos.isEmpty) {
          return _tarjetaSinPrestamos();
        }

        prestamos.sort((a, b) {
          final fechaA = _convertirFecha(a.data()['fechaSolicitud']);
          final fechaB = _convertirFecha(b.data()['fechaSolicitud']);

          if (fechaA == null && fechaB == null) return 0;
          if (fechaA == null) return 1;
          if (fechaB == null) return -1;

          return fechaB.compareTo(fechaA);
        });

        final ultimo = prestamos.first.data();
        final activoId = (ultimo['activoId'] ?? '').toString();

        final fechaVencimiento = _convertirFecha(
          ultimo['fechaVencimiento'],
        );

        return FutureBuilder<Map<String, dynamic>?>(
          future: _obtenerActivoPorId(activoId),
          builder: (context, activoSnapshot) {
            final activo = activoSnapshot.data;

            final nombreActivo =
                (activo?['nombre'] ?? 'Activo solicitado').toString();

            final categoria =
                (activo?['categoria'] ?? 'Sin categoría').toString();

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 24, 18, 18),
              decoration: BoxDecoration(
                color: AppColors.fondoDestacado,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Último activo prestado',
                          style: TextStyle(
                            color: AppColors.textoSecundario,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          nombreActivo,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textoPrincipal,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _textoCategoria(categoria),
                          style: const TextStyle(
                            color: AppColors.textoSecundario,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.acentoPrincipal,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _tiempoRestante(fechaVencimiento),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  _imagenUltimoPrestamo(categoria),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _tituloSeccion(String titulo) {
    return Text(
      titulo,
      style: const TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.bold,
        color: AppColors.textoPrincipal,
      ),
    );
  }

  Widget _seccionCategorias(List<Activo> activos) {
    final categorias = activos
        .map((activo) => _categoriaNormalizada(activo.categoria))
        .toSet()
        .toList()
      ..sort();

    final opciones = ['todos', ...categorias];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _tituloSeccion('Categorías'),
        const SizedBox(height: 14),
        SizedBox(
          height: 108,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: opciones.length,
            separatorBuilder: (context, index) {
              return const SizedBox(width: 14);
            },
            itemBuilder: (context, index) {
              final categoria = opciones[index];
              final seleccionado = categoriaSeleccionada == categoria;

              final cantidad = categoria == 'todos'
                  ? activos.length
                  : activos
                      .where(
                        (activo) =>
                            _categoriaNormalizada(activo.categoria) ==
                            categoria,
                      )
                      .length;

              return CategoriaIconoAnimado(
                categoria: categoria,
                texto: '${_textoCategoria(categoria)} ($cantidad)',
                icono: _iconoCategoria(categoria),
                seleccionado: seleccionado,
                onTap: () {
                  setState(() {
                    categoriaSeleccionada = categoria;
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _tarjetaActivoDisponible(Activo activo) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () {
        _solicitarPrestamo(activo);
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.fondoTarjeta,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(12),
              blurRadius: 14,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: AppColors.acentoSuave,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                _iconoCategoria(activo.categoria),
                color: AppColors.acentoPrincipal,
                size: 30,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activo.nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.textoPrincipal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_textoCategoria(activo.categoria)} • ${activo.cantidadDisponible} disponibles',
                    style: const TextStyle(
                      color: AppColors.textoSecundario,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Toca para solicitar préstamo',
                    style: TextStyle(
                      color: AppColors.acentoPrincipal,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.acentoSuave,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.add,
                size: 18,
                color: AppColors.acentoPrincipal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _activosDisponibles(List<Activo> activos) {
    final disponibles = activos
        .where(
          (activo) =>
              activo.estado == 'disponible' &&
              activo.cantidadDisponible > 0,
        )
        .where(
          (activo) =>
              categoriaSeleccionada == 'todos' ||
              _categoriaNormalizada(activo.categoria) ==
                  categoriaSeleccionada,
        )
        .toList();

    if (disponibles.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.fondoTarjeta,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          categoriaSeleccionada == 'todos'
              ? 'No hay activos disponibles para prestar en este momento.'
              : 'No hay activos disponibles en la categoría ${_textoCategoria(categoriaSeleccionada)}.',
          style: const TextStyle(
            color: AppColors.textoSecundario,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _tituloSeccion(
          categoriaSeleccionada == 'todos'
              ? 'Disponibles para prestar'
              : 'Disponibles en ${_textoCategoria(categoriaSeleccionada)}',
        ),
        const SizedBox(height: 12),
        ...disponibles.map(_tarjetaActivoDisponible),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondoGeneral,
      body: SafeArea(
        child: StreamBuilder<List<Activo>>(
          stream: activosStream,
          builder: (context, snapshot) {
            final activos = snapshot.data ?? [];

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _encabezado(),
                  const SizedBox(height: 24),
                  _tarjetaUltimoPrestamo(),
                  const SizedBox(height: 28),
                  _seccionCategorias(activos),
                  const SizedBox(height: 22),
                  _activosDisponibles(activos),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class CategoriaIconoAnimado extends StatefulWidget {
  final String categoria;
  final String texto;
  final IconData icono;
  final bool seleccionado;
  final VoidCallback onTap;

  const CategoriaIconoAnimado({
    super.key,
    required this.categoria,
    required this.texto,
    required this.icono,
    required this.seleccionado,
    required this.onTap,
  });

  @override
  State<CategoriaIconoAnimado> createState() =>
      _CategoriaIconoAnimadoState();
}

class _CategoriaIconoAnimadoState extends State<CategoriaIconoAnimado> {
  bool encima = false;

  @override
  Widget build(BuildContext context) {
    final activo = widget.seleccionado || encima;

    return MouseRegion(
      onEnter: (_) {
        setState(() {
          encima = true;
        });
      },
      onExit: (_) {
        setState(() {
          encima = false;
        });
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: encima ? 1.08 : 1.0,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          child: SizedBox(
            width: 92,
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  width: activo ? 68 : 62,
                  height: activo ? 68 : 62,
                  decoration: BoxDecoration(
                    color: widget.seleccionado
                        ? AppColors.acentoPrincipal
                        : encima
                            ? AppColors.acentoSuave
                            : AppColors.fondoChip,
                    shape: BoxShape.circle,
                    boxShadow: activo
                        ? [
                            BoxShadow(
                              color: AppColors.acentoPrincipal.withAlpha(70),
                              blurRadius: 14,
                              offset: const Offset(0, 7),
                            ),
                          ]
                        : [],
                  ),
                  child: Icon(
                    widget.icono,
                    color: widget.seleccionado
                        ? Colors.white
                        : AppColors.acentoPrincipal,
                    size: activo ? 31 : 28,
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 180),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: activo ? FontWeight.bold : FontWeight.w500,
                    color: activo
                        ? AppColors.acentoPrincipal
                        : AppColors.textoPrincipal,
                  ),
                  child: Text(
                    widget.texto,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}