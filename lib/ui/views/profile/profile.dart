import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:internet_praktikum/core/services/init_pushnotifications.dart';
import 'package:internet_praktikum/ui/widgets/headerWidgets/topbar.dart';
import 'package:internet_praktikum/ui/widgets/profileWidgets/profileButton.dart';
import 'package:permission_handler/permission_handler.dart';

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

  XFile? pickedFile;

  void updateProfilepicture(String image) async {
    await userCollection.doc(currentUser.uid).update({
      'profilepicture': image,
    });
  }

  @override
  void initState() {
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
        title: "Profile",
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
                children: [
                  GestureDetector(
                    onTap: () async {
                      // Pick image from gallery
                      ImagePicker imagePicker = ImagePicker();
                      pickedFile = await imagePicker.pickImage(
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
                              .putFile(File(pickedFile!.path));
                        }
                        imageURL =
                            await referenceImageToUpload.getDownloadURL();
                      } catch (e) {
                        if (kDebugMode) {
                          print(e);
                        }
                      }
                      setState(() {
                        imageProvider = ((pickedFile != null
                                ? FileImage(File(pickedFile!.path))
                                : const AssetImage('assets/Personavatar.png'))
                            as ImageProvider<Object>?)!;
                      });
                      updateProfilepicture(imageURL);
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
                  const SizedBox(height: 15),
                  SizedBox(
                      width: 200,
                      child: ElevatedButton(
                          onPressed: () {
                            context.pushReplacement("/accountdetails/true");
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[300],
                              side: BorderSide.none,
                              shape: const StadiumBorder()),
                          child: const Text('Edit Profile',
                              style: TextStyle(color: Colors.black)))),
                  const SizedBox(height: 15),
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
                                FutureBuilder(
                                    future: PushNotificationService()
                                        .checkIfNotificationIsEnabled(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }
                                      if (snapshot.hasError) {
                                        return const Center(
                                          child: Text('An error occured!'),
                                        );
                                      }
                                      return ProfileButton(
                                        title: snapshot.data!
                                            ? "Disable PushNotifications"
                                            : "Enable PushNotifications",
                                        icon: Icons.notifications,
                                        textcolor: Colors.white,
                                        onTap: () async {
                                          if (snapshot.data!) {
                                            await PushNotificationService()
                                                .disable();
                                          } else {
                                            var status = await Permission
                                                .notification.status;
                                            if (status.isDenied ||
                                                status.isPermanentlyDenied) {
                                              await _openSettings();
                                            } else {
                                              await PushNotificationService()
                                                  .initialise();
                                            }
                                          }
                                          setState(() {});
                                        },
                                      );
                                    }),
                                ProfileButton(
                                  title: "Your Interests",
                                  icon: Icons.stars,
                                  textcolor: Colors.white,
                                  onTap: () =>
                                      context.go('/setinterests/false'),
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

  // Ask if user wants to open settings to enalbe push notifications
  Future<void> _openSettings() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Urgent Actions required!'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Push Notifications are disabled!'),
                Text(
                    'To Enable them, please go to Settings, and allow them! and reopen app after enabling them!'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Open Android Settings'),
              onPressed: () {
                openAppSettings();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('not now'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
