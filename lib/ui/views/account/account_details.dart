import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:internet_praktikum/ui/views/navigation/app_navigation.dart';
import 'package:internet_praktikum/ui/widgets/inputfield_password_or_icon.dart';
import 'package:internet_praktikum/ui/widgets/my_button.dart';
import '../../widgets/container.dart';
import '../../widgets/inputfield.dart';
import '../../widgets/datepicker.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Account extends StatefulWidget {
  const Account({super.key});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final userCollection = FirebaseFirestore.instance.collection('users');
  final storage = FirebaseStorage.instance;

  final prenameController = TextEditingController();
  final lastnameController = TextEditingController();
  final emailController = TextEditingController();
  final dateOfBirthController = TextEditingController();
  final passwordController = TextEditingController();
  late String selectedDate;
  late ImageProvider<Object>? imageProvider;

  String imageURL = '';

  void updateUserData(String prename, String lastname, String dateOfBirth,
      String email, String image) async {
    await userCollection.doc(currentUser.uid).update({
      'prename': prename,
      'lastname': lastname,
      'dateOfBirth': dateOfBirth,
      'email': email,
      'profilepicture': image,
    });
  }

  Future<void> updateUserEmail(
      String newEmail, String oldMail, String password) async {
    try {
      AuthCredential credential =
          EmailAuthProvider.credential(email: oldMail, password: password);
      await currentUser.reauthenticateWithCredential(credential);
      await currentUser.verifyBeforeUpdateEmail(newEmail);
      print("Email has been updated");
    } catch (e) {
      if (kDebugMode) {
        print("Error updating email: $e");
      }
    }
  }

  Future<void> updateDisplayName(String prename, String lastName) async {
    try {
      await currentUser.updateDisplayName("$prename $lastName");
    } catch (e) {
      if (kDebugMode) {
        print("Error updating Displayname: $e");
      }
    }
  }

  @override
  void initState() {
    super.initState();
    emailController.text = currentUser.email!;
    if (currentUser.displayName != null &&
        currentUser.displayName!.isNotEmpty) {
      List<String> displayNameParts = currentUser.displayName!.split(' ');
      if (displayNameParts.length == 2) {
        prenameController.text = displayNameParts[0];
        lastnameController.text = displayNameParts[1];
      }
    }

    currentUser.photoURL != null
        ? imageProvider = NetworkImage(currentUser.photoURL!)
        : imageProvider = const AssetImage('assets/Personavatar.png');
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
                        Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                // Pick image from gallery
                                ImagePicker imagePicker = ImagePicker();
                                XFile? pickedFile = await imagePicker.pickImage(
                                    source: ImageSource.gallery) as XFile?;
                                //get reference to storage root
                                Reference referenceRoot =
                                    FirebaseStorage.instance.ref();
                                Reference referenceDirImages =
                                    referenceRoot.child('profilePictures');

                                // create a refernece for the image to be stored
                                Reference referenceImageToUpload =
                                    referenceDirImages.child(currentUser.uid);

                                //Handle errors/succes
                                try {
                                  if (pickedFile != null) {
                                    await referenceImageToUpload
                                        .putFile(File(pickedFile.path));
                                  }
                                  imageURL = await referenceImageToUpload
                                      .getDownloadURL();
                                } catch (e) {
                                  print(e);
                                }

                                setState(() {
                                  imageProvider = (pickedFile != null
                                          ? FileImage(File(pickedFile.path))
                                          : AssetImage(
                                              'assets/Personavatar.png'))
                                      as ImageProvider<Object>?;
                                });
                              },
                              child: CircleAvatar(
                                radius: 37.5,
                                backgroundImage: imageProvider,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        InputField(
                          controller: prenameController,
                          hintText: currentUser.displayName.toString(),
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
                          onDateSelected: (DateStringTupel dateStringTupel) {
                            setState(() {
                              selectedDate = dateStringTupel.dateString;
                            });
                          },
                          showFuture: false,
                        ),
                        InputField(
                          controller: emailController,
                          hintText: "Email",
                          obscureText: false,
                          margin: const EdgeInsets.only(bottom: 25),
                        ),
                        MyButton(
                          onTap: () async {
                            //store information of item in cloud firestore

                            currentUser.updatePhotoURL(imageURL);
                            updateUserData(
                                prenameController.value.text,
                                lastnameController.value.text,
                                selectedDate,
                                emailController.value.text.isEmpty
                                    ? userData['email']
                                    : emailController.value.text,
                                imageURL);
                            if (emailController.text.isNotEmpty &&
                                emailController.text != currentUser.email) {
                              print("UPDATED EMAIL");
                              await updateUserEmail(
                                  emailController.text,
                                  'felixbauer320@gmail.com',
                                  passwordController.text);
                            }
                            updateDisplayName(prenameController.text,
                                lastnameController.text);

                            context.go("/createtrip");
                          },
                          text: 'Finish',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error ${snapshot.error}'),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
