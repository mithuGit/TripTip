import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/views/login_register_pages/home_page.dart';
import 'package:internet_praktikum/ui/widgets/my_button.dart';
import '../../widgets/container.dart';
import '../../widgets/inputfield.dart';
import '../../widgets/datepicker.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Account extends StatefulWidget {
  const Account({super.key});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  void updateDisplayName(String newDisplayName) async {
    // Get the current user
    User? user = FirebaseAuth.instance.currentUser;

    try {
      // Update the display name
      await user?.updateProfile(displayName: newDisplayName);

      // Reload the user to get the updated information
      await user?.reload();
      user = FirebaseAuth.instance.currentUser;

      // Print the updated user information
      print("User display name updated to: ${user?.displayName}");
    } on FirebaseAuthException catch (e) {
      print("Failed to update display name: $e");
    }
  }

  void updatePhoto(String photoURL) async {
    // Get the current user
    User? user = FirebaseAuth.instance.currentUser;

    try {
      // Update the photo name
      await user?.updatePhotoURL(photoURL);

      // Reload the user to get the updated information
      await user?.reload();
      user = FirebaseAuth.instance.currentUser;

      // Print the updated user information
      print("User photo name updated to: ${user?.photoURL}");
    } on FirebaseAuthException catch (e) {
      print("Failed to update photo: $e");
    }
  }

  //Controller for text
  final prenameController = TextEditingController();
  final lastnameController = TextEditingController();
  final emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    // Get Screen Size
    return Scaffold(
      backgroundColor: const Color(0xFFCBEFFF),
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
              child: CustomContainer(
                title: "Account Details:",
                children: [
                  GestureDetector(
                    onTap: () {
                      prenameController.text = 'Hello';
                    },
                    child: Image.asset(
                      'assets/Personavatar.png',
                      width: 75,
                      height: 75,
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  InputField(
                    controller: prenameController,
                    hintText: 'Prename',
                    obscureText: false,
                    margin: const EdgeInsets.only(bottom: 25),
                  ),
                  InputField(
                    controller: lastnameController,
                    hintText: 'Lastname',
                    obscureText: false,
                    margin: const EdgeInsets.only(bottom: 12.5),
                  ),
                  const SizedBox(
                    width: 148,
                    height: 18,
                    child: Text(
                      'Date of Birth',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontFamily: 'Ubuntu',
                        fontWeight: FontWeight.w500,
                        height: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12.5),
                  const CupertinoDatePickerButton(
                    margin: EdgeInsets.only(bottom: 25),
                  ),
                  InputField(
                    controller: emailController,
                    hintText: 'Email',
                    obscureText: false,
                    margin: const EdgeInsets.only(bottom: 25),
                  ),
                  MyButton(
                      onTap: () {
                        String displayName = prenameController.toString() +
                            lastnameController.toString();
                        updateDisplayName(displayName);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomePage(),
                          ),
                        );
                      },
                      text: 'Finish'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
