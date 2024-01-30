import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:internet_praktikum/ui/widgets/errorSnackbar.dart';
import 'package:internet_praktikum/ui/widgets/my_button.dart';
import '../../widgets/container.dart';
import '../../widgets/inputfield.dart';
import '../../widgets/datepicker.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_cropper/image_cropper.dart';

/*
This class is being used to display the account details of the user. 
It is also used to edit the account details of the user.
to set the profile picture of the user, the user can click on the profile picture and select a picture from the gallery.

*/

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
  final passwordController = TextEditingController();

  Color buttonColor = Colors.grey;
  Color buttonFill = Colors.white;
  var buttonIcon = Icons.copy;

  //sonst late inizalisiert fehler
  String selectedDate = '';
  ImageProvider<Object>? imageProvider;

  DateTime? selectedDateTime;

  String imageURL = '';
  String newImageURL = '';
  String imagePath = '';
  String newImagePath = '';
  bool uploading = false;
  bool loarding = false;
  @override
  void initState() {
    super.initState();
    setState(() {
      loarding = true;
    });

    // get user data from firestore... after the widget is build
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      Map<String, dynamic> userData =
          (await getUserdata()).data() as Map<String, dynamic>;
      if (userData["prename"] != null) {
        prenameController.text = userData["prename"];
      }
      if (userData["lastname"] != null) {
        lastnameController.text = userData["lastname"];
      }
      if (userData["dateOfBirth"] != null) {
        selectedDate = userData["dateOfBirth"];
      }
      if (userData["email"] != null) {
        emailController.text = userData["email"];
      } else {
        emailController.text = currentUser.email!;
      }
      if (userData["profilePicture"] != null &&
          userData["profilePicture"] != "") {
        setState(() {
          imageURL = userData["profilePicture"];
          imageProvider = NetworkImage(userData["profilePicture"]);
        });
      }
      if (userData["profilePicturePath"] != null &&
          userData["profilePicturePath"] != "") {
        setState(() {
          imagePath = userData["profilePicturePath"];
        });
      }
      setState(() {
        loarding = false;
      });
    });
  }

  //set and updates Userdata in the FirebaseCollestion users
  Future<void> updateUserData() async {
    if (prenameController.text == "") throw "Please enter your first name";
    if (lastnameController.text == "") throw "Please enter your last name";
    if (selectedDate == "") throw "Please enter your date of birth";
    if (newImageURL != '') {
      imageURL = newImageURL;
      await currentUser.updatePhotoURL(imageURL);
    }
    if (newImagePath != '') {
      imagePath = newImagePath;
    }
    await userCollection.doc(currentUser.uid).update({
      //Updates data in FireStore
      'prename': prenameController.text,
      'lastname': lastnameController.text,
      'dateOfBirth': selectedDate,
      'profilePicture': imageURL,
      'profilePicturePath': imagePath,
    });
    //Updates displayName in Auth
    await currentUser.updateDisplayName(
        prenameController.text + " " + lastnameController.text);

    await currentUser.reload();
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
                  if (loarding)
                    const Center(child: CircularProgressIndicator()),
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
                          if (pickedFile != null) {
                            // The filecroper Class is used to crop the image
                            CroppedFile? croppedFile =
                                await ImageCropper().cropImage(
                              sourcePath: pickedFile.path,
                              cropStyle: CropStyle.circle,
                              aspectRatioPresets: [
                                CropAspectRatioPreset.square,
                              ],
                              compressFormat: ImageCompressFormat.jpg,
                              compressQuality: 50,
                              uiSettings: [
                                AndroidUiSettings(
                                    toolbarTitle: 'Crop Your Profile Picture',
                                    toolbarColor: Colors.blue,
                                    toolbarWidgetColor: Colors.white,
                                    initAspectRatio:
                                        CropAspectRatioPreset.square,
                                    lockAspectRatio: true),
                              ],
                            );
                            try {
                              //get reference to storage root
                              Reference referenceDirImages = FirebaseStorage
                                  .instance
                                  .ref()
                                  .child('profilePictures');

                              // create a refernece for the image to be stored
                              Reference referenceImageToUpload =
                                  referenceDirImages.child(currentUser.uid);
                              if (croppedFile != null) {
                                await referenceImageToUpload.putFile(
                                    File(croppedFile.path),
                                    SettableMetadata(
                                        contentType: 'image/jpeg'));
                                String newUploadURL =
                                    await referenceImageToUpload
                                        .getDownloadURL();
                                setState(() {
                                  newImagePath =
                                      referenceImageToUpload.fullPath;
                                  newImageURL = newUploadURL;
                                });
                                setState(() {
                                  imageProvider =
                                      FileImage(File(croppedFile.path));
                                  PaintingBinding.instance.imageCache.clear();
                                });
                              }
                            } catch (e) {
                              if (kDebugMode) {
                                print(
                                    "Something went wrong while uploading your image $e");
                              }
                              if (mounted) {
                                ErrorSnackbar.showErrorSnackbar(context,
                                    "Something went wrong while uploading your image");
                              }
                            }
                          }
                          setState(() {
                            uploading = false;
                          });
                        },
                        child: CircleAvatar(
                          radius: 37.5,
                          backgroundImage: imageProvider ??
                              const AssetImage('assets/Personavatar.png'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  if (uploading) const Center(child: LinearProgressIndicator()),
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
                    onDateSelected: (DateStringTupel dateStringTupel) {
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
                        width: MediaQuery.of(context).size.width * 0.66,
                        child: InputField(
                          readOnly: true,
                          controller:
                              TextEditingController(text: currentUser.uid),
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
                                  Clipboard.setData(
                                      ClipboardData(text: currentUser.uid));
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
                      try {
                        await updateUserData();
                        if (mounted) {
                          widget.isEditProfile == true
                              ? context.go('/profile')
                              : context.go('/setinterests/true');
                        }
                      } catch (e) {
                        if (kDebugMode) {
                          print("Something went wrong $e");
                        }
                        if (mounted) {
                          ErrorSnackbar.showErrorSnackbar(
                              context, e.toString());
                        }
                      }
                    },
                    // The Widget can be used to initalize the profile page or to modify the profile page
                    // when its only modified the user will be redirected to the settings page
                    text: widget.isEditProfile == true
                        ? "Finish"
                        : 'Select your Interests',
                  ),
                ],
              ),
            ),
          ),
        )));
  }
}
