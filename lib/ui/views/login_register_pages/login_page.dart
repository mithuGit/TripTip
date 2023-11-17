import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/widgets/my_button.dart';
import '../../../core/services/auth_service.dart';
import '../../widgets/my_textfield.dart';
import '../../widgets/my_textfield_icon.dart';
import '../Resetpassword/OTP_form.dart';
import 'package:dotted_line/dotted_line.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;

  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // text editing controllers
  final emailController = TextEditingController();
  final passwordforgotController = TextEditingController();
  final passwordController = TextEditingController();

  var counter = 0;

  // sign user in method
  void signUserIn() async {
    // show loading circle
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    // try sign in
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
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
      showErrorMessage(e.code);
    }
  }

  //error messsage to user
  void showErrorMessage(String message) {
    counter++;
    // Wenn Counter gleich 3 ist, wird eigentlich hier Capcha aufgerufen
    if (counter == 3) {
      counter = 0;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const OTPForm()),
      );
    }
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
      backgroundColor: const Color.fromARGB(255, 168, 217, 251),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background_city.png'), // Passe den Pfad zu deinem Hintergrundbild an
            alignment: Alignment.center,
            fit: BoxFit.fill,
          ),
      ),

      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const SizedBox(height: 50),
              const Icon(
                Icons.lock,
                size: 100,
              ),
              const SizedBox(height: 50),
              const Text(
                'Welcome back you \'ve been missed!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 25),
              MyTextField(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false),
              const SizedBox(height: 10),
              MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: resetpassword(context),
                ),
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
                onTap: () => AuthService().signInWithGoogle(),
                imagePath: 'assets/google_logo.png',
                text: "Login with Google",
                ),
              const SizedBox(height: 25),
              MyButton(
                onTap: () {}, 
                imagePath: 'assets/facebook_logo.png',
                text: "Login with Facebook",
              ),
              
              const SizedBox(height: 15,),

              const DottedLine(
                dashColor: Colors.white,
                lineThickness: 1,
                dashGapLength: 7,
                dashRadius: 1,
                dashLength: 5,
                direction: Axis.horizontal,
                lineLength: 365,),

              const SizedBox(height: 15,),

              MyButton(onTap: widget.onTap, text: "Create a new Account", small: true,),

              

              /*
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Not a member?',
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: const Text(
                      'Register now',
                      style: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              )
              */

            ]),
          ),
        ),
      ),
    ),
    );
  }

  List<Widget> resetpassword(BuildContext context) {
    return [
      GestureDetector(
        onTap: () {
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
                    MyTextFieldicon(
                      controller: passwordforgotController,
                      hintText: 'Email',
                      obscureText: false,
                      icon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 20),
                    MyButton(
                      text: 'Next',
                      onTap: () {
                        String emailToCheck = passwordforgotController.text;
                        if (isValidEmail(emailToCheck)) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const OTPForm()),
                          );
                        } else {
                          isValidEmail(passwordforgotController.text)
                              ? Colors.white
                              : Colors.red;

                          //hier fehlt noch was
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: const Text(
          'Forgot Password?',
          style: TextStyle(
            color: Colors.blue,
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
}
