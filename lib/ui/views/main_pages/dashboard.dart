import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/widgets/bottom_sheet.dart';
import 'package:internet_praktikum/ui/views/dashboard/scrollview.dart';
import 'package:internet_praktikum/ui/widgets/dashboardWidgets/createNewWidgetOnDashboard.dart';
import 'package:internet_praktikum/ui/widgets/header/topbar.dart';
import 'package:provider/provider.dart';

class ProviderUserdata {
  Map<String, dynamic> userdata = {};
  ProviderUserdata(this.userdata);
}

class ProviderDay {
  DocumentReference day;
  ProviderDay(this.day);
}

class DashBoard extends StatefulWidget {
  const DashBoard({super.key});
  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  final user = FirebaseAuth.instance.currentUser!;
  DateTime? selectedDay = DateTime(2023, 10, 1);
  bool showSomething = false;
  DocumentReference? currentDay;

  // A function that automatecly loads the data from the user and fetches the profilepicture
  Future<ProviderUserdata> getUserData() async {
    print("getUserData");
    final userCollection = FirebaseFirestore.instance.collection('users');
    final userDoc = await userCollection.doc(user.uid).get();
    Map<String, dynamic> _userData = userDoc.data()!;
    return ProviderUserdata(_userData);
  }

  // A function that returns the current day for the Widget list and also saves it in the currentDay variable for later use
  Future<ProviderDay> getCurrentDay() async {
    if (currentDay != null) return ProviderDay(currentDay!);
    print('DateTime: $selectedDay');
    final userCollection = FirebaseFirestore.instance.collection('users');
    final userDoc = await userCollection.doc(user.uid).get();
    if (userDoc.data()?['selectedtrip'] == null)
      throw Exception('No trip selected');

    final tripId = userDoc.data()?['selectedtrip'];
    try {
      await FirebaseFirestore.instance.collection('trips').doc(tripId).get();
    } catch (e) {
      print('Trip does not exist anymore');
      await userCollection.doc(user.uid).update({'selectedtrip': null});
      throw Exception('Trip does not exist anymore');
    }

    final currentTrip =
        await FirebaseFirestore.instance.collection('trips').doc(tripId).get();
    Map<String, dynamic>? currentTripdata = currentTrip.data();
    List<dynamic> days = currentTripdata?['days'].toList();
    Map<String, dynamic> day = days
        .where((el) =>
            (el['starttime'] as Timestamp).toDate().day == selectedDay!.day &&
            (el['starttime'] as Timestamp).toDate().month ==
                selectedDay!.month &&
            (el['starttime'] as Timestamp).toDate().year == selectedDay!.year)
        .first;
    currentDay = day['ref'];
    return ProviderDay(currentDay!);
  }

  late String prename; // Variable für den Vornamen

  @override
  void initState() {
    super.initState();
    // Bei der Initialisierung den Vornamen aus der Datenbank laden
    //loadPrename();
  }

  // Dafür benötigen wir ein Future, da die Datenbank-Abfrage asynchron ist
  void loadPrename() async {
    try {
      // Benutzer-ID (uid) aus dem aktuellen Benutzer abrufen
      final String uid = FirebaseAuth.instance.currentUser!.uid;

      // Den Vornamen aus der Firestore-Datenbank laden
      final String prenameResult = await getPrename(uid);

      // Wenn die Komponente noch im Widget-Baum ist, das State aktualisieren
      if (context.mounted) {
        setState(() {
          prename = prenameResult;
        });
      }
    } catch (error) {
      print("Fehler beim Laden des Vornamens: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(
          isDash: true,
          icon: Icons.add,
          onTapForIconWidget: () {
            CustomBottomSheet.show(context,
                title: "Add new Widget to your Dashboard",
                content: [
                  MultiProvider(
                      providers: [
                        FutureProvider(
                          create: (context) => getUserData(),
                          initialData: null,
                        ),
                        FutureProvider(
                          create: (context) => getCurrentDay(),
                          initialData: null,
                        ),
                      ],
                      child:
                          CreateNewWidgetOnDashboard()) // get the secound element of list since the first is the Userdata
                ]);
          }),
      body: Stack(
        children: [
          Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                      'assets/mainpage_pic/dashboard.png'), // assets/BackgroundCity.png
                  fit: BoxFit.cover,
                ),
              ),
              child: MultiProvider(providers: [
                FutureProvider(
                  create: (context) => getUserData(),
                  initialData: null,
                ),
                FutureProvider(
                  create: (context) => getCurrentDay(),
                  initialData: null,
                ),
              ], child: Center(child: Center(child: ScrollViewWidget())))),
        ],
      ),
    );
  }
}

Future<String> getPrename(String uid) async {
  final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();
  final String prename = documentSnapshot.data()!['prename'].toString();
  print(prename);
  return prename;
}
