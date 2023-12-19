import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:internet_praktikum/ui/views/trip_setup_pages/create_trip.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:google_sign_in_mocks/google_sign_in_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void main() async {
  // Define a test. The TestWidgets function also provides a WidgetTester
  // to work with. The WidgetTester allows building and interacting
  // Sign in.
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Initialize mock Firebase app
    await Firebase.initializeApp();
  });
  final googleSignIn = MockGoogleSignIn();
  final signinAccount = await googleSignIn.signIn();
  final googleAuth = await signinAccount?.authentication;
  final AuthCredential credential = GoogleAuthProvider.credential(
    accessToken: googleAuth?.accessToken,
    idToken: googleAuth?.idToken,
  );
  final user = MockUser(
    isAnonymous: false,
    uid: 'uid',
    email: 'bob@somedomain.com',
    displayName: 'Bob',
  );
  final auth = MockFirebaseAuth(mockUser: user);
  final result = await auth.signInWithCredential(credential);
  final res = result.user;
  print(res?.displayName);

  testWidgets('shows messages', (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    await firestore.collection('users').add({
      'uid': 'uid',
      'prename': 'Prename',
      'lastname': 'Lastname',
    });
    
    // Create the widget by telling the tester to build it.
    await tester.pumpWidget(MaterialApp(
        title: 'Firestore Example',
        home: CreateTrip(firestore: firestore, auth: auth)));
    await tester.idle();
    await tester.pump(); 
  });
}
