import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:internet_praktikum/ui/widgets/headerWidgets/topbar.dart';
import 'package:internet_praktikum/ui/widgets/profileWidgets/profileButton.dart';

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
    return Scaffold(
      extendBody: true,
      appBar: const TopBar(
        icon: null,
        title: "Profile",
        onTapForIconWidget: null,
      ),
      body: Stack(
        children: [
          Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                      'assets/background_forest.png'), // assets/BackgroundCity.png
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
                              backgroundColor: Colors.grey[300],
                              side: BorderSide.none,
                              shape: const StadiumBorder()),
                          child: const Text('Edit Profile',
                              style: TextStyle(color: Colors.black)))),
                  const SizedBox(height: 25),
                  const Divider(
                    color: Colors.black,
                  ),
                  const SizedBox(height: 25),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 14, right: 14, bottom: 45),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 43, 43, 43)
                              .withOpacity(0.90),
                          borderRadius: BorderRadius.circular(34.5),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(22),
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                ProfileButton(
                                  title: "Information",
                                  icon: Icons.info,
                                  textcolor: Colors.white,
                                  onTap: () => context.go("/info"),
                                ),
                                ProfileButton(
                                  title: "Billing Details",
                                  icon: Icons.wallet,
                                  textcolor: Colors.white,
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
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }
}
