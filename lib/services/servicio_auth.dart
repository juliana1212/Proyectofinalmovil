// lib/services/servicio_auth.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/enums.dart';
 
class ServicioAuth {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
 
  // ── Iniciar sesión ────────────────────────────────────────────────────────
  Future<User?> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw Exception('user-not-found');
        case 'wrong-password':
        case 'invalid-credential':
          throw Exception('wrong-password');
        case 'invalid-email':
          throw Exception('invalid-email');
        case 'user-disabled':
          throw Exception('user-disabled');
        case 'too-many-requests':
          throw Exception('too-many-requests');
        case 'network-request-failed':
          throw Exception('network-request-failed');
        default:
          throw Exception(e.code);
      }
    } catch (e) {
      rethrow;
    }
  }
 
  // ── Registrar nuevo usuario (siempre como solicitante/pendiente) ──────────
  Future<User?> registrar({
    required String email,
    required String password,
    required String nombre,
  }) async {
    try {
      // 1. Crear cuenta en Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) throw Exception('No se pudo crear la cuenta.');
 
      // 2. Actualizar display name
      await user.updateDisplayName(nombre);
 
      // 3. Crear documento en Firestore con rol fijo = solicitante y estado = pendingApproval
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'correo': email,
        'nombre': nombre,
        'role': 'solicitante',          // Siempre estudiante al registrarse
        'status': 'pendingApproval',    // Requiere aprobación de admin
        'creadoEn': FieldValue.serverTimestamp(),
      });
 
      // 4. Cerrar sesión inmediatamente (no puede entrar sin aprobación)
      await _auth.signOut();
 
      return user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw Exception('email-already-in-use');
        case 'invalid-email':
          throw Exception('invalid-email');
        case 'weak-password':
          throw Exception('weak-password');
        case 'operation-not-allowed':
          throw Exception('operation-not-allowed');
        case 'network-request-failed':
          throw Exception('network-request-failed');
        default:
          throw Exception(e.code);
      }
    } catch (e) {
      rethrow;
    }
  }
 
  // ── Cerrar sesión ─────────────────────────────────────────────────────────
  Future<void> logout() async {
    await _auth.signOut();
  }
 
  // ── Usuario actualmente autenticado ───────────────────────────────────────
  User? get usuarioActual => _auth.currentUser;
 
  // ── Verificar si el usuario puede acceder (activo) ────────────────────────
  bool puedeAcceder(
    User? user, {
    AccountStatus estado = AccountStatus.active,
    UserRole rol = UserRole.solicitante,
  }) {
    if (user == null) return false;
    return estado == AccountStatus.active;
  }
}