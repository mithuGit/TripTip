import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/views/login_register_pages/login_or_register_page.dart';
import 'package:internet_praktikum/ui/widgets/my_button.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final user = FirebaseAuth.instance.currentUser!;

  void signUserOut() async{
    await FirebaseAuth.instance.signOut();
  }

  void deleteUser() async {
    await FirebaseAuth.instance.currentUser!.delete();
  } 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [
        IconButton(onPressed: signUserOut, icon: const Icon(Icons.logout))
      ]),
      body: Center(
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
            const SizedBox(height: 20),
            Text('Your profile picture is ${user.photoURL}'),
            MyButton(
              onTap: signUserOut, 
              text: "Logout",
              colors: Colors.red,),
            MyButton(
              onTap: deleteUser, 
              text: "Delete Account",
              colors: Colors.red,),
          ],
        ),
      ),
    );
  }
}
