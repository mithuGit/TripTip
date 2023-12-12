import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internet_praktikum/ui/widgets/bottom_sheet.dart';
import 'package:internet_praktikum/ui/views/dashboard/scrollview.dart';
import 'package:internet_praktikum/ui/views/navigation/app_navigation.dart';
import 'package:internet_praktikum/ui/widgets/dashboardWidgets/createNewWidgetOnDashboard.dart';
import 'package:internet_praktikum/ui/widgets/my_button.dart';
import 'package:internet_praktikum/ui/widgets/topbar.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({super.key});

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  final user = FirebaseAuth.instance.currentUser!;
  DateTime? selectedDay = DateTime(2023, 10, 1);
  bool showSomething = false;

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

  Future<DocumentReference> getCurrentDay() async {
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

    return day['ref'];
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
                  FutureBuilder<DocumentReference>(
                          future: getCurrentDay(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator(); // Show loading indicator while waiting for the Future
                            } else if (snapshot.hasError) {
                              return Text(
                                  'Resolve Data Error: ${snapshot.error}');
                            } else {
                              return CreateNewWidgetOnDashboard(day: snapshot.data!);
                            }
                          }),
                ]);
          }),
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
                  child: Center(
                      child: FutureBuilder<DocumentReference>(
                          future: getCurrentDay(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator(); // Show loading indicator while waiting for the Future
                            } else if (snapshot.hasError) {
                              return Text(
                                  'Resolve Data Error: ${snapshot.error}');
                            } else {
                              return ScrollViewWidget(day: snapshot.data!);
                            }
                          })))),
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
