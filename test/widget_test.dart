import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:let_me_know/app.dart';

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
    // La app usa DateFormat('es_ES') en varias pantallas.
    // En tests no se ejecuta main.dart, así que debemos inicializarlo aquí.
    await initializeDateFormatting('es_ES', null);

    // Build our app and trigger a frame.
    await tester.pumpWidget(const LetMeKnowApp());
    await tester.pumpAndSettle();

    // Verify that the app loads
    expect(find.text('Mi Asistente'), findsOneWidget);
  });
}
