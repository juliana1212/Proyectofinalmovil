// lib/pages/admin_usuarios_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
 
import '../models/enums.dart';
import '../models/perfil_usuario.dart';
 
class AdminUsuariosPage extends StatefulWidget {
  const AdminUsuariosPage({super.key});
 
  @override
  State<AdminUsuariosPage> createState() => _AdminUsuariosPageState();
}
 
class _AdminUsuariosPageState extends State<AdminUsuariosPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
 
  @override
  void initState() {
    super.initState();
    // 3 tabs: pendientes / activos / bloqueados
    _tabController = TabController(length: 3, vsync: this);
  }
 
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
 
  Future<void> _cerrarSesion() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }
 
  @override
  Widget build(BuildContext context) {
    // ── NO reverificamos el rol aquí ────────────────────────────────────────
    // El login_page ya lo verificó antes de navegar a esta ruta.
    // Reverificar de forma asíncrona causaba que la pantalla mostrara
    // "Acceso denegado" mientras esperaba Firestore.
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // sin flecha de regreso
        title: const Text('Gestión de usuarios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: _cerrarSesion,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.pending_outlined), text: 'Pendientes'),
            Tab(icon: Icon(Icons.people_outline), text: 'Activos'),
            Tab(icon: Icon(Icons.block_outlined), text: 'Bloqueados'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ListaUsuarios(filtroEstado: 'pendingApproval'),
          _ListaUsuarios(filtroEstado: 'active'),
          _ListaUsuarios(filtroEstado: 'blocked'),
        ],
      ),
    );
  }
}
 
// ─────────────────────────────────────────────────────────────────────────────
// Lista de usuarios filtrada por estado (StreamBuilder en tiempo real)
// ─────────────────────────────────────────────────────────────────────────────
class _ListaUsuarios extends StatelessWidget {
  final String filtroEstado;
 
  const _ListaUsuarios({required this.filtroEstado});
 
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('status', isEqualTo: filtroEstado)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
 
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Error al cargar usuarios:\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }
 
        final docs = snapshot.data?.docs ?? [];
 
        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  filtroEstado == 'pendingApproval'
                      ? Icons.inbox_outlined
                      : filtroEstado == 'active'
                          ? Icons.people_outline
                          : Icons.block_outlined,
                  size: 56,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 12),
                Text(
                  filtroEstado == 'pendingApproval'
                      ? 'No hay usuarios pendientes.'
                      : filtroEstado == 'active'
                          ? 'No hay usuarios activos.'
                          : 'No hay usuarios bloqueados.',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }
 
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final perfil = PerfilUsuario.fromMap(data, doc.id);
 
            return _TarjetaUsuario(perfil: perfil, docId: doc.id);
          },
        );
      },
    );
  }
}
 
// ─────────────────────────────────────────────────────────────────────────────
// Tarjeta de usuario con acciones
// ─────────────────────────────────────────────────────────────────────────────
class _TarjetaUsuario extends StatefulWidget {
  final PerfilUsuario perfil;
  final String docId;
 
  const _TarjetaUsuario({required this.perfil, required this.docId});
 
  @override
  State<_TarjetaUsuario> createState() => _TarjetaUsuarioState();
}
 
class _TarjetaUsuarioState extends State<_TarjetaUsuario> {
  bool _procesando = false;
 
  Color get _colorEstado {
    switch (widget.perfil.estado) {
      case AccountStatus.active:
        return Colors.green;
      case AccountStatus.blocked:
        return Colors.red;
      case AccountStatus.pendingApproval:
        return Colors.orange;
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
 
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Nombre + badge estado ──────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.perfil.nombre.isNotEmpty
                        ? widget.perfil.nombre
                        : '(Sin nombre)',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _colorEstado.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _colorEstado),
                  ),
                  child: Text(
                    _textoEstado,
                    style: TextStyle(
                        color: _colorEstado,
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
 
            // ── Correo ────────────────────────────────────────────────────
            Row(
              children: [
                const Icon(Icons.email_outlined, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    widget.perfil.correo,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
 
            // ── Rol ───────────────────────────────────────────────────────
            Row(
              children: [
                const Icon(Icons.badge_outlined, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(_textoRol,
                    style:
                        const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 14),
 
            // ── Botones de acción ─────────────────────────────────────────
            if (_procesando)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: CircularProgressIndicator(),
                ),
              )
            else
              _botonesAccion(),
 
            const Divider(height: 20),
 
            // ── Ver activos asignados ─────────────────────────────────────
            TextButton.icon(
              onPressed: () => _verActivosAsignados(context),
              icon: const Icon(Icons.inventory_2_outlined, size: 18),
              label: const Text('Ver activos asignados'),
            ),
          ],
        ),
      ),
    );
  }
 
  Widget _botonesAccion() {
    final estado = widget.perfil.estado;
 
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // Aprobar → solo cuando está pendiente
        if (estado == AccountStatus.pendingApproval)
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.check, size: 18),
            label: const Text('Aprobar'),
            onPressed: () => _cambiarEstado('active'),
          ),
 
