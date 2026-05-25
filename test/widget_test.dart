import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proyectofinalmovil/widgets/widgets_devoluciones.dart';

void main() {
  testWidgets(
    'muestra acceso restringido para usuario sin permiso de devolución',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AccesoRestringidoDevoluciones(),
          ),
        ),
      );

      expect(find.text('Acceso restringido'), findsOneWidget);

      expect(
        find.text(
          'Solo el encargado de inventario puede confirmar devoluciones.',
        ),
        findsOneWidget,
      );

      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    },
  );
}