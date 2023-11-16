import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../profile_pages/profile_page.dart';
import 'login_or_register_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            // user logged in
            if (snapshot.hasData) {
              return ProfilePage();
            }
            if (snapshot.hasError){
              return const Text("here is Buggy");
            }
            else {
              return const LoginOrRegisterPage();
            }

            // user not logged in
          }),
    );
  }
}
