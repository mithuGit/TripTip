import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/calendar.dart';
import 'package:internet_praktikum/ui/widgets/bottom_sheet.dart';
import 'package:internet_praktikum/ui/views/dashboard/scrollview.dart';
import 'package:internet_praktikum/ui/widgets/dashboardWidgets/createNewWidgetOnDashboard.dart';
import 'package:internet_praktikum/ui/widgets/header/topbar.dart';
import 'package:provider/provider.dart';

class ProviderUserdata extends ChangeNotifier {
  Map<String, dynamic> _userdata = {};
  get userdata => _userdata;
  ProviderUserdata({Map<String, dynamic>? userdata});
  void changeUserdata(Map<String, dynamic> newUserData) {
    _userdata = newUserData;
    notifyListeners();
  }
}

class ProviderDay extends ChangeNotifier {
  DocumentReference? day;
  ProviderDay({this.day});
  void changeDay(DocumentReference newDay) {
    day = newDay;
    notifyListeners();
  }
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

  ProviderDay providerDay = ProviderDay();
  ProviderUserdata providerUserdata = ProviderUserdata();

  // A function that automatecly loads the data from the user and fetches the profilepicture
  Future<Map<String, dynamic>> getUserData() async {
    print("getUserData");
    final userCollection = FirebaseFirestore.instance.collection('users');
    final userDoc =
        await userCollection.where('uid', isEqualTo: user.uid).get();
    Map<String, dynamic> _userData = userDoc.docs.first.data();
    return _userData;
  }

  @override
  void initState() {
    super.initState();
    getUserData().then((value) {
      providerUserdata.changeUserdata(value);
    });
  }

  // A function that returns the current day for the Widget list and also saves it in the currentDay variable for later use
  Future<DocumentReference> getCurrentDay() async {
    //if (currentDay != null) return ProviderDay(currentDay!);
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
    // TODO wenn kein Tag gefunden wird, dann einen neuen Tag erstellen... Dies muss bei leeren Colection sirgendwann aufgeräumt werden.
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
                  Builder(builder: (context) {
                    if (providerDay.day != null &&
                        providerUserdata.userdata != null) {
                      return CreateNewWidgetOnDashboard(
                          day: providerDay.day!,
                          userdata: providerUserdata.userdata);
                    } else {
                      return const Text("no userdata and no day data");
                    }
                  }), // get the secound element of list since the first is the Userdata
                ]);
          }),
      body: Stack(
        children: [
          MultiProvider(
            providers: [
              FutureProvider(
                create: (context) => getUserData(),
                initialData: null,
              ),
            ],
            child: Container(
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
                  selectedDay = date;
                  getCurrentDay().then((value) =>
                      {providerDay.changeDay(value), setState(() {})});
                }),
                Builder(builder: (context) {
                  if (providerDay.day != null &&
                      providerUserdata.userdata != null) {
                    return ScrollViewWidget(
                        day: providerDay.day!,
                        userdata: providerUserdata.userdata);
                  } else {
                    return const Text("no userdata and no day data");
                  }
                })
              ]),
            ),
          )
        ],
      ),
    );
  }
}
