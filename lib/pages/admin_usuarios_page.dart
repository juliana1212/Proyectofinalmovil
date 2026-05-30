// lib/pages/admin_usuarios_page.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/enums.dart';
import '../models/perfil_usuario.dart';

class AdminColors {
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

class AdminUsuariosPage extends StatefulWidget {
  const AdminUsuariosPage({super.key});

  @override
  State<AdminUsuariosPage> createState() => _AdminUsuariosPageState();
}

class _AdminUsuariosPageState extends State<AdminUsuariosPage> {
  int paginaSeleccionada = 0;

  final List<String> estados = [
    'pendingApproval',
    'active',
    'blocked',
  ];

  Future<void> _cerrarSesion() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushReplacementNamed(context, '/login');
  }

  String _tituloPagina() {
    switch (paginaSeleccionada) {
      case 0:
        return 'Usuarios pendientes';
      case 1:
        return 'Usuarios activos';
      case 2:
        return 'Usuarios bloqueados';
      default:
        return 'Gestión de usuarios';
    }
  }

  String _subtituloPagina() {
    switch (paginaSeleccionada) {
      case 0:
        return 'Aprueba o bloquea las cuentas nuevas.';
      case 1:
        return 'Consulta usuarios aprobados y sus activos asignados.';
      case 2:
        return 'Administra usuarios que no pueden ingresar.';
      default:
        return 'Administra el acceso de los usuarios.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.fondoGeneral,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Gestión de usuarios',
                          style: TextStyle(
                            color: AdminColors.textoPrincipal,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _subtituloPagina(),
                          style: const TextStyle(
                            color: AdminColors.textoSecundario,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Cerrar sesión',
                    style: IconButton.styleFrom(
                      backgroundColor: AdminColors.acentoSuave,
                      foregroundColor: AdminColors.acentoPrincipal,
                      fixedSize: const Size(52, 52),
                    ),
                    onPressed: _cerrarSesion,
                    icon: const Icon(Icons.logout),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _tituloPagina(),
                  style: const TextStyle(
                    color: AdminColors.textoPrincipal,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: paginaSeleccionada,
                children: const [
                  _ListaUsuarios(filtroEstado: 'pendingApproval'),
                  _ListaUsuarios(filtroEstado: 'active'),
                  _ListaUsuarios(filtroEstado: 'blocked'),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: paginaSeleccionada,
        backgroundColor: AdminColors.fondoTarjeta,
        indicatorColor: AdminColors.acentoSuave,
        onDestinationSelected: (index) {
          setState(() {
            paginaSeleccionada = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.pending_outlined),
            selectedIcon: Icon(
              Icons.pending,
              color: AdminColors.acentoPrincipal,
            ),
            label: 'Pendientes',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(
              Icons.people,
              color: AdminColors.acentoPrincipal,
            ),
            label: 'Activos',
          ),
          NavigationDestination(
            icon: Icon(Icons.block_outlined),
            selectedIcon: Icon(
              Icons.block,
              color: AdminColors.acentoPrincipal,
            ),
            label: 'Bloqueados',
          ),
        ],
      ),
    );
  }
}

class _ListaUsuarios extends StatelessWidget {
  final String filtroEstado;

  const _ListaUsuarios({
    required this.filtroEstado,
  });

  IconData get _iconoVacio {
    if (filtroEstado == 'pendingApproval') {
      return Icons.inbox_outlined;
    }

    if (filtroEstado == 'active') {
      return Icons.people_outline;
    }

    return Icons.block_outlined;
  }

  String get _textoVacio {
    if (filtroEstado == 'pendingApproval') {
      return 'No hay usuarios pendientes.';
    }

    if (filtroEstado == 'active') {
      return 'No hay usuarios activos.';
    }

    return 'No hay usuarios bloqueados.';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('status', isEqualTo: filtroEstado)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: AdminColors.acentoPrincipal,
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Error al cargar usuarios:\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AdminColors.rojo,
                ),
              ),
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return Center(
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                color: AdminColors.fondoTarjeta,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 18,
                    offset: const Offset(0, 9),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 78,
                    height: 78,
                    decoration: BoxDecoration(
                      color: AdminColors.acentoSuave,
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: Icon(
                      _iconoVacio,
                      size: 42,
                      color: AdminColors.acentoPrincipal,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _textoVacio,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AdminColors.textoPrincipal,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Cuando haya usuarios en esta sección aparecerán aquí.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AdminColors.textoSecundario,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(22, 4, 22, 100),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 18),
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final perfil = PerfilUsuario.fromMap(data, doc.id);

            return _TarjetaUsuario(
              perfil: perfil,
              docId: doc.id,
              index: index,
            );
          },
        );
      },
    );
  }
}

