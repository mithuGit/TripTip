import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internet_praktikum/ui/widgets/dashboardWidgets/appointment.dart';
import 'package:internet_praktikum/ui/widgets/dashboardWidgets/survey.dart';
import 'package:internet_praktikum/ui/widgets/dashboardWidgets/voting_poll.dart';
import 'package:internet_praktikum/ui/widgets/dashboardWidgets/widgetContainer.dart';

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
      appBar: AppBar(backgroundColor: Colors.transparent, actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.black, size: 30),
          onPressed: () {
            //search in map
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
              child: ListView(children: const [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    /*SurveyWidget( children: [
                      VotingPoll(title: "Pizza"),
                      VotingPoll(title: "Burger"),
                      VotingPoll(title: "Pasta"),
                    ]),
                    SizedBox(
                      height: 10,
                    ),
                    Appointment(
                        icon: Icons.group,
                        description: "We eat at 18:00",
                        time: TimeOfDay(hour: 18, minute: 0)),
                    SizedBox(
                      height: 10,
                    ),
                    Appointment(
                        icon: Icons.map_outlined,
                        description:
                            "We eat at 18:00 in the Restaurant near the University",
                        time: TimeOfDay(hour: 7, minute: 3)),
                    SizedBox(
                      height: 10,
                    ),
                    Appointment(
                      icon: Icons.map_outlined,
                      time: TimeOfDay(hour: 12, minute: 32),
                    ),*/
                  ],
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
