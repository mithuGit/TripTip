import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internet_praktikum/core/services/init_pushnotifications.dart';
import 'package:internet_praktikum/ui/views/login_register_pages/login_page.dart';
import 'package:internet_praktikum/ui/widgets/container.dart';
import 'package:internet_praktikum/ui/widgets/errorSnackbar.dart';
import 'package:internet_praktikum/ui/widgets/inputfield.dart';
import '../../../core/services/auth_service.dart';
import '../../widgets/my_button.dart';
import '../../widgets/inputfield_password_or_icon.dart';

// Page to register a new user
class RegisterPage extends StatefulWidget {
  final Function()? onTap;

  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // sign user up method
  void signUserUp() async {
    // try sign up (try creating the user)
    try {
      // check if passwords match
      if (passwordController.text == confirmPasswordController.text) {
        emailController.text = emailController.text.trim();
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        if (userCredential.user != null) {
          // Hier wird die Verifizierung der E-Mail-Adresse des Users auf false gesetzt
          await userCredential.user!.updateEmail(userCredential.user!.email!);

          // Der User muss seine E-Mail-Adresse verifizieren, bevor er sich einloggen kann
          // sendet eine EmailVerifizierung an die E-Mail-Adresse des Users
          await userCredential.user!.sendEmailVerification();

          // Assuming 'users' is the collection name in Firestore
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
            'email': userCredential.user!.email,
            'prename': userCredential.user!.displayName,
            'lastname': userCredential.user!.displayName,
            'uid': userCredential.user!.uid,
            'profilePicture': null,
            'dateOfBirth': null,
            'selectedtrip': null
            // Add other data fields as needed
          });
        }
        await PushNotificationService().gantPushNotifications();
        if (context.mounted) {
          GoRouter.of(context).go('/otp');
        }
      } else {
        // show error message
        if (context.mounted) {
          ErrorSnackbar.showMessage('Passwords do not match!', context, 0);
        }
      }
    } on FirebaseAuthException catch (e) {
      print(e.code);
      // Wrong email | Wrong password
      if (e.code == 'weak-password') {
        if (context.mounted) {
          ErrorSnackbar.showMessage(
              'The password provided is too weak.', context, 0);
        }
      } else if (e.code == 'email-already-in-use') {
        if (context.mounted) {
          ErrorSnackbar.showMessage(
              'The account already exists for that email.', context, 0);
        }
      } else if (e.code == 'invalid-email') {
        if (context.mounted) {
          ErrorSnackbar.showMessage(
              'The email address is not valid.', context, 0);
        }
      } else if (e.code == 'operation-not-allowed') {
        if (context.mounted) {
          ErrorSnackbar.showMessage('Error during sign up.', context, 0);
        }
      } else if (e.code == 'user-disabled') {
        if (context.mounted) {
          ErrorSnackbar.showMessage(
              'The user account has been disabled.', context, 0);
        }
      } else {
        if (context.mounted) {
          ErrorSnackbar.showMessage('An undefined Error happened.', context, 0);
        }
      }
    }
  }

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
                  title: "Register",
                  children: [
                    InputField(
                        controller: emailController,
                        hintText: 'Email',
                        obscureText: false),
                    const SizedBox(height: 10),

                    InputFieldPasswortOrIcon(
                      controller: passwordController,
                      hintText: 'Password',
                      obscureText: true,
                      eyeCheckerStatus: true,
                      useSuffixIcon: true,
                    ),
                    const SizedBox(height: 10),

                    // confirm Password
                    InputFieldPasswortOrIcon(
                      controller: confirmPasswordController,
                      hintText: 'Confirm Password',
                      obscureText: true,
                      eyeCheckerStatus: true,
                      useSuffixIcon: true,
                    ),

                    const SizedBox(height: 25),

                    MyButton(
                        onTap: () {
                          signUserUp();
                        },
                        text: 'Sign Up'),

                    const SizedBox(height: 30),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Divider(
                              thickness: 0.5,
                              color: Colors.grey[400],
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.0),
                            child: Text(
                              'Or continue with',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const Expanded(
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
                            if (context.mounted)
                              context.go('/accountdetails/:isEditProfile');
                          } else {
                            if (context.mounted) context.go('/');
                          }
                        });
                      },
                      imagePath: 'assets/google_logo.png',
                      text: "Register with Google",
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
                            if (context.mounted)
                              context.go('/accountdetails/:isEditProfile');
                          } else {
                            if (context.mounted) context.go('/');
                          }
                        });
                      },
                      imagePath: 'assets/facebook_logo.png',
                      text: "Register with Facebook",
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    CustomPaint(
                      painter: DashedLinePainter(),
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    MyButton(
                      onTap: widget.onTap,
                      text: "Already have an account?",
                    )
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
}
