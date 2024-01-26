import 'package:cloud_firestore/cloud_firestore.dart';

// A Class wiche is used to create a Jobworker
// and securely delete all workers
// This class is also needede if an archived widget is restored

class JobworkerService {
  static var firestore = FirebaseFirestore.instance;
  static Future<DocumentReference> generateAppointmentWorker(
      DateTime selectedDate,
      DocumentReference day,
      DocumentReference createdBy,
      DocumentReference trip,
      String title) async {
    return await firestore.collection("tasks").add({
      "worker": "AppoinmentNotification",
      "performAt": selectedDate,
      "status": "pending",
      "active" : true,
      "options": {
        "day": day,
        "widgetCreatedBy": createdBy,
        "titleOfAppointment": title,
        "trip": trip,
      }
    });
  }

  static Future<DocumentReference> generateSurveyConvertionWorker(
      DateTime deadline,
      DocumentReference day,
      DocumentReference createdBy,
      DocumentReference trip,
      String key,
      String title) async {
    return await firestore.collection("tasks").add({
      "worker": "SurveyConvertion",
      "performAt": deadline,
      "status": "pending",
      "active" : true,
      "options": {
        "day": day,
        "widgetCreatedBy": createdBy,
        "titleOfSurvey": title,
        "trip": trip,
        "key": key
      }
    });
  }
  static Future<DocumentReference> generateLastChanceSurveryWorker(
      DateTime deadline,
      DocumentReference day,
      DocumentReference createdBy,
      DocumentReference trip,
      String key,
      String title) async {
    return await firestore.collection("tasks").add({
      "worker": "LastChanceSurvey",
      "performAt": deadline,
      "status": "pending",
      "active" : true,
      "options": {
        "day": day,
        "widgetCreatedBy": createdBy,
        "titleOfSurvey": title,
        "trip": trip,
        "key": key
      }
    });
  }

  static Future<void> deleteAllWorkers(List<DocumentReference> workers) async {
    for (var worker in workers) {
      await worker.update({"active": false});
    }
  }
}
