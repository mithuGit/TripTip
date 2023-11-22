import 'dart:math';

import 'package:dotted_line/dotted_line.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/widgets/container.dart';
import '../../../core/services/auth_service.dart';
import '../../widgets/my_button.dart';
import '../../widgets/inputfield_password_or_icon.dart';
import '../../widgets/my_textfield_emailnotnull.dart';

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
    // show loading circle
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    // try sign up (try creating the user)
    try {
      // check if passwords match
      if (passwordController.text == confirmPasswordController.text) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
      } else {
        // show error message
        showErrorMEssage('Passwords do not match!');
      }

      // pop the loading circle
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      // pop the loading circle
      Navigator.pop(context);
      // Wrong email
      /*
      if (e.code == 'user-not-found') {
        //print('No user found for that email.');
        showErrorMEssage('Wrong Email');
      }
      // Wrong password
      else if (e.code == 'wrong-password') {
        //print('Wrong password provided for this email.');
        wrongPasswordMessage('Wrong Password');
      }
      */
      showErrorMEssage(e.code);
    }
  }

  //error messsage to user
  void showErrorMEssage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.deepPurple,
          title: Center(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
          child: Container(
            decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/BackgroundCity.png'),
                  fit: BoxFit.cover,
                ),
            ),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                            Icons.lock,
                            size: 100,
                      ),
                      CustomContainer(
                        title: "Register",
                        children: [
                          MyTextFieldemailnotnull(
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
                            
                        /*   MyButton(
                            onTap: () => AuthService().signInWithGoogle(),
                            imagePath: 'assets/google_logo.png',
                            text: "Register with Google",
                          ), */
                          const SizedBox(height: 25),
                            
                          MyButton(
                            onTap: () {},
                            imagePath: 'assets/facebook_logo.png',
                            text: "Register with Facebook",
                          ),
                            
                          const SizedBox(height: 15,),
                            
                          const DottedLine(
                            dashColor: Colors.white,
                            lineThickness: 1,
                            dashGapLength: 7,
                            dashRadius: 1,
                            dashLength: 5,
                            direction: Axis.horizontal,
                            lineLength: 365,
                          ),
                            
                          const SizedBox(height: 15, ),
                            
                          MyButton(
                            onTap: widget.onTap,
                            text: "Already have an account?",
                          )
                        
                        ],
                      ),
                    ]
                  ),
              ),
            ),
          ),
        )
      );
  }
}
