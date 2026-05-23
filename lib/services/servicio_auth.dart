// lib/services/servicio_auth.dart
import 'package:firebase_auth/firebase_auth.dart';
import '../models/enums.dart';

class ServicioAuth {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Iniciar sesión con email y contraseña
  Future<User?> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      // Manejo de errores comunes
      if (e.code == 'user-not-found') {
        throw Exception('Usuario no encontrado.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Contraseña incorrecta.');
      } else {
        throw Exception('Error al iniciar sesión: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  // Cerrar sesión
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Obtener usuario actual
  User? get usuarioActual => _auth.currentUser;

  // Revisar si el usuario tiene acceso según estado y rol
  bool puedeAcceder(User? user, {AccountStatus estado = AccountStatus.active, UserRole rol = UserRole.solicitante}) {
    if (user == null) return false;
    // Aquí puedes implementar lógicas adicionales según rol y estado
    return true;
  }
}