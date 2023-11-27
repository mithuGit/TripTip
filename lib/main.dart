import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:internet_praktikum/ui/views/login_register_pages/home_page.dart';
import 'package:internet_praktikum/ui/views/login_register_pages/login_or_register_page.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const Main());
}

class Main extends StatelessWidget {
  const Main({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      title: 'Product App. ',
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
    return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // user logged in
          if (snapshot.hasData) {
            return HomePage(); // hier kann man zum testen auch ProfilePage() einfügen
          }
          if (snapshot.hasError) {
            return const Text("here is Buggy");
          } else {
            return const LoginOrRegisterPage();
          }

          // user not logged in
        });
  }
}
