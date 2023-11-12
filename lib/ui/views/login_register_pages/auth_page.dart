import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontent/ui/views/login_register_pages/home_page.dart';
import 'package:frontend/login_register_pages/login_or_register_page.dart';
import 'package:modern_login/profile_pages/profile_page.dart';

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
              return   ProfilePage();; // davor war hier HomePage()   //const ProfilePage(); FETTER BUG FIX man muss oft Sign In
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
