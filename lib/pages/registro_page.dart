// lib/pages/registro_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
 
class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key});
 
  @override
  State<RegistroPage> createState() => _RegistroPageState();
}
 
class _RegistroPageState extends State<RegistroPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
 
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
 
  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear cuenta'),
        leading: BackButton(
          onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
 
                // Ícono / encabezado
                const Icon(Icons.person_add_outlined,
                    size: 64, color: Colors.blue),
                const SizedBox(height: 16),
                const Text(
                  'Nueva cuenta de estudiante',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tu cuenta quedará pendiente de aprobación por un administrador.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 32),
 
                // Nombre completo
                TextFormField(
                  controller: _nombreController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Nombre completo',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'El nombre es obligatorio.';
                    }
                    if (v.trim().length < 3) {
                      return 'El nombre debe tener al menos 3 caracteres.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
 
                // Correo electrónico
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'El correo es obligatorio.';
                    }
                    final emailRegex =
                        RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
                    if (!emailRegex.hasMatch(v.trim())) {
                      return 'Ingresa un correo válido.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
 
                // Contraseña
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
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
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'La contraseña es obligatoria.';
                    }
                    if (v.length < 6) {
                      return 'La contraseña debe tener al menos 6 caracteres.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
 
                // Confirmar contraseña
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirm,
                  decoration: InputDecoration(
                    labelText: 'Confirmar contraseña',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirm
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined),
                      onPressed: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Confirma tu contraseña.';
                    }
                    if (v != _passwordController.text) {
                      return 'Las contraseñas no coinciden.';
                    }
                    return null;
                  },
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
 
                // Botón registrar
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _registrar,
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5),
                          )
                        : const Text('Crear cuenta',
                            style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 16),
 
                // Ir al login
                TextButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/login'),
                  child: const Text('¿Ya tienes cuenta? Inicia sesión'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
 
  Future<void> _registrar() async {
    // Ocultar teclado y limpiar error previo
    FocusScope.of(context).unfocus();
    setState(() => _errorMessage = null);
 
    if (!_formKey.currentState!.validate()) return;
 
    setState(() => _isLoading = true);
 
    try {
      // 1. Crear usuario en Firebase Auth
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
 
      final user = credential.user;
      if (user == null) throw Exception('No se pudo crear el usuario.');
 
      // 2. Actualizar displayName en FirebaseAuth
      await user.updateDisplayName(_nombreController.text.trim());
 
      // 3. Guardar perfil en Firestore
      //    - role: 'solicitante'  → siempre estudiante al registrarse
      //    - status: 'pendingApproval' → requiere aprobación de admin
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'correo': user.email ?? _emailController.text.trim(),
        'nombre': _nombreController.text.trim(),
        'role': 'solicitante',
        'status': 'pendingApproval',
        'creadoEn': FieldValue.serverTimestamp(),
      });
 
      // 4. Cerrar sesión inmediatamente (no puede entrar hasta ser aprobado)
      await FirebaseAuth.instance.signOut();
 
      if (!mounted) return;
 
      // 5. Mostrar diálogo de éxito y regresar al login
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          icon: const Icon(Icons.check_circle_outline,
              color: Colors.green, size: 48),
          title: const Text('¡Cuenta creada!'),
          content: const Text(
            'Tu cuenta fue creada exitosamente como estudiante.\n\n'
            'Un administrador debe aprobarla antes de que puedas ingresar. '
            'Te avisarán cuando esté lista.',
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text('Entendido'),
            ),
          ],
        ),
      );
    } on FirebaseAuthException catch (e) {
      String mensaje;
      switch (e.code) {
        case 'email-already-in-use':
          mensaje = 'Este correo ya está registrado. Intenta iniciar sesión.';
          break;
        case 'invalid-email':
          mensaje = 'El formato del correo no es válido.';
          break;
        case 'weak-password':
          mensaje =
              'La contraseña es muy débil. Usa al menos 6 caracteres con letras y números.';
          break;
        case 'operation-not-allowed':
          mensaje =
              'El registro con correo y contraseña no está habilitado. Contacta al administrador.';
          break;
        case 'network-request-failed':
          mensaje = 'Sin conexión a internet. Verifica tu red e intenta de nuevo.';
          break;
        default:
          mensaje = 'Error al registrar: ${e.message ?? e.code}';
      }
      setState(() => _errorMessage = mensaje);
    } catch (e) {
      setState(() => _errorMessage = 'Error inesperado: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}