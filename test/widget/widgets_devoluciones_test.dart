import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proyectofinalmovil/widgets/widgets_devoluciones.dart';

void main() {
  testWidgets(
    'muestra una devolución pendiente de sincronización',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TarjetaDevolucionPendiente(
              nombreActivo: 'Tablet Samsung',
            ),
          ),
        ),
      );

      expect(find.text('Tablet Samsung'), findsOneWidget);
      expect(find.text('Pendiente de sincronización'), findsOneWidget);
      expect(find.text('Pendiente'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_off_outlined), findsOneWidget);
    },
  );

  testWidgets(
    'muestra botón sincronizar cuando existen devoluciones pendientes',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BannerPendientesSincronizacion(
              cantidadPendientes: 1,
              sincronizando: false,
              onSincronizar: () {},
            ),
          ),
        ),
      );

      expect(
        find.text('1 devolución(es) pendiente(s) de sincronización.'),
        findsOneWidget,
      );

      expect(find.text('Sincronizar'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_upload_outlined), findsOneWidget);
    },
  );

  testWidgets(
    'muestra indicador de carga mientras sincroniza pendientes',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BannerPendientesSincronizacion(
              cantidadPendientes: 1,
              sincronizando: true,
              onSincronizar: null,
            ),
          ),
        ),
      );

      expect(
        find.text('1 devolución(es) pendiente(s) de sincronización.'),
        findsOneWidget,
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Sincronizar'), findsNothing);
    },
  );
}