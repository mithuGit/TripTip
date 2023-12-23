import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/widgets/bottom_sheet.dart';

class TicketContainer extends StatefulWidget {
  const TicketContainer({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  State<TicketContainer> createState() => _TicketContainerState();
}

class _TicketContainerState extends State<TicketContainer> {
  User? currentUser;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        currentUser = user;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(left: 20, right: 20, top: 10.0, bottom: 10.0),
      child: GestureDetector(
        onTap: () {
          setState(() => CustomBottomSheet.show(context,
                  title: widget.title,
                  content: [
                    Builder(
                      builder: (context) {
                        return const Center(
                            // hier Modal für Preview des Belegs
                            );
                      },
                    ),
                  ]));
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: 66.0,
          decoration: BoxDecoration(
            color: const Color(0xE51E1E1E),
            border: Border.all(color: const Color(0xE51E1E1E)),
            borderRadius: BorderRadius.circular(34.5),
          ),
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 17.0, left: 25, right: 25, bottom: 15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const ImageIcon(
                            AssetImage('assets/docs.png'),
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
