// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
 
import 'pages/login_page.dart';
import 'pages/registro_page.dart';
import 'pages/activos_page.dart';
import 'pages/devoluciones_page.dart';
import 'pages/gestion_activos_page.dart';
import 'pages/historial_prestamos_page.dart';
import 'pages/admin_usuarios_page.dart';
 
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const AssetLoanApp());
}
 
class AssetLoanApp extends StatelessWidget {
  const AssetLoanApp({super.key});
 
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Control de activos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login':           (context) => const LoginPage(),
        '/registro':        (context) => const RegistroPage(),
        '/home':            (context) => const ActivosPage(),
        '/devoluciones':    (context) => const DevolucionesPage(),
        '/gestion-activos': (context) => const GestionActivosPage(),
        '/historial-prestamos': (context) => const HistorialPrestamosPage(),
        '/admin-usuarios':  (context) => const AdminUsuariosPage(),
      },
    );
  }
}