class _TarjetaUsuario extends StatefulWidget {
  final PerfilUsuario perfil;
  final String docId;
  final int index;

  const _TarjetaUsuario({
    required this.perfil,
    required this.docId,
    required this.index,
  });

  @override
  State<_TarjetaUsuario> createState() => _TarjetaUsuarioState();
}

class _TarjetaUsuarioState extends State<_TarjetaUsuario> {
  bool _procesando = false;

  Color get _colorEstado {
    switch (widget.perfil.estado) {
      case AccountStatus.active:
        return AdminColors.verde;
      case AccountStatus.blocked:
        return AdminColors.rojo;
      case AccountStatus.pendingApproval:
        return AdminColors.naranja;
    }
  }

  String get _textoEstado {
    switch (widget.perfil.estado) {
      case AccountStatus.active:
        return 'Activo';
      case AccountStatus.blocked:
        return 'Bloqueado';
      case AccountStatus.pendingApproval:
        return 'Pendiente';
    }
  }

  IconData get _iconoEstado {
    switch (widget.perfil.estado) {
      case AccountStatus.active:
        return Icons.check_circle_outline;
      case AccountStatus.blocked:
        return Icons.block_outlined;
      case AccountStatus.pendingApproval:
        return Icons.pending_outlined;
    }
  }

  String get _textoRol {
    switch (widget.perfil.role) {
      case UserRole.administrador:
        return 'Administrador';
      case UserRole.encargadoInventario:
        return 'Encargado de inventario';
      case UserRole.solicitante:
        return 'Estudiante';
    }
  }

  IconData get _iconoRol {
    switch (widget.perfil.role) {
      case UserRole.administrador:
        return Icons.admin_panel_settings_outlined;
      case UserRole.encargadoInventario:
        return Icons.inventory_2_outlined;
      case UserRole.solicitante:
        return Icons.school_outlined;
    }
  }

  Color _fondoDecorativo() {
    if (widget.index % 3 == 0) {
      return AdminColors.azulSuave;
    }

    if (widget.index % 3 == 1) {
      return AdminColors.cremaSuave;
    }

    return AdminColors.verdeSuave;
  }

