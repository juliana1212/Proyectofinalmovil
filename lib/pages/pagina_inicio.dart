import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Control de activos'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sistema de activos y préstamos institucionales',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Text('Flujo principal:'),
            SizedBox(height: 8),
            Text('1. Login'),
            Text('2. Consultar activos disponibles'),
            Text('3. Seleccionar activo'),
            Text('4. Solicitar préstamo'),
            Text('5. Validar préstamo pendiente o activo'),
          ],
        ),
      ),
    );
  }
}