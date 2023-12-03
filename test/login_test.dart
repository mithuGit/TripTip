import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:internet_praktikum/ui/views/login_register_pages/login_or_register_page.dart';
import 'package:internet_praktikum/ui/widgets/my_button.dart';

void main() {
  testWidgets('Anmeldetest', (WidgetTester tester) async {
    // Pump the widget under test
    await tester.pumpWidget(const MaterialApp(home: LoginOrRegisterPage()));

    // Verify that the widgets are present
    //expect(find.byKey(const Key('Email')), findsOneWidget);
    //expect(find.byKey(const Key('Password')), findsOneWidget);
    expect(find.widgetWithText(MyButton,"Sign In"), findsOneWidget);

    // Simulate user input
    //await tester.enterText(find.byKey(const Key('Email')), 'thaibinhnguyen7@outlook.de');
    //await tester.enterText(find.byKey(const Key('Password')), 'test123');

    // Tap the login button
    await tester.tap(find.widgetWithText(MyButton,"Sign In"));

    // Wait for changes to be processed
    await tester.pump();

    // Verify the appearance of the dialog
    //expect(find.byType(Dialog), findsOneWidget);
    
    // Assuming that the dialog contains the specified text
    expect(find.text('Something went wrong. Try again later.'), findsOneWidget);
  });
}