  @override
  Widget build(BuildContext context) {
    final nombre = widget.perfil.nombre.isNotEmpty
        ? widget.perfil.nombre
        : '(Sin nombre)';

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 18, 16),
      decoration: BoxDecoration(
        color: AdminColors.fondoTarjeta,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: _fondoDecorativo(),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Icon(
              _iconoRol,
              color: _colorEstado,
              size: 42,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        nombre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AdminColors.textoPrincipal,
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _chipEstado(),
                  ],
                ),
                const SizedBox(height: 8),
                _lineaInfo(
                  icono: Icons.email_outlined,
                  texto: widget.perfil.correo,
                ),
                const SizedBox(height: 5),
                _lineaInfo(
                  icono: Icons.badge_outlined,
                  texto: _textoRol,
                ),
                const SizedBox(height: 14),
                if (_procesando)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: LinearProgressIndicator(
                      color: AdminColors.acentoPrincipal,
                      backgroundColor: AdminColors.acentoSuave,
                    ),
                  )
                else
                  _botonesAccion(),
                const SizedBox(height: 12),
                Divider(
                  color: Colors.grey.shade200,
                  height: 1,
                ),
                const SizedBox(height: 10),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: AdminColors.acentoPrincipal,
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: () => _verActivosAsignados(context),
                  icon: const Icon(
                    Icons.inventory_2_outlined,
                    size: 18,
                  ),
                  label: const Text(
                    'Ver activos asignados',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chipEstado() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: _colorEstado.withAlpha(24),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _iconoEstado,
            color: _colorEstado,
            size: 15,
          ),
          const SizedBox(width: 5),
          Text(
            _textoEstado,
            style: TextStyle(
              color: _colorEstado,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _lineaInfo({
    required IconData icono,
    required String texto,
  }) {
    return Row(
      children: [
        Icon(
          icono,
          size: 16,
          color: AdminColors.textoSecundario,
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            texto,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AdminColors.textoSecundario,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _botonesAccion() {
    final estado = widget.perfil.estado;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (estado == AccountStatus.pendingApproval)
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AdminColors.verde,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            icon: const Icon(Icons.check, size: 18),
            label: const Text('Aprobar'),
            onPressed: () => _cambiarEstado('active'),
          ),
        if (estado == AccountStatus.blocked)
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AdminColors.azul,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            icon: const Icon(Icons.lock_open_outlined, size: 18),
            label: const Text('Activar'),
            onPressed: () => _cambiarEstado('active'),
          ),
        if (estado == AccountStatus.active ||
            estado == AccountStatus.pendingApproval)
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AdminColors.rojo,
              side: const BorderSide(
                color: AdminColors.rojo,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            icon: const Icon(Icons.block_outlined, size: 18),
            label: const Text('Bloquear'),
            onPressed: _confirmarBloqueo,
          ),
        if (estado == AccountStatus.active ||
            estado == AccountStatus.blocked)
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AdminColors.naranja,
              side: const BorderSide(
                color: AdminColors.naranja,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            icon: const Icon(Icons.hourglass_empty_outlined, size: 18),
            label: const Text('Poner pendiente'),
            onPressed: () => _cambiarEstado('pendingApproval'),
          ),
      ],
    );
  }

  Future<void> _confirmarBloqueo() async {
    final nombre = widget.perfil.nombre.isNotEmpty
        ? widget.perfil.nombre
        : widget.perfil.correo;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 430,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AdminColors.fondoTarjeta,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(18),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: AdminColors.acentoSuave,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.block_outlined,
                    color: AdminColors.rojo,
                    size: 38,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Bloquear usuario',
                  style: TextStyle(
                    color: AdminColors.textoPrincipal,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '¿Seguro que quieres bloquear a "$nombre"?\n\nNo podrá iniciar sesión hasta que lo actives nuevamente.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AdminColors.textoSecundario,
                    fontSize: 14,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AdminColors.acentoPrincipal,
                          side: const BorderSide(
                            color: AdminColors.acentoPrincipal,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AdminColors.rojo,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: const Text('Bloquear'),
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

    if (confirmar == true) {
      await _cambiarEstado('blocked');
    }
  }

  Future<void> _cambiarEstado(String nuevoEstado) async {
    setState(() {
      _procesando = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.docId)
          .update({'status': nuevoEstado});

      if (!mounted) return;

      final mensaje = switch (nuevoEstado) {
        'active' => 'Usuario activado correctamente.',
        'blocked' => 'Usuario bloqueado.',
        'pendingApproval' => 'Usuario puesto en pendiente.',
        _ => 'Estado actualizado.',
      };

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: nuevoEstado == 'active'
              ? AdminColors.verde
              : nuevoEstado == 'blocked'
                  ? AdminColors.rojo
                  : AdminColors.naranja,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar: $e'),
          backgroundColor: AdminColors.rojo,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _procesando = false;
        });
      }
    }
  }

  Future<void> _verActivosAsignados(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ModalActivosAsignados(
        uid: widget.docId,
        nombreUsuario: widget.perfil.nombre.isNotEmpty
            ? widget.perfil.nombre
            : widget.perfil.correo,
      ),
    );
  }
}

class _ModalActivosAsignados extends StatelessWidget {
  final String uid;
  final String nombreUsuario;

  const _ModalActivosAsignados({
    required this.uid,
    required this.nombreUsuario,
  });

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

