import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:internet_praktikum/ui/widgets/container.dart';

import '../../widgets/my_button.dart';

class OTPFormTest extends StatefulWidget {
  const OTPFormTest({Key? key}) : super(key: key);

  @override
  State<OTPFormTest> createState() => _OTPFormTestState();
}

class _OTPFormTestState extends State<OTPFormTest> {
  bool isEmailVerified = false;
  bool canResendEmail = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    if (!isEmailVerified) {
      sendVerificationEmail();

      Timer.periodic(const Duration(seconds: 3), (_) => checkEmailVerified());
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser!.reload();

    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if (isEmailVerified) timer?.cancel();
  }

  Future sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();

      setState(() => canResendEmail = false);
      await Future.delayed(const Duration(seconds: 5));
      setState(() => canResendEmail = true);
    } catch (e) {
      //Utils.showSnackBar(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    const String message = "Enter the Verification code sent at ";

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/BackgroundCity.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Positioned(
                top: 40, // Hier kannst du den Wert nach Bedarf anpassen
                child: Icon(
                  Icons.lock,
                  size: 100,
                ),
              ),
              Center(
                child: SingleChildScrollView(
                  //TODO: brauchen wir das eigentlich?
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 60,
                      ),
                      CustomContainer(
                        title: "Verify your Email",
                        smallSize: true,
                        children: [
                          const SizedBox(height: 25),
                          const Text(
                            "$message support@MoneyTrip.com",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              //TODO: style in styles.dart Ubuntu verwenden
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 50),
                          OtpTextField(
                            fieldWidth: 60.0,
                            borderWidth: 4,
                            textStyle: const TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                            borderColor: Colors.white,
                            fillColor: Colors.white,
                            numberOfFields: 4,
                            filled: true,
                            onSubmit: (code) {
                              print("OTP is => $code");
                            },
                          ),
                          const SizedBox(height: 35),
                          const Icon(
                            Icons.verified,
                            color: Colors.white,
                            size: 40,
                          ),
                          const SizedBox(
                            height: 35,
                          ),

                          MyButton(
                            /*onTap: () => {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const PasswordChange()))
                            },
                            */
                            onTap:
                                canResendEmail ? sendVerificationEmail : null,
                            text: 'Resend Code',
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
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
