import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/views/main_pages/dashboard.dart';
import 'package:internet_praktikum/ui/widgets/dashboardWidgets/addAppointmentWidgetToDashboard.dart';
import 'package:internet_praktikum/ui/widgets/dashboardWidgets/addNoteWidgetToDashboard.dart';
import 'package:internet_praktikum/ui/widgets/dashboardWidgets/addSurveyWidgetToDashboard.dart';
import 'package:internet_praktikum/ui/widgets/modalButton.dart';
import 'package:internet_praktikum/ui/widgets/my_button.dart';
import 'package:provider/provider.dart';

class CreateNewWidgetOnDashboard extends StatefulWidget {
  Map<String, dynamic> userdata;
  DocumentReference day;
  CreateNewWidgetOnDashboard({super.key, required this.day, required this.userdata});

  @override
  _CreateNewWidgetOnDashboardState createState() =>
      _CreateNewWidgetOnDashboardState();
}

class _CreateNewWidgetOnDashboardState
    extends State<CreateNewWidgetOnDashboard> {
  String show = 'init';
  @override
  Widget build(BuildContext context) {
    switch (show) {
      case 'init':
        return Column(children: [
          ModalButton(
              onTap: () => {
                    setState(() {
                      show = 'note';
                    })
                  },
              text: "Add Note"),
          MyButton(
              colors: Colors.blue,
              onTap: () => {
                    setState(() {
                      show = 'appointment';
                    })
                  },
              text: "Add Appointment"),
          MyButton(
              colors: Colors.blue,
              onTap: () => {
                    setState(() {
                      show = 'survey';
                    })
                  },
              text: "Add Survey"),
        ]);
      case 'note':
        return AddNoteWidgetToDashboard(userdata: widget.userdata, day: widget.day);
      case 'appointment':
        return AddAppointmentWidgetToDashboard(userdata: widget.userdata, day: widget.day);
      case 'survey':
        return AddSurveyWidgetToDashboard(userdata: widget.userdata, day: widget.day);
      default:
        return const Text('default');
    }
  }
}
