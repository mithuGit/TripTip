import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/views/account/account_details.dart';
import 'package:internet_praktikum/ui/widgets/container.dart';
import '../../widgets/my_button.dart';

class OTPForm extends StatefulWidget {
  const OTPForm({
    Key? key,
  }) : super(key: key);

  @override
  State<OTPForm> createState() => _OTPFormState();
}

class _OTPFormState extends State<OTPForm> {
  bool isEmailVerified = false;
  bool canResendEmail = true;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    if (!isEmailVerified) {
      Timer.periodic(const Duration(seconds: 3), (_) => checkEmailVerified());
    }
  }

  Future checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser!.reload();

    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if (isEmailVerified) {
      canResendEmail = false;
      timer?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    const String message = "We have sent a verification link to your email. \n";

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/BackgroundCity.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 158, left: 14, right: 14, bottom: 45),
                  child: CustomContainer(
                    title: "Verify your Email",
                    smallSize: true,
                    children: [
                      const SizedBox(height: 25),
                      const Text(
                        "$message Please check your inbox.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          //TODO: style in styles.dart Ubuntu verwenden
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),

                      const SizedBox(height: 60),
                      if (canResendEmail)
                        const Icon(
                          Icons.verified,
                          color: Colors.white,
                          size: 100,
                        )
                      else
                        const Icon(
                          Icons.verified,
                          color: Colors.green,
                          size: 100,
                        ),
                      const SizedBox(
                        height: 55,
                      ),

                      if (canResendEmail)
                        MyButton(
                          onTap:
                              resendVerificationEmail, // TODO: => sendVerificationEmail(),
                          text: "Resend Link",
                        )
                      else
                        MyButton(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Account(),
                              ),
                            );
                          },
                          text: 'Next',
                        ),

                      // Würde hier ein Back-Button Sinn machen? Mithu-Thai: JA
                      /* MyButton(
                          onTap: () => {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const PasswordChange()))
                          },
                          text: 'Back',
                        ),
                        */
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Future<void> resendVerificationEmail() async {
    try {
      if (FirebaseAuth.instance.currentUser!.emailVerified) {
        setState(() {
          canResendEmail = false;
        });
      } else {
        await FirebaseAuth.instance.currentUser!.sendEmailVerification();
        canResendEmail = true;
      }
    } on FirebaseAuthException catch (e) {
      print(e.code);
    }
  }
}
