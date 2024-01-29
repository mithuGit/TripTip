import 'package:cloud_firestore/cloud_firestore.dart';

class StartEndDate {
  final DateTime startDate;
  final DateTime endDate;
  StartEndDate({required this.startDate, required this.endDate});
}

class DateService {
  static Future<StartEndDate> getStartEndDate(
      DocumentReference selectTrip) async {
    final DocumentSnapshot documentSnapshot = await selectTrip.get();
    if (documentSnapshot.exists) {
      Map<String, dynamic> data =
          documentSnapshot.data() as Map<String, dynamic>;
      final DateTime startDate = data['startdate'].toDate();
      final DateTime endDate = data['enddate'].toDate();
      return StartEndDate(startDate: startDate, endDate: endDate);
    }
    throw Exception('No trips selected');
  }
}
