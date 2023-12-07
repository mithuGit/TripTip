import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internet_praktikum/ui/widgets/my_button.dart';
import 'package:internet_praktikum/ui/widgets/topbar.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final user = FirebaseAuth.instance.currentUser!;

  void signUserOut() async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      GoRouter.of(context).go('/loginorregister');
    }
  }

  void deleteUser() async {
    await FirebaseAuth.instance.currentUser!.delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.black, size: 30),
              onPressed: () {
                //fetchWeather();
              },
            ),
          ]),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/mainpage_pic/dashboard.png'), // assets/BackgroundCity.png
                fit: BoxFit.fill,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('Welcome ${user.displayName}'),
                  const SizedBox(height: 20),
                  Text('Your email is ${user.email}'),
                  const SizedBox(height: 20),
                  Text('Your uid is ${user.uid}'),
                  const SizedBox(height: 20),
                  Text('Your profile picture is ${user.photoURL}'),
                  //Uri.file(user.photoURL!).isAbsolute
                  //    ? Image.network(user.photoURL!)
                  //    : Image.asset(user.photoURL!),
                  MyButton(
                    onTap: signUserOut,
                    text: "Logout",
                    colors: Colors.red,
                  ),
                  MyButton(
                    onTap: deleteUser,
                    text: "Delete Account",
                    colors: Colors.red,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
