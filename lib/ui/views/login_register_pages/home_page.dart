import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/widgets/my_button.dart';
import 'package:internet_praktikum/ui/widgets/topbar.dart';
import 'package:internet_praktikum/ui/views/dashboard/scrollview.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;
  //Todo: wir brauchen von euch Hunden den selected Day... dann können wir die Datenbank abfragen und die Daten anzeigen
  DateTime? selectedDay = DateTime(2023, 10, 1);
  void signUserOut() async {
    await FirebaseAuth.instance.signOut();
  }

  void deleteUser() async {
    await FirebaseAuth.instance.currentUser!.delete();
  }

  Future<DocumentReference> getCurrentDay() async {
    print('DateTime: $selectedDay');
    final userCollection = FirebaseFirestore.instance.collection('users');
    final userDoc = await userCollection.doc(user.uid).get();
    final tripId = userDoc.data()?['selectedtrip'];
    final currentTrip =
        await FirebaseFirestore.instance.collection('trips').doc(tripId).get();
    Map<String, dynamic>? currentTripdata = currentTrip.data();

    List<dynamic> days = currentTripdata?['days'].toList();
    print((days[0]['starttime'] as Timestamp).toDate());
    Map<String, dynamic> day = days
        .where((el) =>
            (el['starttime'] as Timestamp).toDate().day == selectedDay!.day &&
            (el['starttime'] as Timestamp).toDate().month ==
                selectedDay!.month &&
            (el['starttime'] as Timestamp).toDate().year == selectedDay!.year)
        .first;

    print(day.toString());
    return day['ref'];
  }

  /*void _onItemTapped(int index) {
    setState(() {
      this.index = index;
    });
  }*/
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBody: true,
        appBar: const TopBar(
          isDash: true,
          icon: Icons.add,
          onTapForIconWidget: null,
        ),
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
                    child: FutureBuilder<DocumentReference>(
                        future: getCurrentDay(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator(); // Show loading indicator while waiting for the Future
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            return ScrollViewWidget(day: snapshot.data!);
                          }
                        }))) //ScrollView
          ],
        ),
        bottomNavigationBar: NavigationBarTheme(
            data: const NavigationBarThemeData(
              labelTextStyle: MaterialStatePropertyAll(
                  TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ),
            child: NavigationBar(
              surfaceTintColor: Colors.transparent,
              indicatorColor: Colors.transparent,
              height: 65,
              backgroundColor:
                  Colors.transparent, // const Color.fromARGB(255, 83, 211, 96),
              labelBehavior: NavigationDestinationLabelBehavior
                  .alwaysHide, //=> damit geht Text unter Icon weg
              animationDuration: const Duration(milliseconds: 200),
              selectedIndex: index,
              // onDestinationSelected:_onItemTapped,
              destinations: const [
                NavigationDestination(
                  icon: ImageIcon(
                    AssetImage('assets/navbar_pic/home.256x229.png'),
                    color: Colors.white,
                    size: 35,
                  ),
                  label: "Dashboard",
                  selectedIcon: ImageIcon(
                    AssetImage('assets/navbar_pic/home.256x229.png'),
                    color: Colors.black,
                    size: 35,
                  ),
                ),
                NavigationDestination(
                  icon: ImageIcon(
                    AssetImage('assets/navbar_pic/wallet.256x235.png'),
                    color: Colors.white,
                    size: 35,
                  ),
                  label: "Payment",
                  selectedIcon: ImageIcon(
                    AssetImage('assets/navbar_pic/wallet.256x235.png'),
                    color: Colors.black,
                    size: 35,
                  ),
                ),
                NavigationDestination(
                  icon: ImageIcon(
                    AssetImage('assets/navbar_pic/map.256x256.png'),
                    color: Colors.white,
                    size: 35,
                  ),
                  label: "Map",
                  selectedIcon: ImageIcon(
                    AssetImage('assets/navbar_pic/map.256x256.png'),
                    color: Colors.black,
                    size: 35,
                  ),
                ),
                NavigationDestination(
                  icon: ImageIcon(
                    AssetImage('assets/navbar_pic/train.197x256.png'),
                    color: Colors.white,
                    size: 35,
                  ),
                  label: "Tickets",
                  selectedIcon: ImageIcon(
                    AssetImage('assets/navbar_pic/train.197x256.png'),
                    color: Colors.black,
                    size: 35,
                  ),
                ),
                NavigationDestination(
                  icon: ImageIcon(
                    AssetImage('assets/navbar_pic/user.226x256.png'),
                    color: Colors.white,
                    size: 35,
                  ),
                  label: "Profile",
                  selectedIcon: ImageIcon(
                    AssetImage('assets/navbar_pic/user.226x256.png'),
                    color: Colors.black,
                    size: 35,
                  ),
                ),
              ],
            )));
  }
}
