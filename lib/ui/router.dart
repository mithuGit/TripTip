import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internet_praktikum/ui/views/account/account_details.dart';
import 'package:internet_praktikum/ui/views/login_register_pages/home_page.dart';
import 'package:internet_praktikum/ui/views/login_register_pages/login_or_register_page.dart';
import 'package:internet_praktikum/ui/views/trip_setup_pages/create_trip.dart';
import 'package:internet_praktikum/ui/views/trip_setup_pages/join_trip.dart';
import 'package:internet_praktikum/ui/views/trip_setup_pages/select_trip.dart';
import 'package:internet_praktikum/ui/views/verification/OTP_form.dart';

class MyRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        name: 'home',
        path: '/',
        builder: (context, state) => HomePage(),
        redirect: (BuildContext context, GoRouterState state) {
          FirebaseAuth auth = FirebaseAuth.instance;
          if (auth.currentUser == null) {
            return '/loginorregister';
          }  else if(auth.currentUser != null && !auth.currentUser!.emailVerified) {
            return '/otp';
          } else {
            return null; // return "null" to display the intended route without redirecting
          }
        },
      ),
      GoRoute(
        name: 'loginOrRegister',
        path: '/loginorregister',
        builder: (context, state) => const LoginOrRegisterPage(),
      ),
      GoRoute(
          name: 'otp',
          path: '/otp',
          builder: (context, state) => const OTPForm()),
      GoRoute(
        name: 'accountdetails',
        path: '/accountdetails',
        builder: (context, state) => const Account(),
      ),
      GoRoute(
        name: 'createtrip',
        path: '/createtrip',
        builder: (context, state) => CreateTrip(),
      ),
      GoRoute(
        name: 'selecttrip',
        path: '/selecttrip',
        builder: (context, state) => const SelectTrip(),
      ),
      GoRoute(
        name: 'jointrip',
        path: '/jointrip',
        builder: (context, state) => JoinTrip(),
      ),
    ],
  );
}
