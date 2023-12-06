import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
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
  //auth user
  final currentUser = FirebaseAuth.instance.currentUser!;
  //all user
  final userCollection = FirebaseFirestore.instance.collection('users');

  //Controller for text
  final prenameController = TextEditingController();
  final lastnameController = TextEditingController();
  final emailController = TextEditingController();
  final dateOfBirthController = TextEditingController();
  late String selectedDate;

//sets the changes to the Collection
  void updateUserData(
      String prename, String lastname, String dateOfBirth, String email) async {
    await userCollection.doc(currentUser.uid).update({
      'prename': prename,
      'lastname': lastname,
      'dateOfBirth': dateOfBirth,
      'email': email,
    });
  }

  // Update user email in Firebase Authentication
  Future<void> updateUserEmail(String newEmail) async {
    try {
      await currentUser.updateEmail(newEmail);
    } catch (e) {
      // Handle the error, for example, show an error message to the user
      if (kDebugMode) {
        print("Error updating email: $e");
      }
    }
  }

  @override
  void initState() {
    super.initState();
    emailController.text = currentUser.email!;
    if (currentUser.displayName != null &&
        currentUser.displayName!.isNotEmpty) {
      List<String> displayNameParts = currentUser.displayName!.split(', ');
      if (displayNameParts.length == 2) {
        prenameController.text =
            displayNameParts[1]; // Assuming Prename is the second part
        lastnameController.text =
            displayNameParts[0]; // Assuming LastName is the first part
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFCBEFFF),
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .snapshots(),
          builder: (context, snapshot) {
            //get User Data
            if (snapshot.hasData) {
              final userData = snapshot.data!.data() as Map<String, dynamic>;
              return SafeArea(
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
                          // Profile Picture
                          GestureDetector(
                            onTap: () {},
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
                            hintText: "Prename",
                            obscureText: false,
                            margin: const EdgeInsets.only(bottom: 25),
                          ),
                          InputField(
                            controller: lastnameController,
                            hintText: 'LastName',
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
                          CupertinoDatePickerButton(
                            margin: const EdgeInsets.only(bottom: 25),
                            onDateSelected: (String formattedDate) {
                              setState(() {
                                selectedDate = formattedDate;
                              });
                            },
                          ),
                          InputField(
                            controller: emailController,
                            hintText: "Email",
                            obscureText: false,
                            margin: const EdgeInsets.only(bottom: 25),
                          ),
                          MyButton(
                              onTap: () async {
                                updateUserData(
                                    prenameController.value.text,
                                    lastnameController.value.text,
                                    selectedDate,
                                    emailController.value.text.isEmpty
                                        ? userData['email']
                                        : emailController.value.text);
                                if (emailController.text.isNotEmpty &&
                                    emailController.text != currentUser.email) {
                                  await updateUserEmail(emailController.text);
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const HomePage(),
                                  ),
                                );
                              },
                              text: 'Finish'),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            } else if (snapshot.hasData) {
              return Center(
                child: Text('Error${snapshot.error}'),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ));
  }
}
