import 'package:firebase_auth/firebase_auth.dart';
import '../models/perfil_usuario.dart';

class ServicioAuth {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Método para iniciar sesión con email y contraseña
  Future<User?> login(String email, String password) async {
    try {
      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return cred.user;
    } catch (e) {
      rethrow;
    }
  }

  // Método para cerrar sesión
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Método para obtener usuario actual
  User? get usuarioActual => _auth.currentUser;
}