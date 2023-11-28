import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';
import 'package:internet_praktikum/ui/views/login_register_pages/home_page.dart';
import 'package:internet_praktikum/ui/views/login_register_pages/login_or_register_page.dart';
import 'package:internet_praktikum/ui/widgets/container.dart';
import 'package:internet_praktikum/ui/widgets/inputfield.dart';

import '../../widgets/my_button.dart';
import '../../widgets/inputfield_password_or_icon.dart';

class OTPForm extends StatefulWidget {
  final bool passwordverifier;
  const OTPForm({
    Key? key,
    required this.passwordverifier,
  }) : super(key: key);

  @override
  State<OTPForm> createState() => _OTPFormState();
}

class _OTPFormState extends State<OTPForm> {
  bool isEmailVerified = false;
  bool canResendEmail = false;
  Timer? timer;
  FirebaseAuth auth = FirebaseAuth.instance;

  
  /*
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
  */

  @override
  Widget build(BuildContext context) {
    const String message = "Enter the Verification code sent at ";

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
                        "$message support@MoneyTrip.com",
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
                          onTap: () {}, // TODO: => sendVerificationEmail(),
                          text: "Resend Link",
                        )
                      else
                        MyButton(
                          onTap: () {
                            if (widget.passwordverifier) {
                              resetpassword(context);
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HomePage(),
                                ),
                              );
                            }
                          },
                          text: widget.passwordverifier
                              ? 'Change Password'
                              : 'Next',
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

  void resetpassword(BuildContext context) {
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();

    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      context: context,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(100),
              topRight: Radius.circular(100),
            ),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Let\'s change your Password?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Please enter your new Password',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 40),

              InputFieldPasswortOrIcon(
                  controller: passwordController,
                  hintText: "New Password",
                  obscureText: true,
                  eyeCheckerStatus: true,
                  useSuffixIcon:
                      true), //TODO: controller anpassen, weil hier muss es an Firebase angepasst werden

              const SizedBox(height: 30),

              InputFieldPasswortOrIcon(
                  controller: confirmPasswordController,
                  hintText: "Confirm Password",
                  obscureText: true,
                  eyeCheckerStatus: true,
                  useSuffixIcon:
                      true), //TODO: controller anpassen, weil hier muss es an Firebase angepasst werden

              const SizedBox(height: 30),

              MyButton(
                text: 'Confirm',
                colors: Colors.black,
                onTap: () {
                  String newPassword = passwordController.text;
                  String confirmPassword = confirmPasswordController.text;

                  if (newPassword == confirmPassword) {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => LoginOrRegisterPage()));
                  } else {
                    // Passwörter stimmen nicht überein, zeige eine Fehlermeldung
                    showDialog(
                        context: context,
                        builder: (context) {
                          return const AlertDialog(
                            backgroundColor: Colors.black,
                            title: Center(
                              child: Text(
                                "Passwords do not match",
                                style: Styles.textfieldHintStyle,
                              ),
                            ),
                          );
                        });
                    print("Password do not match");
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
