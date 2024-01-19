import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:internet_praktikum/ui/widgets/errorSnackbar.dart';
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

  Color buttonColor = Colors.grey;
  Color buttonFill = Colors.white;
  var buttonIcon = Icons.copy;

  //sonst late inizalisiert fehler
  String selectedDate = '';
  ImageProvider<Object>? imageProvider;

  String imageURL = '';
  bool uploading = false;

  //set and updates Userdata in the FirebaseCollestion users
  Future<void> updateUserData(
      String prename, String lastname, String dateOfBirth, String image) async {
    try {
      await userCollection.doc(currentUser.uid).update({
        //Updates data in FireStore
        'prename': prename,
        'lastname': lastname,
        'dateOfBirth': dateOfBirth,
        'profilePicture': image,
      });
      await currentUser.updateDisplayName(
          "$prename $lastname"); //Updates displayName in Auth
    } on Exception catch (e) {
      if (kDebugMode) {
        print("Something went wrong while fetching your data $e");
      }
      // ignore: use_build_context_synchronously
      ErrorSnackbar.showErrorSnackbar(
          context, "Something went wrong while fetching your data");
    }
  }

  Future<DocumentSnapshot> getUserdata() async {
    DocumentSnapshot user = await userCollection.doc(currentUser.uid).get();
    if (!user.exists) throw "User does't exists";
    return user;
  }

  @override
  Widget build(BuildContext context) {
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
                  FutureBuilder(
                      future: getUserdata(),
                      builder:
                          (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snapshot.hasError) {
                          return const Text(
                              "Something went wrong while fetching your data ");
                        }
                        Map<String, dynamic> userData =
                            snapshot.data!.data()! as Map<String, dynamic>;
                        if (userData['prename'] != null) {
                          prenameController.text = userData['prename'];
                        }
                        if (userData['lastname'] != null) {
                          lastnameController.text = userData['lastname'];
                        }
                        if (userData['dateOfBirth'] != null) {
                          selectedDate = userData['dateOfBirth'];
                        }
                        if (userData['email'] != null) {
                          emailController.text = userData['email'];
                        }
                        imageProvider =
                            AssetImage('assets/Personavatar.png');
                        if (userData.containsKey('profilePicture')) {
                          imageURL = userData['profilePicture'];
                          imageProvider = NetworkImage(imageURL);
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    setState(() {
                                      uploading = true;
                                    });
                                    ImagePicker imagePicker = ImagePicker();
                                    XFile? pickedFile;
                                    pickedFile = await imagePicker.pickImage(
                                        source: ImageSource.gallery);
                                    //get reference to storage root
                                    Reference referenceRoot =
                                        FirebaseStorage.instance.ref();
                                    Reference referenceDirImages =
                                        referenceRoot.child('profilePictures');

                                    // create a refernece for the image to be stored
                                    Reference referenceImageToUpload =
                                        referenceDirImages
                                            .child(currentUser.uid);

                                    //Handle errors/succes
                                    try {
                                      if (pickedFile != null) {
                                        await referenceImageToUpload
                                            .putFile(File(pickedFile!.path));
                                      }
                                      imageURL =
                                          referenceImageToUpload.fullPath;
                                    } catch (e) {
                                      if (kDebugMode) {
                                        print(
                                            "Something went wrong while uploading your image $e");
                                      }
                                      // ignore: use_build_context_synchronously
                                      ErrorSnackbar.showErrorSnackbar(context,
                                          "Something went wrong while uploading your image");
                                    }

                                    if (pickedFile != null) {
                                      setState(() {
                                        imageProvider =
                                            FileImage(File(pickedFile!.path));
                                      });
                                    }
                                    setState(() {
                                      uploading = false;
                                    });
                                  },
                                  child: CircleAvatar(
                                    radius: 37.5,
                                    backgroundImage: imageProvider,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            if (uploading)
                              const Center(child: LinearProgressIndicator()),
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
                              margin: const EdgeInsets.only(bottom: 10),
                            ),
                            const SizedBox(height: 10),
                            const SizedBox(
                              width: 148,
                              height: 18,
                              child: Text(
                                'Date of Birth:',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontFamily: 'Ubuntu',
                                  fontWeight: FontWeight.w500,
                                  height: 0,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            CupertinoDatePickerButton(
                              presetDate: selectedDate,
                              margin: const EdgeInsets.only(bottom: 25),
                              onDateSelected:
                                  (DateStringTupel dateStringTupel) {
                                setState(() {
                                  selectedDate = dateStringTupel.dateString;
                                });
                              },
                              showFuture: false,
                            ),
                            InputField(
                              readOnly: true,
                              controller: emailController,
                              hintText: "Email",
                              obscureText: false,
                            ),
                            const SizedBox(height: 20),
                            const SizedBox(
                              width: 148,
                              height: 18,
                              child: Text(
                                'User ID:',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontFamily: 'Ubuntu',
                                  fontWeight: FontWeight.w500,
                                  height: 0,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 275,
                                  child: InputField(
                                    readOnly: true,
                                    controller: TextEditingController(
                                        text: currentUser.uid),
                                    hintText: "UID",
                                    obscureText: false,
                                  ),
                                ),
                                SizedBox(
                                  child: Card(
                                      color: buttonFill,
                                      margin: const EdgeInsets.only(left: 10),
                                      child: IconButton(
                                          onPressed: () {
                                            Clipboard.setData(ClipboardData(
                                                text: currentUser.uid));
                                            setState(() {
                                              buttonFill = Colors.green;
                                              buttonIcon = Icons.check;
                                              buttonColor = Colors.white;
                                            });
                                          },
                                          icon: Icon(
                                            buttonIcon,
                                            color: buttonColor,
                                          ))),
                                )
                              ],
                            ),
                            const SizedBox(height: 25),
                            MyButton(
                              onTap: () async {
                                //store information of item in cloud firestore

                                //currentUser.updatePhotoURL(imageURL);
                                await updateUserData(
                                    prenameController.value.text,
                                    lastnameController.value.text,
                                    selectedDate,
                                    imageURL);

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
                        );
                      }),
                ],
              ),
            ),
          ),
        )));
  }
}
