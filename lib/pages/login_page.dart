// lib/pages/login_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/servicio_auth.dart';
import '../models/enums.dart';
 
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
 
  @override
  State<LoginPage> createState() => _LoginPageState();
}
 
class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final ServicioAuth authService = ServicioAuth();
 
  bool isLoading = false;
  String? errorMessage;
 
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: isLoading ? null : _login,
                child: isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text('Iniciar sesión', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
 
  Future<void> _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
 
    if (email.isEmpty || password.isEmpty) {
      setState(() => errorMessage = 'Por favor completa todos los campos.');
      return;
    }
 
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
 
    try {
      // 1. Autenticar con Firebase Auth
      final user = await authService.login(email, password);
      if (user == null) {
        setState(() => errorMessage = 'No se pudo autenticar.');
        return;
      }
 
      // 2. Leer el documento de Firestore
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
 
      // 3. Si no existe el documento, lo creamos con valores por defecto
      if (!doc.exists) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({
          'correo': user.email ?? email,
          'nombre': email.split('@').first,
          'role': 'solicitante',
          'status': 'active',
        });
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/home');
        return;
      }
 
      // 4. Leer status (acepta "status" o "estado")
      final data = doc.data()!;
      final String statusRaw =
          (data['status'] ?? data['estado'] ?? '').toString().trim().toLowerCase();
 
      // 5. Parsear el status al enum
      AccountStatus estado;
      if (statusRaw == 'active' || statusRaw == 'activo') {
        estado = AccountStatus.active;
      } else if (statusRaw == 'blocked' || statusRaw == 'bloqueado') {
        estado = AccountStatus.blocked;
      } else {
        // pendingApproval u otro valor desconocido
        estado = AccountStatus.pendingApproval;
      }
 
      // 6. Verificar estado de la cuenta
      if (estado == AccountStatus.blocked) {
        setState(() => errorMessage = 'Tu cuenta está bloqueada. Contacta al administrador.');
        return;
      }
      if (estado == AccountStatus.pendingApproval) {
        setState(() => errorMessage = 'Tu cuenta está pendiente de aprobación.');
        return;
      }
 
      // 7. Estado activo → navegar
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
 
    } catch (e) {
      final msg = e.toString();
      String friendly;
      if (msg.contains('wrong-password') || msg.contains('invalid-credential')) {
        friendly = 'Contraseña incorrecta.';
      } else if (msg.contains('user-not-found') || msg.contains('invalid-email')) {
        friendly = 'Correo electrónico no registrado.';
      } else if (msg.contains('too-many-requests')) {
        friendly = 'Demasiados intentos fallidos. Espera un momento.';
      } else if (msg.contains('network-request-failed')) {
        friendly = 'Sin conexión a internet.';
      } else {
        friendly = 'Error: $msg';
      }
      setState(() => errorMessage = friendly);
    } finally {
      // Solo apagar el loading si todavía estamos montados
      if (mounted) setState(() => isLoading = false);
    }
  }
}