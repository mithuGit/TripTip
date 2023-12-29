import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:internet_praktikum/core/services/placeApiProvider.dart';
import 'package:internet_praktikum/main.dart' as app;
import 'package:uuid/uuid.dart';


void main() {
  group('Test Create Trip', () { 
    test('Test Places Api', () async {
      // Build our app and trigger a frame.
      final String uuid = Uuid().v4();
      final placeApiProvider = PlaceApiProvider(uuid);
      final suggestions = await placeApiProvider.fetchSuggestions('Berlin');
      expect(suggestions.first.description, 'Berlin, Germany');
    });
    testWidgets('Create Trip', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      
    });
  });
}