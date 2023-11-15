import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/views/login_register_pages/home_page.dart';

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
              return   ProfilePage();; // davor war hier HomePage()   //const ProfilePage(); FETTER BUG FIX man muss oft Sign In
            }
            else {
              return const LoginOrRegisterPage();
            }
         
            // user not logged in
          }),
    );
  }
}
