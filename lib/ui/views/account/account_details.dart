import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:internet_praktikum/ui/widgets/my_button.dart';
import '../../widgets/container.dart';
import '../../widgets/inputfield.dart';
import '../../widgets/datepicker.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Account extends StatefulWidget {
  final bool isEditProfile;
  const Account({super.key, required this.isEditProfile});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final userCollection = FirebaseFirestore.instance.collection('users');
  final storage = FirebaseStorage.instance;

  //Controller for text
  final prenameController = TextEditingController();
  final lastnameController = TextEditingController();
  final emailController = TextEditingController();
  final dateOfBirthController = TextEditingController();
  final passwordController = TextEditingController();

  XFile? pickedFile;

  //sonst late inizalisiert fehler
  String selectedDate = '';
  ImageProvider<Object>? imageProvider;

  String imageURL = '';
  //set and updates Userdata in the FirebaseCollestion users
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

  //Update the email in Auth
  Future<void> updateAuthEmail(
      String newEmail, String oldMail, String password) async {
    AuthCredential credential =
        EmailAuthProvider.credential(email: oldMail, password: password);

    await currentUser.reauthenticateWithCredential(credential).then((value) {
      currentUser.updateEmail(newEmail);
    }).catchError((e) {
      if (kDebugMode) {
        print(e.toString());
      }
    });
  }

  //Updates displayName in Auth
  Future<void> updateAuthDisplayName(String prename, String lastName) async {
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
    getUserData();

    //TODO: damit kann man irgendwie das Bild in Avatr sehen,
    //TODO: check aber nicht so ganz wieso? Ich glaub es liegt daran, dass es sonst nicht inizalisiert ist
    //TODO: und currentUser-photoUrl das gleiche ist wie profilepicture in der DB
    currentUser.photoURL != null
        ? imageProvider = NetworkImage(currentUser.photoURL!)
        : imageProvider = const AssetImage('assets/Personavatar.png');
  }

  Future<void> getUserData() async {
    var collection = userCollection.doc(currentUser.uid);
    DocumentSnapshot userdata = await collection.get();
    if (!userdata.exists) {
      throw Exception('Document does not exist!');
    }
    if (kDebugMode) {
      print('Document data: ${userdata.data()}');
    }
    Map<String, dynamic> userData = userdata.data()! as Map<String, dynamic>;

    if (userData['prename'] != null) {
      setState(() {
        prenameController.text = userData['prename'];
      });
    }
    if (userData['lastname'] != null) {
      setState(() {
        lastnameController.text = userData['lastname'];
      });
    }
    if (userData.containsKey('profilePicture') &&
        userData['profilePicture'] != null) {
      setState(() {
        imageURL = userData['profilePicture'];
      });
    } else {
      setState(() {
        imageURL = '';
      });
    }
    emailController.text = currentUser.email!;
    if (currentUser.displayName != null &&
        currentUser.displayName!.isNotEmpty) {
      List<String> displayNameParts = currentUser.displayName!.split(' ');
      if (displayNameParts.length == 2) {
        setState(() {
          prenameController.text = displayNameParts[0];
          lastnameController.text = displayNameParts[1];
        });
      }
    }
    if (userData.containsKey('dateOfBirth') &&
        userData['dateOfBirth'] != null) {
      setState(() {
        selectedDate = userData['dateOfBirth'];
      });
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
                                pickedFile = await imagePicker.pickImage(
                                    source: ImageSource.gallery);
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
                                        .putFile(File(pickedFile!.path));
                                  }
                                  imageURL = await referenceImageToUpload
                                      .getDownloadURL();
                                } catch (e) {
                                  if (kDebugMode) {
                                    print(e);
                                  }
                                }
                                setState(() {
                                  imageProvider = ((pickedFile != null
                                          ? FileImage(File(pickedFile!.path))
                                          : const AssetImage(
                                              'assets/Personavatar.png'))
                                      as ImageProvider<Object>?)!;
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
                          hintText: 'First Name',
                          obscureText: false,
                          margin: const EdgeInsets.only(bottom: 25),
                        ),
                        InputField(
                          controller: lastnameController,
                          hintText: 'Last Name',
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
                          presetDate: selectedDate,
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
                          validator: ((p0) {
                            if (p0 == null || p0.isEmpty) {
                              return 'Please enter a email adress';
                            } else if (!isValidEmail(p0)) {
                              return 'Please enter an valid email adress';
                            }
                            return null;
                          }),
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
                              await updateAuthEmail(emailController.text,
                                  'felixtest87@gmail.com', 'test123');
                            }
                            updateAuthDisplayName(prenameController.text,
                                lastnameController.text);

                            if (context.mounted) {
                              widget.isEditProfile == true
                                  ? context.go('/profile')
                                  : context.go('/setinterests/true');
                            }
                          },
                          text: widget.isEditProfile == true
                              ? "Finish"
                              : 'Select your Interests',
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

bool isValidEmail(String email) {
  String emailRegex =
      r'^[\w-]+(\.[\w-]+)*@([a-z\d-]+(\.[a-z\d-]+)*?\.[a-z]{2,6}|(\d{1,3}\.){3}\d{1,3})$';
  RegExp regex = RegExp(emailRegex);
  return regex.hasMatch(email);
}
