import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internet_praktikum/ui/widgets/headerWidgets/topbar.dart';
import 'package:internet_praktikum/ui/widgets/my_button.dart';

import '../../widgets/profile_menu.dart';
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
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.grey[300], // genauere Farbe wählen
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  Text('Welcome ${user.displayName}',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),

                  Text('Your email is ${user.email}',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),

                  const SizedBox(height: 20),

                  SizedBox(
                      width: 200,
                      child: ElevatedButton(
                          onPressed: () {
                            /*Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Account(isEditProfile: true,),
                              ),
                            );*/
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

                  const SizedBox(height: 30),
                  const Divider(
                      color: Colors
                          .grey), // damit machen wir alles in den Center // color ändern
                  const SizedBox(height: 10),

                  ProfileMenuWidget(
                      title: "Billing Details",
                      icon: Icons.wallet,
                      textColor: true,
                      onPress: () {}),
                  ProfileMenuWidget(
                    title: "Information",
                    icon: Icons.info,
                    textColor: true,
                    onPress: () {},
                  ),
                  ProfileMenuWidget(
                    title: "Logout",
                    icon: Icons.logout,
                    textColor: false,
                    onPress: () {
                      signUserOut();
                    },
                  ),
                  ProfileMenuWidget(
                    title: "Delete",
                    icon: Icons.delete,
                    textColor: false,
                    onPress: () {
                      deleteUser();
                    },
                  ),
                ],
              )),
        ],
      ),
    );
  }
}
