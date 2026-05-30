// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

import 'pages/login_page.dart';
import 'pages/registro_page.dart';
import 'pages/home_estudiante_page.dart';
import 'pages/activos_page.dart';
import 'pages/devoluciones_page.dart';
import 'pages/gestion_activos_page.dart';
import 'pages/historial_prestamos_page.dart';
import 'pages/admin_usuarios_page.dart';
import 'pages/mis_prestamos_page.dart';
import 'pages/home_encargado_page.dart';

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
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF3F5FC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF8A73),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF3F5FC),
          foregroundColor: Color(0xFF24324A),
          elevation: 0,
          centerTitle: false,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFFFFE5DE),
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(
              color: Color(0xFF24324A),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(
                color: Color(0xFFFF8A73),
              );
            }

            return const IconThemeData(
              color: Color(0xFF8C93A8),
            );
          }),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(
            color: Color(0xFF24324A),
          ),
          bodyMedium: TextStyle(
            color: Color(0xFF24324A),
          ),
          titleLarge: TextStyle(
            color: Color(0xFF24324A),
            fontWeight: FontWeight.bold,
          ),
          titleMedium: TextStyle(
            color: Color(0xFF24324A),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/registro': (context) => const RegistroPage(),

        // Pantalla principal del estudiante con diseño tipo dashboard.
        '/home': (context) => const HomeEstudiantePage(),

        // Pantallas internas.
        '/activos': (context) => const ActivosPage(),
        '/mis-prestamos': (context) => const MisPrestamosPage(),
        '/devoluciones': (context) => const DevolucionesPage(),
        '/gestion-activos': (context) => const GestionActivosPage(),
        '/historial-prestamos': (context) =>
            const HistorialPrestamosPage(),
        '/admin-usuarios': (context) => const AdminUsuariosPage(),
        '/home-encargado': (context) => const HomeEncargadoPage(),
      },
    );
  }
}