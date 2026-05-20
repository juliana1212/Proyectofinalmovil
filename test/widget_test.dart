import 'package:flutter_test/flutter_test.dart';
import 'package:proyectofinalmovil/main.dart';

void main() {
  testWidgets('La app inicia correctamente', (WidgetTester tester) async {
    await tester.pumpWidget(const AssetLoanApp());

    expect(find.text('Control de activos'), findsOneWidget);
  });
}