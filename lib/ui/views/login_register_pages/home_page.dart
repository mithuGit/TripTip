import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/widgets/my_button.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});
  final auth = FirebaseAuth.instance;

  void signUserOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted)  {
      GoRouter.of(context).go('/loginorregister');
    }  
  }

  void deleteUser() async {
    await FirebaseAuth.instance.currentUser!.delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [
        IconButton(
            onPressed: (() => signUserOut(context)),
            icon: const Icon(Icons.logout))
      ]),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
                        Text('Welcome ${auth.currentUser!.displayName}'),
            Text('Welcome ${auth.currentUser != null ? auth.currentUser!.displayName : "-"}'),
            const SizedBox(height: 20),
            Text('Your email is ${auth.currentUser != null ? auth.currentUser!.email : "-"}'),
            MyButton(
              onTap: (() => signUserOut(context)),
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
    );
  }
}
