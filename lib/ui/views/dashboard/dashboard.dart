import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
  Future<DocumentReference> getCurrentDaySubCollection() async {
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
        FirebaseFirestore.instance.collection('trips').doc(tripId);
    // issue: that the day doesnt starts at 0:00, thats why we need to filter the day
    final filteredDay = Timestamp.fromDate(
        DateTime(selectedDay!.year, selectedDay!.month, selectedDay!.day));

    QuerySnapshot currentDay = await currentTrip
        .collection("days")
        .where("starttime", isEqualTo: filteredDay)
        .get();
    if (currentDay.docs.isEmpty) {
      // if there is no day yet, create one
      // every Day has a starttime, active and archive
      // the first widget is the diary, wiche is always active and cant be deleted
      DateTime diaryTime = await calculateDiaryTime(selectedDay!);
      DocumentReference day = await currentTrip.collection("days").add({
        'starttime': filteredDay,
        'active': {
          'diary': {
            'key': 'diary',
            'index': 0,
            'title': 'Your daily Diary',
            'dontEdit': true,
            'dontDelete': true,
            'diaryStartTime': diaryTime,
            'diaryEndTime': diaryTime.add(const Duration(hours: 2)),
            'type': 'diary',
            'due': 'Diary',
          },
        },
        'archive': {},
      });
      await FirebaseFirestore.instance.collection("tasks").add({
        'performAt': diaryTime,
        'status': 'pending',
        'worker': 'WriteDiaryNotification',
        'options': {
          'day': day,
          'trip': currentTrip,
        },
      });

      return day;
    } else {
      return currentDay.docs.first.reference;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(
          isDash: true,
          popupButton: PopupMenuButton(
            icon: const Icon(Icons.menu_rounded),
            onSelected: (value) => {
              switch(value) {
                "changeTrip" => {context.goNamed("changeTrip")},
                "createWidget" => {
                  CustomBottomSheet.show(context,
                title: "Add new Widget to your Dashboard",
                content: [
                  FutureBuilder(
                      future: Future.wait([
                        getUserData(),
                        getCurrentDaySubCollection(),
                      ]),
                      builder:
                          (context, AsyncSnapshot<List<dynamic>> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
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
                            day: snapshot.data![1],
                            userdata: snapshot.data![0]);
                      })
                ])
                },
                _ => (),
              }
            },
            itemBuilder: (BuildContext c) {
              return const [
                PopupMenuItem(value: "changeTrip", child: Text("Change Trip"),),
                PopupMenuItem(value: "createWidget", child: Text("Create Widget"), )];
            },
          )),

      body: Stack(
        children: [
          Container( 
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/background_forest.png'), // assets/BackgroundCity.png
                fit: BoxFit.fitWidth,
              ),
            ),
            child: Column(children: [
              Calendar(onDateSelected: (date) {
                setState(() {
                  selectedDay = date;
                });
              }),
              FutureBuilder(
                  future: Future.wait([
                    getUserData(),
                    getCurrentDaySubCollection(),
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
                        child: Text(
                            'An error occured while fetching data! check your internet connection!'),
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

Future<DateTime> calculateDiaryTime(DateTime starttime) {
  int randomHour = Random().nextInt(14);
  // since People are not awake at 0:00, we add 8 hours to the randomHour
  // and people shoud go to bed at 22:00, so we substract 2 hours
  randomHour = randomHour + 8;
  int randomMinute = Random().nextInt(61);
  DateTime diaryTime = DateTime(starttime.year, starttime.month, starttime.day,
      randomHour, randomMinute, 0, 0);
  return Future.value(diaryTime);
}
