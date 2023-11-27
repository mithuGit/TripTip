import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:internet_praktikum/ui/views/account/account_details.dart';
import 'package:internet_praktikum/ui/views/login_register_pages/login_or_register_page.dart';
import 'package:internet_praktikum/ui/views/trip_setup_pages/select_trip.dart';
import 'package:internet_praktikum/ui/views/verification/OTP_Form.dart';
import 'package:internet_praktikum/ui/views/trip_setup_pages/create_trip.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(ProviderScope(
    child: const Main())
  );
}

class Main extends StatelessWidget {
  const Main({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      title: 'Product App. ',
      home: SelectTrip(),
    );
  }
}
