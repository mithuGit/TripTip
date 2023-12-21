import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:internet_praktikum/ui/widgets/headerWidgets/topbar.dart';
import 'package:internet_praktikum/ui/widgets/my_button.dart';
import 'package:internet_praktikum/ui/widgets/profileWidgets/profileButton.dart';

import '../../widgets/profileWidgets/profile_menu.dart';
import '../login_register_pages/login_or_register_page.dart';
//import 'package:modern_login/components/my_button.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  void signUserOut() async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      GoRouter.of(context).go('/loginorregister');
    }
  }

  void deleteUser() async {
    await FirebaseAuth.instance.currentUser!.delete();
    if (context.mounted) {
      GoRouter.of(context).go('/loginorregister');
    }
  }

  final auth = FirebaseAuth.instance;
  final user = FirebaseAuth.instance.currentUser!;
  String imageURL = '';

  final currentUser = FirebaseAuth.instance.currentUser!;
  final userCollection = FirebaseFirestore.instance.collection('users');
  final storage = FirebaseStorage.instance;
  late ImageProvider<Object>? imageProvider;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentUser.photoURL != null
        ? imageProvider = NetworkImage(currentUser.photoURL!)
        : imageProvider = const AssetImage('assets/Personavatar.png');
  }

  @override
  Widget build(BuildContext context) {
    var isDark = MediaQuery.of(context).platformBrightness ==
        Brightness.dark; // check if dark mode is enabled
    // DarkMode Bool noch hinzufügen

    return Scaffold(
      extendBody: true,
      appBar: const TopBar(
        icon: Icons.settings,
        title: "Profile",
        onTapForIconWidget: null,
      ),
      body: Stack(
        children: [
          Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                      'assets/mainpage_pic/profile.png'), // assets/BackgroundCity.png
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                children: <Widget>[
                  GestureDetector(
                    onTap: () async {
                      // Pick image from gallery
                      ImagePicker imagePicker = ImagePicker();
                      XFile? pickedFile = await imagePicker.pickImage(
                          source: ImageSource.gallery);
                      //get reference to storage root
                      Reference referenceRoot = FirebaseStorage.instance.ref();
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
                        imageURL =
                            await referenceImageToUpload.getDownloadURL();
                      } catch (e) {
                        print(e);
                      }
                      setState(() {
                        imageProvider = (pickedFile != null
                                ? FileImage(File(pickedFile.path))
                                : const AssetImage('assets/Personavatar.png'))
                            as ImageProvider<Object>?;
                        currentUser.updatePhotoURL(imageURL);
                      });
                    },
                    child: CircleAvatar(
                      radius: 37.5,
                      backgroundImage: imageProvider,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Text('Welcome ${user.displayName}',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),

                  const SizedBox(height: 20),

                  SizedBox(
                      width: 200,
                      child: ElevatedButton(
                          onPressed: () {
                            context.pushReplacement(
                                "/accountdetails-isEditProfile");
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: isDark
                                  ? Colors.grey[700]
                                  : Colors.grey[
                                      300], // maybe hier eine eindeutige Farbe wählen, wie Lila oder gelb.
                              side: BorderSide.none,
                              shape: const StadiumBorder()),
                          child: const Text('Edit Profile',
                              style: TextStyle(
                                  color: Colors
                                      .black)))), // primary nochmal angucken und verändern

                  const SizedBox(height: 15),
                  const Divider(
                      color: Colors
                          .black), // damit machen wir alles in den Center // color ändern
                  const SizedBox(height: 15),
                  ProfileButton(
                    title: "Information",
                    icon: Icons.info,
                    textcolor: Colors.black,
                    onTap: () => context.pushReplacement("/info"),
                  ),
                  ProfileButton(
                    title: "Billing Details",
                    icon: Icons.wallet,
                    textcolor: Colors.black,
                    onTap: () {},
                  ),
                  ProfileButton(
                    title: "Game: Choose a Loser ",
                    icon: Icons.games, // so Game Icon wär gut
                    textcolor: Colors.purpleAccent,
                    onTap: () {},
                  ),
                  ProfileButton(
                    title: "Logout",
                    icon: Icons.logout,
                    textcolor: Colors.red,
                    onTap: signUserOut,
                  ),
                  ProfileButton(
                    title: "Delete Account",
                    icon: Icons.delete,
                    textcolor: Colors.red,
                    onTap: deleteUser,
                  ),

                  
                ],
              )),
        ],
      ),
    );
  }
}
