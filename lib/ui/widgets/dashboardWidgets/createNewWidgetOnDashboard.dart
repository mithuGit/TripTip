import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/widgets/dashboardWidgets/addNoteWidgetToDashboard.dart';
import 'package:internet_praktikum/ui/widgets/my_button.dart';

class CreateNewWidgetOnDashboard extends StatefulWidget {
  DocumentReference<Object?> day;
  CreateNewWidgetOnDashboard({super.key, required this.day});

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
          MyButton(
              colors: Colors.blue,
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
              text: "Add Appointment")
        ]);
      case 'note':
        return AddNoteWidgetToDashboard(day: widget.day,);
      case 'appointment':
        return Container(
          child: Text('list'),
        );
      default:
        return Container(
          child: Text('default'),
        );
    }
  }
}
