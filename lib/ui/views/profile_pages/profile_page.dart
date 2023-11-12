import 'package:flutter/material.dart';
//import 'package:modern_login/components/my_button.dart';
import 'package:modern_login/components/profile_menu.dart';
import 'package:modern_login/login_register_pages/login_or_register_page.dart';
import 'package:modern_login/profile_pages/edit_profile_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var isDark = MediaQuery.of(context).platformBrightness ==
        Brightness.dark; // check if dark mode is enabled
    // DarkMode Bool noch hinzufügen

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.dark_mode),
          ),
        ],
      ),
      body: SingleChildScrollView(
          child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Stack(
                    children: [
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: const Image(
                                image: AssetImage(
                                    '/Users/mithu/Projects/Apps/modern_login/lib/images/google-logo.png'))),
                      ),
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
                      )
                    ],
                  ),
                  const SizedBox(height: 10),

                  const Text('Username',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

                  const Text('Email',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

                  const SizedBox(height: 20),

                  SizedBox(
                      width: 200,
                      child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EditProfilePage(),
                              ),
                            );
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
                      title: "Settings",
                      icon: Icons.settings,
                      textColor: true,
                      onPress: () {},
                      endIcon: true),
                  ProfileMenuWidget(
                      title: "Billing Details",
                      icon: Icons.wallet,
                      textColor: true,
                      onPress: () {},
                      endIcon: true),
                  ProfileMenuWidget(
                      title: "User Managment",
                      icon: Icons.verified_user,
                      textColor: true,
                      onPress: () {},
                      endIcon: true),

                  const Divider(
                      color: Colors
                          .grey), // damit machen wir alles in den Center // color ändern
                  const SizedBox(height: 10),

                  ProfileMenuWidget(
                      title: "Information",
                      icon: Icons.info,
                      textColor: true,
                      onPress: () {},
                      endIcon: true),
                  ProfileMenuWidget(
                      title: "Logout",
                      icon: Icons.logout,
                      textColor: false,
                      onPress: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginOrRegisterPage(),
                              ),
                            );
                          },
                      endIcon: false),
                ],
              )
        )
      ),
    );
  }
}