  String _formatearFecha(dynamic fecha) {
    try {
      if (fecha is Timestamp) {
        final dt = fecha.toDate();

        return '${dt.day.toString().padLeft(2, '0')}/'
            '${dt.month.toString().padLeft(2, '0')}/'
            '${dt.year}';
      }

      return fecha.toString();
    } catch (_) {
      return '—';
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.35,
      maxChildSize: 0.92,
      expand: false,
      builder: (ctx, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AdminColors.fondoGeneral,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(34),
            ),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 8, 14, 16),
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: AdminColors.acentoSuave,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.inventory_2_outlined,
                        color: AdminColors.acentoPrincipal,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Activos de $nombreUsuario',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AdminColors.textoPrincipal,
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      color: AdminColors.textoPrincipal,
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('prestamos')
                      .where('usuarioId', isEqualTo: uid)
                      .where('estado', isEqualTo: 'activo')
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AdminColors.acentoPrincipal,
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error: ${snapshot.error}',
                          style: const TextStyle(
                            color: AdminColors.rojo,
                          ),
                        ),
                      );
                    }

                    final prestamos = snapshot.data?.docs ?? [];

                    if (prestamos.isEmpty) {
                      return Center(
                        child: Container(
                          margin: const EdgeInsets.all(24),
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AdminColors.fondoTarjeta,
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.inbox_outlined,
                                size: 48,
                                color: AdminColors.textoSecundario,
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Este usuario no tiene activos asignados.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AdminColors.textoPrincipal,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(22, 4, 22, 24),
                      itemCount: prestamos.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final data =
                            prestamos[index].data() as Map<String, dynamic>;

                        final activoId =
                            (data['activoId'] ?? '').toString();

                        final fechaSolicitud = data['fechaSolicitud'];
                        final fechaVencimiento = data['fechaVencimiento'];

                        return FutureBuilder<DocumentSnapshot>(
                          future: activoId.isNotEmpty
                              ? FirebaseFirestore.instance
                                  .collection('activos')
                                  .doc(activoId)
                                  .get()
                              : Future.value(null as DocumentSnapshot?),
                          builder: (ctx, snapActivo) {
                            String nombreActivo = 'Cargando...';
                            String categoriaActivo = '';

                            if (snapActivo.hasData &&
                                snapActivo.data != null &&
                                snapActivo.data!.exists) {
                              final activoData = snapActivo.data!.data()
                                  as Map<String, dynamic>;

                              nombreActivo =
                                  (activoData['nombre'] ?? 'Sin nombre')
                                      .toString();

                              categoriaActivo =
                                  (activoData['categoria'] ?? '').toString();
                            }

                            return Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AdminColors.fondoTarjeta,
                                borderRadius: BorderRadius.circular(26),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(8),
                                    blurRadius: 14,
                                    offset: const Offset(0, 7),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      color: AdminColors.azulSuave,
                                      borderRadius:
                                          BorderRadius.circular(20),
                                    ),
                                    child: Icon(
                                      _iconoCategoria(
                                        categoria: categoriaActivo,
                                        nombreActivo: nombreActivo,
                                      ),
                                      color: AdminColors.acentoPrincipal,
                                      size: 32,
                                    ),
                                  ),
                                  const SizedBox(width: 13),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          nombreActivo,
                                          maxLines: 1,
                                          overflow:
                                              TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color:
                                                AdminColors.textoPrincipal,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if (categoriaActivo.isNotEmpty) ...[
                                          const SizedBox(height: 3),
                                          Text(
                                            categoriaActivo,
                                            style: const TextStyle(
                                              color: AdminColors
                                                  .textoSecundario,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                        const SizedBox(height: 6),
                                        Text(
                                          'Préstamo: ${_formatearFecha(fechaSolicitud)}',
                                          style: const TextStyle(
                                            color:
                                                AdminColors.textoSecundario,
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text(
                                          'Vence: ${_formatearFecha(fechaVencimiento)}',
                                          style: const TextStyle(
                                            color: AdminColors.naranja,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          AdminColors.azul.withAlpha(25),
                                      borderRadius:
                                          BorderRadius.circular(16),
                                    ),
                                    child: const Text(
                                      'Activo',
                                      style: TextStyle(
                                        color: AdminColors.azul,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}