import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_praktikum/ui/views/finanzen/finazen.dart';
import 'package:internet_praktikum/ui/views/verification/OTP_Form.dart';
import 'package:internet_praktikum/ui/views/login_register_pages/home_page.dart';
import 'package:internet_praktikum/ui/views/login_register_pages/login_or_register_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: Main()));
}

class Main extends StatelessWidget {
  const Main({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      title: 'Let\'s Travel Together. ',
      home: AuthWrapper(),
    );
  }
}

// Mit dieser Klasse wird überprüft, ob der User eingeloggt ist oder nicht
// Wenn er eingeloggt ist, wird er auf die HomePage weitergeleitet
// Wenn er nicht eingeloggt ist, wird er auf die LoginOrRegisterPage weitergeleitet
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});
  @override
  Widget build(BuildContext context) {
    return Finanzen(); /*StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            return HomePage();
          } else {
            return const LoginOrRegisterPage();
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            // Wenn die Authentifizierung noch lädt, zeige einen Ladebildschirm oder Spinner
            return const CircularProgressIndicator();
          }

          if (snapshot.hasError) {
            // Wenn ein Fehler auftritt, zeige eine Fehlermeldung
            return const Text("Fehler bei der Authentifizierung");
          }

          // user logged in
          User? user = snapshot.data;

          if (user != null && !user.emailVerified) {
            print(user.emailVerified);
            return const OTPForm();
          } else if (user != null && user.emailVerified) {
            return HomePage();
          } else if (user == null) {
            return const LoginOrRegisterPage();
          }
          return const CircularProgressIndicator();
        }
        );*/
  }
}
