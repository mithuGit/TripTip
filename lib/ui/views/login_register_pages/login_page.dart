import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internet_praktikum/ui/widgets/container.dart';
import 'package:internet_praktikum/ui/widgets/errorSnackbar.dart';
import 'package:internet_praktikum/ui/widgets/inputfield.dart';
import 'package:internet_praktikum/ui/widgets/my_button.dart';
import 'package:internet_praktikum/ui/widgets/inputfield_password_or_icon.dart';
import '../../../core/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;

  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordforgotController = TextEditingController();

  var counter = 0;

  // sign user in method
  void signUserIn() async {
    // try sign in
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      if (context.mounted) {
        GoRouter.of(context).go('/');
      }
    } on FirebaseAuthException catch (e) {
      print(e.code);
      // Wrong email | Wrong password
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        if (context.mounted) {
          ErrorSnackbar.showMessage(
              'Wrong email or password! Please try again.', context, counter);
          counter++;
        }
      }
      // User disabled
      else if (e.code == 'user-disabled') {
        if (context.mounted) {
          ErrorSnackbar.showMessage(
              'This user has been disabled.', context, counter);
          counter++;
        }
      }
      // Too many requests
      else if (e.code == 'too-many-requests') {
        if (context.mounted) {
          ErrorSnackbar.showMessage(
              'Too many requests. Try again later.', context, counter);
          counter++;
        }
      }
      // Operation not allowed
      else if (e.code == 'operation-not-allowed') {
        if (context.mounted) {
          ErrorSnackbar.showMessage(
              'Operation not allowed. Try again later.', context, counter);
          counter++;
        }
      } else {
        if (context.mounted) {
          ErrorSnackbar.showMessage(
              'Something went wrong. Try again later.', context, counter);
          counter++;
        }
      }
    }
  }

  bool isDateOfBirth = true;
  //error messsage to user

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(children: [
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
                  title: "Login:",
                  children: [
                    InputField(
                      controller: emailController,
                      hintText: 'Email',
                      obscureText: false,
                      margin: const EdgeInsets.only(bottom: 25),
                    ),
                    InputFieldPasswortOrIcon(
                      controller: passwordController,
                      hintText: 'Password',
                      obscureText: true,
                      eyeCheckerStatus: true,
                      useSuffixIcon: true,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: sendEmailforRestPassword(context),
                    ),
                    const SizedBox(height: 25),
                    MyButton(
                      text: 'Sign In',
                      onTap: signUserIn,
                    ),
                    const SizedBox(height: 30),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 25.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Divider(
                              thickness: 0.5,
                              color: Colors.white,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.0),
                            child: Text(
                              'Or continue with',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              thickness: 0.5,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    MyButton(
                      onTap: () async {
                        await signInWithGoogle();
                        bool isDateOfBirth = true;

                        // testen ob DateOfBirth == null, dann soll AccountDetails aufgerufen werden
                        FirebaseAuth.instance
                            .authStateChanges()
                            .listen((user) async {
                          if (user != null) {
                            DocumentSnapshot documentSnapshot =
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(user.uid)
                                    .get();

                            if (documentSnapshot.exists) {
                              if ((documentSnapshot.data()
                                      as Map<String, dynamic>)['dateOfBirth'] ==
                                  null) {
                                isDateOfBirth = false;
                              }
                            }
                          }

                          if (isDateOfBirth == false) {
                            if (context.mounted) context.go('/accountdetails');
                          } else {
                            if (context.mounted) context.go('/');
                          }
                        });
                      },
                      imagePath: 'assets/google_logo.png',
                      text: "Login with Google",
                    ),

                    const SizedBox(height: 25),
                    MyButton(
                      onTap: () async {
                        await signInWithFacebook();
                        bool isDateOfBirth = true;

                        // testen ob DateOfBirth == null, dann soll AccountDetails aufgerufen werden
                        FirebaseAuth.instance
                            .authStateChanges()
                            .listen((user) async {
                          if (user != null) {
                            DocumentSnapshot documentSnapshot =
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(user.uid)
                                    .get();

                            if (documentSnapshot.exists) {
                              if ((documentSnapshot.data()
                                      as Map<String, dynamic>)['dateOfBirth'] ==
                                  null) {
                                isDateOfBirth = false;
                              }
                            }
                          }

                          if (isDateOfBirth == false) {
                            if (context.mounted) context.go('/accountdetails');
                          } else {
                            if (context.mounted) context.go('/');
                          }
                        });
                      },
                      imagePath: 'assets/facebook_logo.png',
                      text: "Login with Facebook",
                    ),
                    const SizedBox(
                      height: 25,
                    ),

                    // Hier wird eine gestrichelte Linie gezeichnet
                    // mit der Klasse DashedLinePainter (siehe unten)
                    CustomPaint(
                      painter: DashedLinePainter(),
                    ),

                    const SizedBox(
                      height: 25,
                    ),
                    MyButton(
                      onTap: widget.onTap,
                      text: "Create a new Account", /*small: true,*/
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
              height: 158,
              child: Center(
                  child: Image.asset(
                'assets/logo.png',
                width: 76,
              ))),
        ]),
      ),
    );
  }

  List<Widget> sendEmailforRestPassword(BuildContext context) {
    return [
      GestureDetector(
        onTap: () {
          showModalBottomSheet(
            isScrollControlled: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            context: context,
            builder: (BuildContext context) {
              return Padding(
                padding: MediaQuery.of(context).viewInsets,
                child: Container(
                  //height: MediaQuery.of(context).size.height * 0.4,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(100),
                      topRight: Radius.circular(100),
                    ),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Enter your email to reset your password:',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 10),
                      InputFieldPasswortOrIcon(
                        controller: passwordforgotController,
                        hintText: 'Email',
                        obscureText: false,
                        icon: Icons.email_outlined,
                        eyeCheckerStatus: false,
                        useSuffixIcon: false,
                      ),
                      const SizedBox(height: 20),
                      MyButton(
                        colors: Colors.black,
                        text: 'Next',
                        onTap: () {
                          String emailToCheck = passwordforgotController.text;
                          if (isValidEmail(emailToCheck)) {
                            resetPassword(emailToCheck);
                            Navigator.of(context).pop();
                            if (context.mounted) {
                              ErrorSnackbar.showMessage(
                                  'A reset link has been sent to your email.',
                                  context,
                                  counter);
                              counter++;
                            }
                          } else {
                            if (context.mounted) {
                              ErrorSnackbar.showMessage(
                                  'Please enter a valid email',
                                  context,
                                  counter);
                              counter++;
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        child: const Text(
          'Forgot Password?',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ];
  }

  bool isValidEmail(String email) {
    String emailRegex =
        r'^[\w-]+(\.[\w-]+)*@([a-z\d-]+(\.[a-z\d-]+)*?\.[a-z]{2,6}|(\d{1,3}\.){3}\d{1,3})$';
    RegExp regex = RegExp(emailRegex);
    return regex.hasMatch(email);
  }

  Future resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      print(e);
    }
  }
}

// Mit dieser Klasse kann man eine gestrichelte Linie zeichnen lassen
class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double dashWidth = 15, dashSpace = 5, startX = 0;
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
