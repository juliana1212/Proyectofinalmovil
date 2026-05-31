import 'package:flutter/material.dart';

import '../models/activo.dart';
import '../services/servicio_activos.dart';

class ActivosColors {
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

class ActivosPage extends StatefulWidget {
  const ActivosPage({super.key});

  @override
  State<ActivosPage> createState() => _ActivosPageState();
}

class _ActivosPageState extends State<ActivosPage> {
  final ServicioActivos servicioActivos = ServicioActivos();

  String categoriaSeleccionada = 'todos';

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

  String _categoriaNormalizada(String categoria) {
    final texto = _normalizarTexto(categoria);

    if (texto.isEmpty) {
      return 'sin categoria';
    }

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

  String? _imagenCategoria(String categoria, String nombreActivo) {
    final categoriaNormalizada = _categoriaNormalizada(categoria);
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
        return 'assets/images/activos/proyectorpic.png';
      default:
        return null;
    }
  }

  String _estadoVisible(Activo activo) {
    final todasDadasDeBaja = activo.cantidadBaja >= activo.cantidadTotal;

    if (todasDadasDeBaja) {
      return 'dadoDeBaja';
    }

    if (activo.estado == 'disponible' && activo.cantidadDisponible <= 0) {
      return 'sinUnidades';
    }

    return activo.estado;
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
      case 'sinUnidades':
        return 'Sin unidades';
      default:
        return estado;
    }
  }

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'disponible':
        return ActivosColors.verde;
      case 'prestado':
        return ActivosColors.naranja;
      case 'vencido':
        return ActivosColors.rojo;
      case 'mantenimiento':
        return ActivosColors.azulGris;
      case 'dadoDeBaja':
        return ActivosColors.gris;
      case 'sinUnidades':
        return ActivosColors.gris;
      default:
        return ActivosColors.textoSecundario;
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
      case 'sinUnidades':
        return Icons.inventory_2_outlined;
      default:
        return Icons.help_outline;
    }
  }

  Color _colorDecorativo(int index) {
    if (index % 4 == 0) {
      return ActivosColors.azulSuave;
    }

    if (index % 4 == 1) {
      return ActivosColors.cremaSuave;
    }

    if (index % 4 == 2) {
      return ActivosColors.verdeSuave;
    }

    return ActivosColors.acentoSuave;
  }

  Widget _tituloSeccion(String titulo) {
    return Text(
      titulo,
      style: const TextStyle(
        color: ActivosColors.textoPrincipal,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _resumenInventario(List<Activo> activos) {
    int disponibles = 0;
    int prestados = 0;
    int mantenimiento = 0;
    int bajas = 0;

    for (final activo in activos) {
      disponibles += activo.cantidadDisponible;
      prestados += activo.cantidadPrestada;
      mantenimiento += activo.cantidadMantenimiento;
      bajas += activo.cantidadBaja;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        children: [
          _miniResumen(
            titulo: 'Disponibles',
            valor: '$disponibles',
            icono: Icons.check_circle_outline,
            fondo: ActivosColors.verdeSuave,
            color: ActivosColors.verde,
          ),
          const SizedBox(width: 10),
          _miniResumen(
            titulo: 'Prestados',
            valor: '$prestados',
            icono: Icons.assignment_outlined,
            fondo: ActivosColors.cremaSuave,
            color: ActivosColors.naranja,
          ),
          const SizedBox(width: 10),
          _miniResumen(
            titulo: 'Mant.',
            valor: '$mantenimiento',
            icono: Icons.build_outlined,
            fondo: ActivosColors.azulSuave,
            color: ActivosColors.azulGris,
          ),
          const SizedBox(width: 10),
          _miniResumen(
            titulo: 'Baja',
            valor: '$bajas',
            icono: Icons.block_outlined,
            fondo: ActivosColors.grisSuave,
            color: ActivosColors.gris,
          ),
        ],
      ),
    );
  }

  Widget _miniResumen({
    required String titulo,
    required String valor,
    required IconData icono,
    required Color fondo,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: fondo,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(icono, color: color, size: 22),
            const SizedBox(height: 5),
            Text(
              valor,
              style: const TextStyle(
                color: ActivosColors.textoPrincipal,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              titulo,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: ActivosColors.textoSecundario,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _seccionCategorias(List<Activo> activos) {
    final activosDisponibles = activos.where((activo) {
      final estado = _estadoVisible(activo);

      return estado == 'disponible' && activo.cantidadDisponible > 0;
    }).toList();

    final categorias =
        activosDisponibles
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
                  ? activosDisponibles.length
                  : activosDisponibles
                        .where(
                          (activo) =>
                              _categoriaNormalizada(activo.categoria) ==
                              categoria,
                        )
                        .length;
              return CategoriaActivoAnimada(
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

  Widget _imagenActivo({
    required String categoria,
    required String nombreActivo,
    required Color fondo,
    required String estado,
  }) {
    final imagen = _imagenCategoria(categoria, nombreActivo);
    final colorEstado = _colorEstado(estado);

    if (imagen == null) {
      return Container(
        width: 150,
        height: 170,
        decoration: BoxDecoration(
          color: fondo,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Icon(_iconoCategoria(categoria), color: colorEstado, size: 64),
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
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(28),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_iconoEstado(estado), color: color, size: 15),
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

  Widget _datoCantidad({
    required String titulo,
    required int cantidad,
    required IconData icono,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, color: color, size: 16),
          const SizedBox(width: 5),
          Text(
            '$titulo: $cantidad',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tarjetaActivo(Activo activo, int index) {
    final estado = _estadoVisible(activo);
    final fondo = _colorDecorativo(index);

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.fromLTRB(10, 14, 18, 14),
      decoration: BoxDecoration(
        color: ActivosColors.fondoTarjeta,
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
          _imagenActivo(
            categoria: activo.categoria,
            nombreActivo: activo.nombre,
            fondo: fondo,
            estado: estado,
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
                    color: ActivosColors.textoPrincipal,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _textoCategoria(activo.categoria),
                  style: const TextStyle(
                    color: ActivosColors.textoSecundario,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  activo.descripcion,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ActivosColors.textoSecundario,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 10),
                _chipEstado(estado),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _datoCantidad(
                      titulo: 'Disp.',
                      cantidad: activo.cantidadDisponible,
                      icono: Icons.check_circle_outline,
                      color: ActivosColors.verde,
                    ),
                    _datoCantidad(
                      titulo: 'Prest.',
                      cantidad: activo.cantidadPrestada,
                      icono: Icons.assignment_outlined,
                      color: ActivosColors.naranja,
                    ),
                    _datoCantidad(
                      titulo: 'Mant.',
                      cantidad: activo.cantidadMantenimiento,
                      icono: Icons.build_outlined,
                      color: ActivosColors.azulGris,
                    ),
                    _datoCantidad(
                      titulo: 'Baja',
                      cantidad: activo.cantidadBaja,
                      icono: Icons.block_outlined,
                      color: ActivosColors.gris,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Total registrado: ${activo.cantidadTotal}',
                  style: const TextStyle(
                    color: ActivosColors.textoPrincipal,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _listaActivos(List<Activo> activos) {
    final filtrados = categoriaSeleccionada == 'todos'
        ? activos
        : activos
              .where(
                (activo) =>
                    _categoriaNormalizada(activo.categoria) ==
                    categoriaSeleccionada,
              )
              .toList();

    if (filtrados.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: ActivosColors.fondoTarjeta,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Text(
          categoriaSeleccionada == 'todos'
              ? 'No hay activos registrados.'
              : 'No hay activos en la categoría ${_textoCategoria(categoriaSeleccionada)}.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: ActivosColors.textoSecundario),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _tituloSeccion(
          categoriaSeleccionada == 'todos'
              ? 'Listado de activos'
              : 'Activos en ${_textoCategoria(categoriaSeleccionada)}',
        ),
        const SizedBox(height: 14),
        ...filtrados.asMap().entries.map(
          (entry) => _tarjetaActivo(entry.value, entry.key),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ActivosColors.fondoGeneral,
      body: StreamBuilder<List<Activo>>(
        stream: servicioActivos.obtenerActivos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: ActivosColors.acentoPrincipal,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Error al cargar activos: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: ActivosColors.textoSecundario),
                ),
              ),
            );
          }

          final activos = snapshot.data ?? [];

          if (activos.isEmpty) {
            return const Center(
              child: Text(
                'No hay activos registrados.',
                style: TextStyle(color: ActivosColors.textoSecundario),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 4, 22, 90),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _resumenInventario(activos),
                _seccionCategorias(activos),
                const SizedBox(height: 22),
                _listaActivos(activos),
              ],
            ),
          );
        },
      ),
    );
  }
}

class CategoriaActivoAnimada extends StatefulWidget {
  final String texto;
  final IconData icono;
  final bool seleccionado;
  final VoidCallback onTap;

  const CategoriaActivoAnimada({
    super.key,
    required this.texto,
    required this.icono,
    required this.seleccionado,
    required this.onTap,
  });

  @override
  State<CategoriaActivoAnimada> createState() => _CategoriaActivoAnimadaState();
}

class _CategoriaActivoAnimadaState extends State<CategoriaActivoAnimada> {
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
            width: 98,
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  width: activo ? 68 : 62,
                  height: activo ? 68 : 62,
                  decoration: BoxDecoration(
                    color: widget.seleccionado
                        ? ActivosColors.acentoPrincipal
                        : encima
                        ? ActivosColors.acentoSuave
                        : ActivosColors.fondoTarjeta,
                    shape: BoxShape.circle,
                    boxShadow: activo
                        ? [
                            BoxShadow(
                              color: ActivosColors.acentoPrincipal.withAlpha(
                                70,
                              ),
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
                        : ActivosColors.acentoPrincipal,
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
                        ? ActivosColors.acentoPrincipal
                        : ActivosColors.textoPrincipal,
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
