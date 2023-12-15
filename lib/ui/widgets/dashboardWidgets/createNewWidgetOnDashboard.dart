import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/views/main_pages/dashboard.dart';
import 'package:internet_praktikum/ui/widgets/dashboardWidgets/addNoteWidgetToDashboard.dart';
import 'package:internet_praktikum/ui/widgets/my_button.dart';
import 'package:provider/provider.dart';

class CreateNewWidgetOnDashboard extends StatefulWidget {
  CreateNewWidgetOnDashboard({super.key});

  @override
  _CreateNewWidgetOnDashboardState createState() =>
      _CreateNewWidgetOnDashboardState();
}

class _CreateNewWidgetOnDashboardState
    extends State<CreateNewWidgetOnDashboard> {
  String show = 'init';
  @override
  Widget build(BuildContext context) {
    DocumentReference<Object?>? day = context.watch<ProviderDay?>()?.day;
     if(day == null){
        return const CircularProgressIndicator();
    }
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
        return AddNoteWidgetToDashboard(day: day!);
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
