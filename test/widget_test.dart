import 'package:flutter_test/flutter_test.dart';
import 'package:let_me_know/app.dart';

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const LetMeKnowApp());

    // Verify that the app loads
    expect(find.text('Mi Asistente de Recordatorios'), findsOneWidget);
  });
}
