import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_praktikum/ui/router.dart';
import 'package:internet_praktikum/ui/views/main_pages/dashboard.dart';
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
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: MyRouter.router,
      title: 'Let\'s Travel Together. ',
    );
  }
}

/*class Main extends StatelessWidget {
  const Main({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //.router(
      debugShowCheckedModeBanner: false,
      home: const DashBoard(),
      theme: ThemeData(
          brightness: Brightness.dark, primarySwatch: Colors.deepPurple),
      //routerConfig: MyRouter.router,
      //title: 'Let's Travel Together. ',
    );
  }
}*/
