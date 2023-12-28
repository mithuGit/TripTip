import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internet_praktikum/ui/widgets/bottom_sheet.dart';
import 'package:internet_praktikum/ui/widgets/my_button.dart';
import 'package:internet_praktikum/ui/widgets/headerWidgets/topbar.dart';
import 'package:internet_praktikum/ui/widgets/ticketWidgets/createTicketWidget.dart';
import 'package:internet_praktikum/ui/widgets/ticketWidgets/ticketContainer.dart';

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
      appBar: TopBar(
        title: "Tickets",
        icon: Icons.add,
        onTapForIconWidget: () {
          CustomBottomSheet.show(context,
              title: "Add Ticket or Receipt",
              content: [
                Builder(
                  builder: (context) {
                    // hier kommt noch die Schuldenüsetzung und Beleg hinzufügen über Galerie oder Fotoupload
                    return const CreateTicketsWidget();
                  },
                ),
              ]);
        },
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
            child: SingleChildScrollView(
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
                    const TicketContainer(title: "Test1"),
                    const TicketContainer(title: "Test2"),
                    const TicketContainer(title: "Test3"),
                    const TicketContainer(title: "Test4"),
                    const TicketContainer(title: "Test5"),
                    const TicketContainer(title: "Ticket from Deutsche Bahn"),
                    const TicketContainer(title: "Ticket from Deutsche Bahn"),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
