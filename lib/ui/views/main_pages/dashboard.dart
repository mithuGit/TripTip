import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/calendar.dart';
import 'package:internet_praktikum/ui/widgets/bottom_sheet.dart';
import 'package:internet_praktikum/ui/views/dashboard/scrollview.dart';
import 'package:internet_praktikum/ui/widgets/dashboardWidgets/createNewWidgetOnDashboard.dart';
import 'package:internet_praktikum/ui/widgets/headerWidgets/topbar.dart';

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
  Future<Map<String, dynamic>> getUserData() async {
    print("getUserData");
    final userCollection = FirebaseFirestore.instance.collection('users');
    print('DateTime: $selectedDay');
    final userDoc = await userCollection.doc(user.uid).get();
    Map<String, dynamic> _userData = userDoc.data() as Map<String, dynamic>;
    if (_userData['selectedtrip'] == null) throw Exception('No trip selected');

    final tripId = _userData['selectedtrip'];
    try {
      await FirebaseFirestore.instance.collection('trips').doc(tripId).get();
    } catch (e) {
      print('Trip does not exist anymore');
      await userCollection.doc(user.uid).update({'selectedtrip': null});
      throw Exception('Trip does not exist anymore');
    }

    final currentTrip =
        await FirebaseFirestore.instance.collection('trips').doc(tripId).get();
    Map<String, dynamic> currentTripdata = currentTrip.data()!;
    _userData['numberofusers'] = currentTripdata['members'].length;
    return _userData;
  }

  // A function that returns the current day for the Widget list and also saves it in the currentDay variable for later use
  Future<DocumentReference> getCurrentDay() async {
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
    if (currentTripdata!['days'] == null) {
      print('The Days Parameter in the Document is null');
      DocumentReference day =
          await FirebaseFirestore.instance.collection('days').add({
        'starttime': Timestamp.fromDate(selectedDay!),
        'active': {},
        'archive': {},
      });
      await FirebaseFirestore.instance.collection('trips').doc(tripId).update({
        'days': FieldValue.arrayUnion([
          {'starttime': Timestamp.fromDate(selectedDay!), 'ref': day}
        ])
      });
      return day;
    }
    List<dynamic> days = currentTripdata['days'].toList();
    Iterable<dynamic> filtered = days.where((el) =>
        (el['starttime'] as Timestamp).toDate().day == selectedDay!.day &&
        (el['starttime'] as Timestamp).toDate().month == selectedDay!.month &&
        (el['starttime'] as Timestamp).toDate().year == selectedDay!.year);
    if (filtered.isEmpty) {
      print('No day found');
      DocumentReference day =
          await FirebaseFirestore.instance.collection('days').add({
        'starttime': Timestamp.fromDate(selectedDay!),
        'active': {},
        'archive': {},
      });
      await FirebaseFirestore.instance.collection('trips').doc(tripId).update({
        'days': FieldValue.arrayUnion([
          {'starttime': Timestamp.fromDate(selectedDay!), 'ref': day}
        ])
      });
      return day;
    }
    Map<String, dynamic>? day = filtered.first;
    currentDay = day!['ref'];
    return currentDay!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(
          isDash: true,
          icon: Icons.menu_rounded,
          onTapForIconWidget: () {
            // Hier muss Bürge Menü rein und in diesem Menü soll das was unten steht über ein Add Widget Button aufgerufen werden
            CustomBottomSheet.show(context,
                title: "Add new Widget to your Dashboard",
                content: [
                  FutureBuilder(
                  future: Future.wait([
                    getUserData(),
                    getCurrentDay(),
                  ]),
                  builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text('An error occured!'),
                      );
                    }
                    return CreateNewWidgetOnDashboard(
                        day: snapshot.data![1], userdata: snapshot.data![0]);
                  }) 
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
            child: Column(children: [
              Calendar(onDateSelected: (date) {
                print("onDateSelected");
                setState(() {
                  selectedDay = date;
                });
              }),
              FutureBuilder(
                  future: Future.wait([
                    getUserData(),
                    getCurrentDay(),
                  ]),
                  builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (snapshot.hasError) {
                      print(snapshot.error);
                      return const Center(
                        child: Text('An error occured!'),
                      );
                    }
                    return ScrollViewWidget(
                        day: snapshot.data![1], userdata: snapshot.data![0]);
                  })
            ]),
          ),
        ],
      ),
    );
  }
}