        // Activar → solo cuando está bloqueado
        if (estado == AccountStatus.blocked)
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.lock_open_outlined, size: 18),
            label: const Text('Activar'),
            onPressed: () => _cambiarEstado('active'),
          ),
 
        // Bloquear → cuando está activo o pendiente
        if (estado == AccountStatus.active ||
            estado == AccountStatus.pendingApproval)
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
            ),
            icon: const Icon(Icons.block_outlined, size: 18),
            label: const Text('Bloquear'),
            onPressed: _confirmarBloqueo,
          ),
 
        // Poner pendiente → cuando está activo o bloqueado
        if (estado == AccountStatus.active ||
            estado == AccountStatus.blocked)
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.orange,
              side: const BorderSide(color: Colors.orange),
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
      builder: (ctx) => AlertDialog(
        title: const Text('Bloquear usuario'),
        content: Text(
          '¿Seguro que quieres bloquear a "$nombre"?\n\n'
          'No podrá iniciar sesión hasta que lo actives nuevamente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Bloquear'),
          ),
        ],
      ),
    );
 
    if (confirmar == true) await _cambiarEstado('blocked');
  }
 
  Future<void> _cambiarEstado(String nuevoEstado) async {
    setState(() => _procesando = true);
 
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.docId)
          .update({'status': nuevoEstado});
 
      if (!mounted) return;
 
      final mensaje = switch (nuevoEstado) {
        'active'          => 'Usuario activado correctamente.',
        'blocked'         => 'Usuario bloqueado.',
        'pendingApproval' => 'Usuario puesto en pendiente.',
        _                 => 'Estado actualizado.',
      };
 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: nuevoEstado == 'active'
              ? Colors.green
              : nuevoEstado == 'blocked'
                  ? Colors.red
                  : Colors.orange,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _procesando = false);
    }
  }
 
  Future<void> _verActivosAsignados(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _ModalActivosAsignados(
        uid: widget.docId,
        nombreUsuario: widget.perfil.nombre.isNotEmpty
            ? widget.perfil.nombre
            : widget.perfil.correo,
      ),
    );
  }
}
 
// ─────────────────────────────────────────────────────────────────────────────
// Modal: préstamos activos del usuario
// ─────────────────────────────────────────────────────────────────────────────
class _ModalActivosAsignados extends StatelessWidget {
  final String uid;
  final String nombreUsuario;
 
  const _ModalActivosAsignados(
      {required this.uid, required this.nombreUsuario});
 
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (ctx, scrollController) {
        return Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
 
            // Título
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.inventory_2_outlined),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Activos de $nombreUsuario',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
 
            // Lista de préstamos activos
            Expanded(
              child: FutureBuilder<QuerySnapshot>(
                // Campo 'usuarioId' según servicio_prestamos.dart
                future: FirebaseFirestore.instance
                    .collection('prestamos')
                    .where('usuarioId', isEqualTo: uid)
                    .where('estado', isEqualTo: 'activo')
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
 
                  if (snapshot.hasError) {
                    return Center(
                        child: Text('Error: ${snapshot.error}'));
                  }
 
                  final prestamos = snapshot.data?.docs ?? [];
 
                  if (prestamos.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox_outlined,
                              size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text(
                            'Este usuario no tiene activos asignados.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }
 
                  return ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: prestamos.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final data = prestamos[index].data()
                          as Map<String, dynamic>;
 
                      // Enriquecer con datos del activo
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
                            final a = snapActivo.data!.data()
                                as Map<String, dynamic>;
                            nombreActivo = (a['nombre'] ?? 'Sin nombre')
                                .toString();
                            categoriaActivo =
                                (a['categoria'] ?? '').toString();
                          }
 
                          return ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                  color: Colors.grey.shade200),
                            ),
                            leading: const CircleAvatar(
                              child: Icon(Icons.devices_outlined),
                            ),
                            title: Text(nombreActivo),
                            subtitle: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                if (categoriaActivo.isNotEmpty)
                                  Text(categoriaActivo,
                                      style: const TextStyle(
                                          fontSize: 11)),
                                if (fechaSolicitud != null)
                                  Text(
                                    'Préstamo: ${_formatearFecha(fechaSolicitud)}',
                                    style:
                                        const TextStyle(fontSize: 11),
                                  ),
                                if (fechaVencimiento != null)
                                  Text(
                                    'Vence: ${_formatearFecha(fechaVencimiento)}',
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.orange),
                                  ),
                              ],
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Activo',
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600),
                              ),
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
        );
      },
    );
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
}