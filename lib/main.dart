import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:internet_praktikum/core/services/init_pushnotifications.dart';
import 'package:internet_praktikum/ui/router.dart';
import 'firebase_options.dart';
import '.env';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //Stripe pub-key
  Stripe.publishableKey = stripePublishableKey;
  await Stripe.instance.applySettings();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // when ever the app is started, the user is reloaded
  // if the user is not logged in, the user is null
  if (FirebaseAuth.instance.currentUser != null) {
    try {
      await FirebaseAuth.instance.currentUser!.reload();
    } catch (e) {
      await FirebaseAuth.instance.signOut();
      //await PushNotificationService().disable();
    }
  }

// ignore: missing_provider_scope
  runApp(const Main());
}

class Main extends StatefulWidget {
  const Main({super.key});

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await PushNotificationService().initalize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: MyRouter.router,
      title: 'Let\'s Travel Together. ',
    );
  }
}
