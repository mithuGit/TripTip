import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internet_praktikum/ui/widgets/inputfield.dart';
import 'package:internet_praktikum/ui/widgets/widgetContainer.dart';

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
              child: ListView(children: const[
                 Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        left: 18,
                        right: 18,
                      ),
                      child:
                          WidgetContainer(
                            isSurvey: true,
                            title: "Voting for Food", 
                            children: [
                        InputField(
                          hintText: 'Burger',
                          obscureText: false,
                        ),
                        InputField(
                          hintText: 'Pizza',
                          obscureText: false,
                        ),
                      ]),
                    ),
                    SizedBox(height: 10,),
                    Padding(
                      padding: EdgeInsets.only(
                        left: 18,
                        right: 18,
                      ),
                      child: WidgetContainer(
                        isSurvey: false,
                        time: TimeOfDay(hour: 18, minute: 0),
                        description: "We eat at 18:00",
                        title: "Go to Restaurant",
                        icon: Icons.group,
                      ),
                    ),
                    SizedBox(height: 10,),
                    Padding(
                      padding: EdgeInsets.only(
                        left: 18,
                        right: 18,
                      ),
                      child: WidgetContainer(
                        isSurvey: false,
                        time: TimeOfDay(hour: 7, minute: 3),
                        description: "We eat at 18:00 in the Restaurant near the University",
                        title: "Go to Restaurant",
                        icon: Icons.map_outlined,
                      ),
                    ),
                    SizedBox(height: 10,),
                    Padding(
                      padding: EdgeInsets.only(
                        left: 18,
                        right: 18,
                      ),
                      child: WidgetContainer(
                        isSurvey: false,
                        title: "Go to Restaurant",
                        icon: Icons.group,
                      ),
                    )
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
