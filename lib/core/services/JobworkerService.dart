// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';

// A Class wiche is used to create a Jobworker
// and securely delete all workers
// This class is also needede if an archived widget is restored

class JobworkerService {
  static var firestore = FirebaseFirestore.instance;
  // every Worker is linked to a appointment
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
      "options": {
        "day": day,
        "widgetCreatedBy": createdBy,
        "titleOfAppointment": title,
        "trip": trip,
      }
    });
  }

  // This Function is used to create a new Diary Worker, that converts a Diary to a dedicated Widget
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
      "options": {
        "day": day,
        "widgetCreatedBy": createdBy,
        "titleOfSurvey": title,
        "trip": trip,
        "key": key
      }
    });
  }
  // 15 min before the survey ends, a notification will be sent
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
      "options": {
        "day": day,
        "widgetCreatedBy": createdBy,
        "titleOfSurvey": title,
        "trip": trip,
        "key": key
      }
    });
  }
  // This Function is used to delete all workers of a widget
  static Future<void> deleteAllWorkers(List<DocumentReference> workers) async {
    for (var worker in workers) {
      DocumentSnapshot workerSnap = await worker.get();
      if (workerSnap.exists) {
        await worker.update({
          "status": "archived",});
      }
    }
  }
  // this function is used to reactivate all workers
  static Future<void> reactivateAllWorkers(List<DocumentReference> workers) async {
    for (var worker in workers) {
      DocumentSnapshot workerSnap = await worker.get();
      if (workerSnap.exists) {
        await worker.update({
          "status": "pending",});
      }
    }
  }
}
