import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';
import 'package:internet_praktikum/ui/widgets/dashboardWidgets/appointment.dart';
import 'package:internet_praktikum/ui/widgets/dashboardWidgets/diaryWidget.dart';
import 'package:internet_praktikum/ui/widgets/dashboardWidgets/simpleNoteWidget.dart';
import 'package:internet_praktikum/ui/widgets/dashboardWidgets/survey.dart';

class MainDasboardinitializer extends StatefulWidget {
  double elevation = 0;
  final String title;
  Map<String, dynamic> data;
  Map<String, dynamic> userdata;
  DocumentReference? day;
  MainDasboardinitializer({
    super.key,
    double? elevation,
    required this.title,
    required this.data,
    required this.userdata,
    required this.day,
  });
  @override
  State<MainDasboardinitializer> createState() =>
      _MainDasboardinitializerState();
}

class _MainDasboardinitializerState extends State<MainDasboardinitializer> {
  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: widget.elevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(34.4),
        ),
        color: const Color(0xE51E1E1E),
        child: Container(
          padding:
              const EdgeInsets.only(top: 20, bottom: 20, left: 20, right: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Flexible(
                  child: Text(
                    super.widget.title,
                    style: Styles.mainDasboardinitializerTitle,
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              ]),
              LayoutBuilder(builder: (context, constraints) {
                if (widget.data["type"] == null) {
                  return const Text("No type is specified");
                } else {
                  if (widget.data["type"] == "note") {
                    return SimpleNoteWidget(
                      data: widget.data,
                    );
                  } else if (widget.data["type"] == "list") {
                    return SimpleNoteWidget(
                      data: widget.data,
                    );
                  } else if (widget.data["type"] == "appointment") {
                    return AppointmentWidget(data: widget.data);
                  } else if (widget.data["type"] == "survey") {
                    return SurveyWidget(
                        data: widget.data,
                        userdata: widget.userdata,
                        day: widget.day);
                  } else if (widget.data["type"] == "diary") {
                    return DiaryWidget(data: widget.data, day: widget.day);
                  } else {
                    return const Text("No type is specified");
                  }
                }
              }),
            ],
          ),
        ));
  }
}
