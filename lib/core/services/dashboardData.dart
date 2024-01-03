import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashBoardData {
  static final user = FirebaseAuth.instance.currentUser!;
  static Future<Map<String, dynamic>> getUserData(DateTime selectedDay) async {
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
  static Future<DocumentReference> getCurrentDaySubCollection(
      DateTime selectedDay) async {
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
    final filteredDay = Timestamp.fromDate(DateTime(
        selectedDay.year, selectedDay.month, selectedDay.day, 0, 0, 0));

    QuerySnapshot currentDay = await currentTrip
        .collection("days")
        .where("starttime", isEqualTo: filteredDay)
        .get();
    if (currentDay.docs.isEmpty) {
      // if there is no day yet, create one
      // every Day has a starttime, active and archive
      // the first widget is the diary, wiche is always active and cant be deleted
      DateTime diaryTime = await calculateDiaryTime(selectedDay);
      DocumentReference day = await currentTrip.collection("days").add({
        'starttime': filteredDay,
        'active': {},
        'archive': {},
      });
      DateTime tripStart =
          (await currentTrip.get()).data()!['startdate'].toDate();
      DateTime tripEnd = (await currentTrip.get()).data()!['enddate'].toDate();
      // only within the trip duration a diary widget will be created
      if (selectedDay.isAfter(tripStart) && selectedDay.isBefore(tripEnd)) {
        day.update({
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
          }
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
      }

      return day;
    } else {
      return currentDay.docs.first.reference;
    }
  }

  static Future<DateTime> calculateDiaryTime(DateTime starttime) {
    int randomHour = Random().nextInt(14);
    // since People are not awake at 0:00, we add 8 hours to the randomHour
    // and people shoud go to bed at 22:00, so we substract 2 hours
    randomHour = randomHour + 8;
    int randomMinute = Random().nextInt(61);
    DateTime diaryTime = DateTime(starttime.year, starttime.month,
        starttime.day, randomHour, randomMinute, 0, 0);
    diaryTime = diaryTime.add(
        const Duration(days: 1)); // you have to write the diary on the next day
    return Future.value(diaryTime);
  }
}
