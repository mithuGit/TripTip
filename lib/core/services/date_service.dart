import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DateService {
  static Future<String> getSelectedTripId() async {
    final auth = FirebaseAuth.instance.currentUser;
    if (auth == null) {
      // Handle the case where the user is not authenticated
      return Future.error('User not authenticated');
    }
    final DocumentSnapshot<Map<String, dynamic>> userDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(auth.uid)
            .get();

    final String tripId = userDoc.data()!['selectedtrip'].toString();

    return tripId;
  }

  static Future<DateTime> getStartDate() async {
    final String selectedTripDoc = await getSelectedTripId();
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await FirebaseFirestore.instance
            .collection('trips')
            .doc(selectedTripDoc)
            .get();
    if (documentSnapshot.exists) {
      final DateTime startDate = documentSnapshot.data()!['startdate'].toDate();
      int day = startDate.day;
      int month = startDate.month;
      int year = startDate.year;
      DateTime result = DateTime(year, month,
          day); // Testen ob hier manchmal ein Fehler auftriit und bei day + 1 muss
      return result;
    } else {
      //TODO:;Werden die Exception noch angezeigt?
      throw Exception('No trips selected');
    }
  }

  static Future<DateTime> getEndDate() async {
    final String selectedTripDoc = await getSelectedTripId();
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await FirebaseFirestore.instance
            .collection('trips')
            .doc(selectedTripDoc)
            .get();
    if (documentSnapshot.exists) {
      final DateTime endDate = documentSnapshot.data()!['enddate'].toDate();
      int day = endDate.day;
      int month = endDate.month;
      int year = endDate.year;
      DateTime result = DateTime(year, month,
          day); // Testen ob hier manchmal ein Fehler auftriit und bei day + 1 muss
      return result;
    } else {
      //TODO:;Werden die Exception noch angezeigt?
      throw Exception('No trips selected');
    }
  }
}
