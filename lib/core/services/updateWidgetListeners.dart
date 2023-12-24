import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/widgets/bottom_sheet.dart';
import 'package:internet_praktikum/ui/widgets/dashboardWidgets/addAppointmentWidgetToDashboard.dart';
import 'package:internet_praktikum/ui/widgets/dashboardWidgets/addNoteWidgetToDashboard.dart';
import 'package:internet_praktikum/ui/widgets/dashboardWidgets/addSurveyWidgetToDashboard.dart';

class UpdateWidgetData {
  final Map<String, dynamic> data;
  final DocumentReference day;
  final Map<String, dynamic> userdata;
  final String type;
  UpdateWidgetData(this.data, this.day, this.userdata, this.type);
}
class UpdateWidgetListeners {
  void updateWidget(String key, Map<String, dynamic> data, DocumentReference day,  Map<String, dynamic> userdata, BuildContext context) {
    if (data["type"] == "note") {
       CustomBottomSheet.show(context, title: "Edit Note", content: [
          AddNoteWidgetToDashboard(
            day: day,
            userdata: userdata,
            data: data,
          )
        ]);
    } else if (data["type"] == "appointment") {
       CustomBottomSheet.show(context, title: "Edit Appointment", content: [
         AddAppointmentWidgetToDashboard(
           day: day,
           userdata: userdata,
           data: data,
         )
       ]);
    } else if (data["type"] == "survey") {
      CustomBottomSheet.show(context, title: "Edit Survey", content: [
        AddSurveyWidgetToDashboard(
          typeOfSurvey: data["typeOfSurvey"],
          day: day,
          userdata: userdata,
          data: data,
         )
       ]);
    }
  }
}