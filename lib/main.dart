import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:internet_praktikum/ui/views/account/account_details.dart';
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
      home: Account(),
    );
  }
}
