import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'activos_page.dart';
import 'devoluciones_page.dart';
import 'gestion_activos_page.dart';

class EncargadoColors {
  static const Color fondoGeneral = Color(0xFFF3F5FC);
  static const Color fondoTarjeta = Color(0xFFFFFFFF);
  static const Color acentoPrincipal = Color(0xFFFF8A73);
  static const Color acentoSuave = Color(0xFFFFE5DE);
  static const Color textoPrincipal = Color(0xFF24324A);
  static const Color textoSecundario = Color(0xFF8C93A8);
}

class HomeEncargadoPage extends StatefulWidget {
  const HomeEncargadoPage({super.key});

  @override
  State<HomeEncargadoPage> createState() => _HomeEncargadoPageState();
}

class _HomeEncargadoPageState extends State<HomeEncargadoPage> {
  int paginaSeleccionada = 0;

  final List<Widget> paginas = const [
    ActivosPage(),
    DevolucionesPage(),
    GestionActivosPage(),
  ];

  Future<void> _cerrarSesion() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushReplacementNamed(context, '/login');
  }

  String _tituloPagina() {
    switch (paginaSeleccionada) {
      case 0:
        return 'Activos';
      case 1:
        return 'Devoluciones';
      case 2:
        return 'Inventario';
      default:
        return 'Encargado';
    }
  }

  String _subtituloPagina() {
    switch (paginaSeleccionada) {
      case 0:
        return 'Consulta el estado general de los activos.';
      case 1:
        return 'Confirma devoluciones y registra novedades.';
      case 2:
        return 'Gestiona unidades, mantenimiento y bajas.';
      default:
        return 'Panel del encargado de inventario.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EncargadoColors.fondoGeneral,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _tituloPagina(),
                          style: const TextStyle(
                            color: EncargadoColors.textoPrincipal,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _subtituloPagina(),
                          style: const TextStyle(
                            color: EncargadoColors.textoSecundario,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Cerrar sesión',
                    style: IconButton.styleFrom(
                      backgroundColor: EncargadoColors.acentoSuave,
                      foregroundColor: EncargadoColors.acentoPrincipal,
                      fixedSize: const Size(52, 52),
                    ),
                    onPressed: _cerrarSesion,
                    icon: const Icon(Icons.logout),
                  ),
                ],
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: paginaSeleccionada,
                children: paginas,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: paginaSeleccionada,
        backgroundColor: EncargadoColors.fondoTarjeta,
        indicatorColor: EncargadoColors.acentoSuave,
        onDestinationSelected: (index) {
          setState(() {
            paginaSeleccionada = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(
              Icons.inventory_2,
              color: EncargadoColors.acentoPrincipal,
            ),
            label: 'Activos',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_return_outlined),
            selectedIcon: Icon(
              Icons.assignment_return,
              color: EncargadoColors.acentoPrincipal,
            ),
            label: 'Devoluciones',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(
              Icons.settings,
              color: EncargadoColors.acentoPrincipal,
            ),
            label: 'Gestión',
          ),
        ],
      ),
    );
  }
}