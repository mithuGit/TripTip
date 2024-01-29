// ignore: file_names
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserIsNotInTripException implements Exception {
  String errMsg() => 'User is not in a trip';
}
class UserHasNoSelectedTripException implements Exception {
  String errMsg() => 'User has no selected trip';
}
class DashBoardData {
  static final user = FirebaseAuth.instance.currentUser!;

  static Future<DocumentReference> getCurrentTrip() async {
    final userCollection = FirebaseFirestore.instance.collection('users');
    final userDoc = await userCollection.doc(user.uid).get();
    if (userDoc.data()?['selectedtrip'] == null)
      throw Exception('No trip selected');

    final tripId = userDoc.data()?['selectedtrip'];
    final currentTrip =
        FirebaseFirestore.instance.collection('trips').doc(tripId);
    return currentTrip;
  }

  static Future<Map<String, dynamic>> getUserData() async {
    final userCollection = FirebaseFirestore.instance.collection('users');
    final userDoc = await userCollection.doc(user.uid).get();
    Map<String, dynamic> _userData = userDoc.data() as Map<String, dynamic>;
    if (_userData['selectedtrip'] == null) throw UserHasNoSelectedTripException();

    final tripId = _userData['selectedtrip'];
    try {
      await FirebaseFirestore.instance.collection('trips').doc(tripId).get();
    } catch (e) {
      throw UserIsNotInTripException();
    }

    final currentTrip =
        await FirebaseFirestore.instance.collection('trips').doc(tripId).get();
    Map<String, dynamic> currentTripdata = currentTrip.data()!;
    _userData['numberofusers'] = currentTripdata['members'].length;
    return _userData;
  }

  // A function that returns the current day for the Widget list and also saves it in the currentDay variable for later use
  static Future<DocumentReference> getCurrentDaySubCollection(
      DateTime selectedDay, DocumentReference selectedTripReference) async {
    
    Map<String, dynamic> currentTripdata = (await selectedTripReference.get()).data()! as Map<String, dynamic>;
    final DateTime tripStart = currentTripdata['startdate'].toDate();
    final DateTime tripEnd = currentTripdata['enddate'].toDate();
    // issue: that the day doesnt starts at 0:00, thats why we need to filter the day
    final filteredDay = Timestamp.fromDate(DateTime(
        selectedDay.year, selectedDay.month, selectedDay.day, 0, 0, 0));

    QuerySnapshot currentDay = await selectedTripReference
        .collection("days")
        .where("starttime", isEqualTo: filteredDay)
        .get();
    if (currentDay.docs.isEmpty) {
      // if there is no day yet, create one
      // every Day has a starttime, active and archive
      // the first widget is the diary, wiche is always active and cant be deleted
      DateTime diaryTime = await calculateDiaryTime(selectedDay);
      DocumentReference day = await selectedTripReference.collection("days").add({
        'starttime': filteredDay,
        'active': {},
        'archive': {},
      });

      // only within the trip duration a diary widget will be created
      if (selectedDay.isAfter(tripStart) && selectedDay.isBefore(tripEnd)) {
        DocumentReference? diary;
        DateTime today = DateTime(DateTime.now().year, DateTime.now().month,
            DateTime.now().day, 0, 0, 0, 0);
        if (filteredDay.toDate().isAfter(DateTime.now()) ||
            filteredDay.toDate().isAtSameMomentAs(today)) {
          diary = await FirebaseFirestore.instance.collection("tasks").add({
            'performAt': diaryTime,
            'status': 'pending',
            'active': true,
            'worker': 'WriteDiaryNotification',
            'options': {
              'day': day,
              'trip': selectedTripReference,
            },
          });
        }
        await day.update({
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
              'workers': [diary]
            },
          }
        });
      }

      return day;
    } else {
      DocumentReference day = currentDay.docs.first.reference;
      final tripEndPlusDay = tripEnd.add(const Duration(days: 1));
      if (selectedDay.isAfter(tripStart) && selectedDay.isBefore(tripEndPlusDay)) {
        Map<String, dynamic> active =
            ((await day.get()).data()! as Map<String, dynamic>)["active"];
        if (active["diary"] == null) {
          DateTime diaryTime = await calculateDiaryTime(selectedDay);
          DocumentReference? diary;
          DateTime today = DateTime(DateTime.now().year, DateTime.now().month,
              DateTime.now().day, 0, 0, 0, 0);
          if (filteredDay.toDate().isAfter(DateTime.now()) ||
              filteredDay.toDate().isAtSameMomentAs(today)) {
            diary = await FirebaseFirestore.instance.collection("tasks").add({
              'performAt': diaryTime,
              'status': 'pending',
              'active': true,
              'worker': 'WriteDiaryNotification',
              'options': {
                'day': day,
                'trip': selectedTripReference,
              },
            });
          }
          await day.update({
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
                'workers': [diary]
              },
            }
          });
          // otherwise you will get notifications for past Days
        }
      }
      return day;
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
