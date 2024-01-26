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

  if (FirebaseAuth.instance.currentUser != null) {
    await PushNotificationService().checkInitialized();
  }
  
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
