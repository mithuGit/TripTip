import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';
import 'package:internet_praktikum/ui/views/dashboard/scrollview.dart';
import 'package:internet_praktikum/ui/views/dashboard/dashboard.dart';
import 'package:internet_praktikum/ui/widgets/bottom_sheet.dart';
import 'package:internet_praktikum/ui/widgets/dashboardWidgets/addNoteWidgetToDashboard.dart';
import 'package:internet_praktikum/ui/widgets/dashboardWidgets/usernameBagageDashboardWidget.dart';
import 'package:provider/provider.dart';

class SimpleNoteWidget extends StatefulWidget {
  final Map<String, dynamic>? data;
  Stream<bool> pressedStream;
  Map<String, dynamic>? userdata;
  DocumentReference? day;
  SimpleNoteWidget({required this.data, required this.pressedStream, this.userdata, this.day});

  @override
  _SimpleNoteWidgetState createState() => _SimpleNoteWidgetState();
}

class _SimpleNoteWidgetState extends State<SimpleNoteWidget> {
  @override
  Widget build(BuildContext context) {
   /*  widget.pressedStream.listen((event) {
      if (event) {
        print("pressedEditButton");
        SchedulerBinding.instance.addPostFrameCallback((_) {
          CustomBottomSheet.show(context, title: "Edit Note", content: [
            AddNoteWidgetToDashboard(
              day: widget.day!,
              userdata: widget.userdata!,
              data: widget.data,
            )
          ]);
        });
      }
    }); */

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
