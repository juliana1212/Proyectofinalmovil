// lib/pages/login_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/servicio_auth.dart';
import '../models/enums.dart';
 
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
 
  @override
  State<LoginPage> createState() => _LoginPageState();
}
 
class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ServicioAuth _authService = ServicioAuth();
 
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;
 
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              const Icon(Icons.inventory_2_outlined, size: 72, color: Colors.blue),
              const SizedBox(height: 16),
              const Text(
                'Control de activos',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Text(
                'Inicia sesión para continuar',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 40),
 
              // Correo
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 16),
 
              // Contraseña
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _login(),
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              const SizedBox(height: 24),
 
              // Mensaje de error
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      border: Border.all(color: Colors.red.shade200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
 
              // Botón iniciar sesión
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text('Iniciar sesión',
                          style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),
 
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('o',
                        style: TextStyle(color: Colors.grey.shade500)),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                ],
              ),
              const SizedBox(height: 16),
 
              // Crear cuenta
              OutlinedButton.icon(
                icon: const Icon(Icons.person_add_outlined),
                label: const Text('Crear cuenta de estudiante'),
                onPressed: _isLoading
                    ? null
                    : () => Navigator.pushReplacementNamed(
                        context, '/registro'),
              ),
            ],
          ),
        ),
      ),
    );
  }
 
  Future<void> _login() async {
    FocusScope.of(context).unfocus();
 
    final email = _emailController.text.trim();
    final password = _passwordController.text;
 
    if (email.isEmpty || password.isEmpty) {
      setState(() =>
          _errorMessage = 'Por favor completa el correo y la contraseña.');
      return;
    }
 
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
 
    try {
      // ── 1. Autenticar con Firebase Auth ──────────────────────────────────
      final user = await _authService.login(email, password);
      if (user == null) {
        setState(() => _errorMessage = 'No se pudo autenticar.');
        return;
      }
 
      // ── 2. Leer documento de usuario en Firestore ─────────────────────────
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
 
      // ── 3. Si no existe el doc → solicitante activo por defecto ───────────
      if (!doc.exists || doc.data() == null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({
          'uid': user.uid,
          'correo': user.email ?? email,
          'nombre': email.split('@').first,
          'role': 'solicitante',
          'status': 'active',
          'creadoEn': FieldValue.serverTimestamp(),
        });
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/home');
        return;
      }
 
      final data = doc.data()!;
 
      // ── 4. Verificar estado de la cuenta ──────────────────────────────────
      final String statusRaw =
          (data['status'] ?? data['estado'] ?? '')
              .toString()
              .trim()
              .toLowerCase();
 
      AccountStatus estado;
      if (statusRaw == 'active' || statusRaw == 'activo') {
        estado = AccountStatus.active;
      } else if (statusRaw == 'blocked' || statusRaw == 'bloqueado') {
        estado = AccountStatus.blocked;
      } else {
        estado = AccountStatus.pendingApproval;
      }
 
      if (estado == AccountStatus.blocked) {
        await FirebaseAuth.instance.signOut();
        setState(() => _errorMessage =
            'Tu cuenta ha sido bloqueada. Contacta al administrador.');
        return;
      }
 
      if (estado == AccountStatus.pendingApproval) {
        await FirebaseAuth.instance.signOut();
        setState(() => _errorMessage =
            'Tu cuenta está pendiente de aprobación. Un administrador la revisará pronto.');
        return;
      }
 
      // ── 5. Leer rol y redirigir ───────────────────────────────────────────
      // Se normaliza a minúsculas para evitar problemas con mayúsculas en Firestore
      final String roleRaw =
          (data['role'] ?? data['rol'] ?? 'solicitante')
              .toString()
              .trim()
              .toLowerCase();
 
      if (!mounted) return;
 
      if (roleRaw == 'administrador') {
        Navigator.pushReplacementNamed(context, '/admin-usuarios');
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      final msg = e.toString();
      String friendly;
      if (msg.contains('wrong-password') ||
          msg.contains('invalid-credential')) {
        friendly = 'Contraseña incorrecta. Verifica e intenta de nuevo.';
      } else if (msg.contains('user-not-found')) {
        friendly =
            'No existe ninguna cuenta con ese correo. ¿Quieres crear una?';
      } else if (msg.contains('invalid-email')) {
        friendly = 'El formato del correo no es válido.';
      } else if (msg.contains('too-many-requests')) {
        friendly =
            'Demasiados intentos fallidos. Espera unos minutos e intenta de nuevo.';
      } else if (msg.contains('network-request-failed')) {
        friendly = 'Sin conexión a internet. Verifica tu red.';
      } else if (msg.contains('user-disabled')) {
        friendly = 'Esta cuenta ha sido deshabilitada.';
      } else {
        friendly = 'Error al iniciar sesión. Intenta de nuevo.';
      }
      setState(() => _errorMessage = friendly);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}