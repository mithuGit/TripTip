import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';
import 'package:internet_praktikum/ui/views/login_register_pages/login_or_register_page.dart';
import 'package:internet_praktikum/ui/widgets/container.dart';
import 'package:internet_praktikum/ui/widgets/inputfield.dart';
import 'package:internet_praktikum/ui/widgets/my_button.dart';
import 'package:internet_praktikum/ui/widgets/inputfield_password_or_icon.dart';
import '../../../core/services/auth_service.dart';
import '../verification/OTP_Form.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';

import 'home_page.dart';

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
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
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
          // Add other data fields as needed
        });
      }
      // pop the loading circle
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      // pop the loading circle
      Navigator.pop(context);
      // Wrong email | Wrong password
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
        MaterialPageRoute(
            builder: (context) => Scaffold(
                  body: WebViewPlus(
                    javascriptMode: JavascriptMode.unrestricted,
                    onWebViewCreated: (controller) {
                      controller.loadUrl("assets/capcha.html");
                    },
                    javascriptChannels: {
                      JavascriptChannel(
                          name: 'Captcha',
                          onMessageReceived: (JavascriptMessage message) {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const LoginOrRegisterPage()));
                          })
                    },
                  ),
                )),
      );
    }
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: Center(
            child: Text(
              message,
              style: Styles.textfieldHintStyle,
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
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 80, left: 14, right: 14, bottom: 45),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.lock,
                      size: 100,
                    ),
                    CustomContainer(
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
                          text: "Login with Google",
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
                  ]),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> sendEmailforRestPassword(BuildContext context) {
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const OTPForm(
                                      passwordverifier: true,
                                    )),
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
