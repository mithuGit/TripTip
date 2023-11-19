import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:internet_praktikum/ui/widgets/usernamebagageCreateTrip.dart';
void main() {
  // Define a test. The TestWidgets function also provides a WidgetTester
  // to work with. The WidgetTester allows building and interacting
  // with widgets in the test environment.
  testWidgets('UsernameBagageCreateTrip has the correct title', (tester) async {
    // Create the widget by telling the tester to build it.
    await tester.pumpWidget(const UsernameBagageCreateTrip());

    // Create the Finders.
    final titleFinder = find.text('T');
    final messageFinder = find.text('M');

    // Use the `findsOneWidget` matcher provided by flutter_test to
    // verify that the Text widgets appear exactly once in the widget tree.
    expect(titleFinder, findsOneWidget);
    expect(messageFinder, findsOneWidget);
  });
}