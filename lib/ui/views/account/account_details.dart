import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/widgets/my_button.dart';
import '../../widgets/container.dart';
import '../../widgets/inputfield.dart';
import '../../widgets/datepicker.dart';
import '../../widgets/my_textfield_emailnotnull.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Account extends StatefulWidget {
  const Account({super.key});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  final currentUser = FirebaseAuth.instance.currentUser!;

  //all user
  final userCollection = FirebaseFirestore.instance.collection('users');
  final authCollection = FirebaseAuth.instance.currentUser;

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

  @override
  Widget build(BuildContext context) {
    List<String> parts =
        FirebaseAuth.instance.currentUser!.toString().split(',');

// Now, parts[0] contains the part before the ','
    String preName = parts[0].trim();
    String lastName = parts[1].trim();
    // Get Screen Size
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
                            hintText: preName != null ? preName : "Prename",
                            obscureText: false,
                            margin: const EdgeInsets.only(bottom: 25),
                          ),
                          InputField(
                            controller: lastnameController,
                            hintText: lastName != null ? lastName : 'LastName',
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
                            margin: EdgeInsets.only(bottom: 25),
                            showFuture: false,
                            onDateSelected: (DateStringTupel formattedDate) {
                              setState(() {
                                selectedDate = formattedDate.dateString;
                              });
                            },
                          ),
                          MyTextFieldemailnotnull(
                            controller: emailController,
                            hintText: userData['email'],
                            obscureText: false,
                            margin: const EdgeInsets.only(bottom: 25),
                          ),
                          MyButton(
                              onTap: () {
                                updateUserData(
                                    prenameController.value.text,
                                    lastnameController.value.text,
                                    selectedDate,
                                    emailController.value.text);
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
