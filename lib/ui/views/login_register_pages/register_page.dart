import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/views/login_register_pages/home_page.dart';
import 'package:internet_praktikum/ui/views/login_register_pages/login_page.dart';
import 'package:internet_praktikum/ui/widgets/container.dart';
import 'package:internet_praktikum/ui/widgets/inputfield.dart';
import '../../../core/services/auth_service.dart';
import '../../widgets/my_button.dart';
import '../../widgets/inputfield_password_or_icon.dart';

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
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
        if (userCredential.user != null) {
          // Assuming 'users' is the collection name in Firestore
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
          'email': userCredential.user!.email,
          'prename': userCredential.user!.displayName,
          'lastname': userCredential.user!.displayName,
          'uid': userCredential.user!.uid,
          'trips': null,
          'profilepicture': null,
          'dateOfBirth': null,
            // Add other data fields as needed
          });
        }
      } else {
        // show error message
        showErrorMEssage('Passwords do not match!');
      }
      // pop the loading circle
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      // pop the loading circle
      Navigator.pop(context);
      // Wrong email | Wrong password
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
                      //onTap: () => AuthService().signInWithGoogle(),
                      onTap: () {
                        signInWithGoogle().whenComplete(() {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return HomePage();
                              },
                            ),
                          );
                        });
                      },
                      imagePath: 'assets/google_logo.png',
                      text: "Register with Google",
                    ),
                    const SizedBox(height: 25),

                    MyButton(
                      onTap: () {
                        signInWithFacebook().whenComplete(() {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return HomePage();
                              },
                            ),
                          );
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
