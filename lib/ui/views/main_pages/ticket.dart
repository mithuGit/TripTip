import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internet_praktikum/ui/widgets/my_button.dart';
import 'package:internet_praktikum/ui/widgets/header/topbar.dart';

class Ticket extends StatefulWidget {
  const Ticket({super.key});

  @override
  State<Ticket> createState() => _TicketState();
}

class _TicketState extends State<Ticket> {
  final user = FirebaseAuth.instance.currentUser!;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: const TopBar(
          isDash: false,
          title: "Tickets",
          icon: Icons.add,
          onTapForIconWidget: null,
        ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/mainpage_pic/ticket.png'), // assets/BackgroundCity.png
                fit: BoxFit.cover,
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
