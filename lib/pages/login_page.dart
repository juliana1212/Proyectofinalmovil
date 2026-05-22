import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/servicio_auth.dart';
import '../models/perfil_usuario.dart';
import '../models/enums.dart';
import '../services/servicio_permisos.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final ServicioAuth authService = ServicioAuth();
  final ServicioPermisos permisosService = ServicioPermisos();

  bool isLoading = false;
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Correo electrónico'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Contraseña'),
            ),
            const SizedBox(height: 20),
            if (errorMessage != null)
              Text(errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: isLoading ? null : login,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Iniciar sesión'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> login() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final user = await authService.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (user != null) {
        // Leer el documento del usuario en Firestore usando UID exacto
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (!doc.exists) {
          setState(() {
            errorMessage = 'Usuario no encontrado en Firestore';
            isLoading = false;
          });
          return;
        }

        // Depuración: imprimir valores
        print('Firestore doc ID: ${doc.id}');
        print('role: ${doc.get('role')}');
        print('status: ${doc.get('status')}');

        final roleString = doc.get('role') as String;
        final statusString = doc.get('status') as String;

        final perfil = PerfilUsuario(
          uid: user.uid,
          nombre: doc.get('nombre') ?? '',
          correo: doc.get('correo') ?? '',
          role: UserRole.values.firstWhere(
            (e) => e.toString().split('.').last == roleString.trim(),
            orElse: () => UserRole.solicitante,
          ),
          estado: AccountStatus.values.firstWhere(
            (e) => e.toString().split('.').last == statusString.trim(),
            orElse: () => AccountStatus.pendingApproval,
          ),
        );

        print('perfil.role: ${perfil.role}');
        print('perfil.estado: ${perfil.estado}');

        // Verificar permisos y estado
        if (!permisosService.puedeAccederModuloPrincipal(perfil)) {
          String msg = 'Acceso denegado';
          if (perfil.estado == AccountStatus.blocked) {
            msg = 'Acceso bloqueado.';
          } else if (perfil.estado == AccountStatus.pendingApproval) {
            msg = 'Cuenta pendiente de aprobación.';
          }
          setState(() {
            errorMessage = msg;
            isLoading = false;
          });
          return;
        }

        // Usuario activo: navegar al home
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error al iniciar sesión: ${e.toString()}';
        isLoading = false;
      });
      print('Error login: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}