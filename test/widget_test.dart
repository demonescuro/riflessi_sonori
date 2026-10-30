import 'package:flutter_test/flutter_test.dart';
import 'package:riflessi_sonori/app.dart';

void main() {
  testWidgets(
    'La schermata iniziale si avvia senza errori',
    (WidgetTester tester) async {
      await tester.pumpWidget(const RiflessiSonoriApp());
      await tester.pump();

      expect(find.byType(RiflessiSonoriApp), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}