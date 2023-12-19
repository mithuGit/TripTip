import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';
import 'package:internet_praktikum/ui/widgets/dashboardWidgets/appointment.dart';
import 'package:internet_praktikum/ui/widgets/dashboardWidgets/simpleNoteWidget.dart';
import 'package:internet_praktikum/ui/widgets/dashboardWidgets/survey.dart';
import 'package:provider/provider.dart';

class AddButton extends ChangeNotifier {
  bool _addButton = false;
  bool get addButton => _addButton;
  void setAddButton(bool value) {
    _addButton = value;
    notifyListeners();
  }
}

class MainDasboardinitializer extends StatefulWidget {
  double elevation = 0;
  final String title;
  Map<String, dynamic>? data;
  Stream<bool> updateStream;
  Map<String, dynamic>? userdata;
  DocumentReference? day;
  MainDasboardinitializer(
      {super.key,
      double? elevation,
      required this.title,
      required this.data,
      required this.updateStream,
      this.userdata, 
      this.day});
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
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AddButton()),
          ],
          child: Container(
            padding:
                const EdgeInsets.only(top: 20, bottom: 20, left: 20, right: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 300,
                      child: Text(
                        super.widget.title,
                        textAlign: TextAlign.left,
                        style: Styles.mainDasboardinitializerTitle,
                      ),
                    ),
                    if (widget.data?["addAble"] != null &&
                        widget.data?["addAble"] == true)
                      GestureDetector(
                        onTap: () {},
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                  ],
                ),
                LayoutBuilder(builder: (context, constraints) {
                  if (widget.data?["type"] == null) {
                    return const Text("No type is specified");
                  } else {
                    if (widget.data?["type"] == "note") {
                      return SimpleNoteWidget(
                          data: widget.data,
                          userdata: widget.userdata,
                          day: widget.day,
                          pressedStream: widget.updateStream);
                    } else if (widget.data?["type"] == "list") {
                      return SimpleNoteWidget(
                          data: widget.data,
                          userdata: widget.userdata,
                          day: widget.day,
                          pressedStream: widget.updateStream);
                    } else if (widget.data?["type"] == "appointment") {
                      return AppointmentWidget(data: widget.data);
                    } else if (widget.data?["type"] == "survey") {
                      return SurveyWidget(data: widget.data);
                    } else {
                      return const Text("No type is specified");
                    }
                  }
                }),
              ],
            ),
          ),
        ));
  }
}
