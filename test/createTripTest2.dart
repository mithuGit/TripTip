import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/views/trip_setup_pages/create_trip.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

bool USE_FIRESTORE_EMULATOR = false;

Future<void> main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('create trip', (WidgetTester tester) async {
      await Firebase.initializeApp();
      if (USE_FIRESTORE_EMULATOR) {
        FirebaseFirestore.instance.settings = const Settings(
            host: 'localhost:8080',
            sslEnabled: false,
            persistenceEnabled: false);
      }
      FirebaseAuth auth = FirebaseAuth.instance;
      auth.setSettings()
      await auth.signInWithEmailAndPassword(
        email: 'fake@example.com',
        password: 'fakepassword',
      );

      await tester.pumpWidget(MaterialApp(
          title: 'Firestore Example',
          home: CreateTrip(
              firestore: FirebaseFirestore.instance,
              auth:auth)));

      // Create the Finders.
      final titleFinder = find.text('Maximilian');
      final messageFinder = find.text('Laue');

      // Use the `findsOneWidget` matcher provided by flutter_test to
      // verify that the Text widgets appear exactly once in the widget tree.
      expect(titleFinder, findsOneWidget);
      expect(messageFinder, findsOneWidget);
    });
  });
}
