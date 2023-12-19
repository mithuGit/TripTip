import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';
import 'package:internet_praktikum/ui/views/dashboard/scrollview.dart';
import 'package:internet_praktikum/ui/views/main_pages/dashboard.dart';
import 'package:internet_praktikum/ui/widgets/bottom_sheet.dart';
import 'package:internet_praktikum/ui/widgets/dashboardWidgets/addNoteWidgetToDashboard.dart';
import 'package:internet_praktikum/ui/widgets/dashboardWidgets/usernameBagageDashboardWidget.dart';
import 'package:provider/provider.dart';

class SimpleNoteWidget extends StatefulWidget {
  final Map<String, dynamic>? data;

  const SimpleNoteWidget({required this.data});

  @override
  _SimpleNoteWidgetState createState() => _SimpleNoteWidgetState();
}

class _SimpleNoteWidgetState extends State<SimpleNoteWidget> {
  @override
  Widget build(BuildContext context) {
    PressdEditButton pressedEditButton = context.watch<PressdEditButton>();
    DocumentReference<Object?>? day = context.watch<ProviderDay>().day;
    Map<String, dynamic>? userData = context.watch<ProviderUserdata>().userdata;

    if (pressedEditButton.pressed) {
     // pressedEditButton.changePressed();
      SchedulerBinding.instance.addPostFrameCallback((_) {
        CustomBottomSheet.show(context, title: "Edit Note", content: [ 
          AddNoteWidgetToDashboard(day: day!, userdata: userData!)]);
      });
      
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(widget.data!["content"], style: Styles.noteTextstyle),
        UsernameBagageDashboardWidget(data: widget.data!),
      ],
    );
  }
}
