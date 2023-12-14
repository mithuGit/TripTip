import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/profile_menu.dart';
import '../login_register_pages/login_or_register_page.dart';
import '../profile_pages/edit_profile_page.dart';
import '../../widgets/topbar.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({Key? key}) : super(key: key);

  final auth = FirebaseAuth.instance;
  final user = FirebaseAuth.instance.currentUser!;

  signOut(BuildContext context) async {
    await auth.signOut();
    if (context.mounted) {
      GoRouter.of(context).go('/loginorregister');
    }
  }

  deleteUser(BuildContext context) async {
    await FirebaseAuth.instance.currentUser!.delete();
    if (context.mounted) {
      GoRouter.of(context).go('/loginorregister');
    }
  }

  @override
  Widget build(BuildContext context) {
    var isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      appBar: const TopBar(
        icon: Icons.settings,
        isDash: false,
        title: "Profile",
        onTapForIconWidget: null,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/mainpage_pic/profile.png'),
                fit: BoxFit.fill,
              ),
            ),
            child: Column(
              children: [
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Colors.grey[300],
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Welcome ${user.displayName}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Your email is ${user.email}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
                      backgroundColor: isDark ? Colors.grey[700] : Colors.grey[300],
                      side: BorderSide.none,
                      shape: const StadiumBorder(),
                    ),
                    child: const Text('Edit Profile', style: TextStyle(color: Colors.black)),
                  ),
                ),
                const SizedBox(height: 30),
                const Divider(color: Colors.grey),
                const SizedBox(height: 10),
                ProfileMenuWidget(
                  title: "Settings",
                  icon: Icons.settings,
                  textColor: true,
                  onPress: () {},
                  endIcon: true,
                ),
                ProfileMenuWidget(
                  title: "Billing Details",
                  icon: Icons.wallet,
                  textColor: true,
                  onPress: () {},
                  endIcon: true,
                ),
                ProfileMenuWidget(
                  title: "User Management",
                  icon: Icons.verified_user,
                  textColor: true,
                  onPress: () {},
                  endIcon: true,
                ),
                const Divider(color: Colors.grey),
                const SizedBox(height: 10),
                ProfileMenuWidget(
                  title: "Information",
                  icon: Icons.info,
                  textColor: true,
                  onPress: () {},
                  endIcon: true,
                ),
                ProfileMenuWidget(
                  title: "Logout",
                  icon: Icons.logout,
                  textColor: false,
                  onPress: () {
                    signOut(context);
                  },
                  endIcon: false,
                ),
                ProfileMenuWidget(
                  title: "Delete Account",
                  icon: Icons.delete,
                  textColor: false,
                  onPress: () {
                    deleteaccount(context);
                  },
                  endIcon: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

void deleteaccount(BuildContext context) {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController confirmemailController = TextEditingController();

  showModalBottomSheet(
    useRootNavigator: true,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    context: context,
    builder: (BuildContext context) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
            ),
            
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Your email is ${user.email}. Please enter to delete your account',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Your Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: confirmemailController,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (emailController.text == user.email &&
                        confirmemailController.text == user.email) {
                      deleteUser(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Emails do not match'),
                        ),
                      );
                    }
                  },
                  child: const Text('Delete Account'),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
}
