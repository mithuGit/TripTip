// ignore_for_file: file_names
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';
import 'package:internet_praktikum/ui/widgets/container.dart';
import 'package:internet_praktikum/ui/widgets/errorSnackbar.dart';
import '../../widgets/my_button.dart';

/*
  This class is the widget for the OTP page
  The user can verify their email address by entering the OTP
*/

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

// checkEmailVerified checks if the email is verified
  Future checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser!.reload();

    if (mounted) {
      setState(() {
        isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
      });
    }

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
                    children: <Widget>[
                      const SizedBox(height: 25),
                      const Text(
                        "$message Please check your inbox.",
                        textAlign: TextAlign.center,
                        style: Styles.verifystyle,
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
                        height: 45,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.4,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: MyButton(
                                onTap: () async {
                                  DocumentSnapshot userDoc =
                                      await FirebaseFirestore
                                          .instance
                                          .collection('users')
                                          .doc(FirebaseAuth
                                              .instance.currentUser!.uid)
                                          .get();

                                  if (userDoc.exists) {
                                    await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(FirebaseAuth
                                            .instance.currentUser!.uid)
                                        .delete();

                                    await FirebaseAuth.instance.currentUser!
                                        .delete();
                                  }
                                  if (context.mounted) {
                                    context.go('/loginorregister');
                                  }
                                },
                                text: 'Back',
                              ),
                            ),
                          ),
                          if (canResendEmail)
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.4,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: MyButton(
                                  onTap: resendVerificationEmail,
                                  text: "Resend Link",
                                ),
                              ),
                            )
                          else
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.4,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: MyButton(
                                  onTap: () {
                                    context.go('/accountdetails/false');
                                  },
                                  text: 'Next',
                                ),
                              ),
                            ),
                        ],
                      )
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

// method to resend the verification email
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
      // ignore: use_build_context_synchronously
      ErrorSnackbar.showErrorSnackbar(context, e.message!);
      if (kDebugMode) {
        print(e.code);
      }
    }
  }
}
