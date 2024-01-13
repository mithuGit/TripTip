// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/widgets/dashboardWidgets/addAppointmentWidgetToDashboard.dart';
import 'package:internet_praktikum/ui/widgets/dashboardWidgets/addNoteWidgetToDashboard.dart';
import 'package:internet_praktikum/ui/widgets/dashboardWidgets/addSurveyWidgetToDashboard.dart';
import 'package:internet_praktikum/ui/widgets/datepicker.dart';
import 'package:internet_praktikum/ui/widgets/modalButton.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class CreateWidgetFromMapToDashboard extends StatefulWidget {
  final String placeName;
  Map<String, dynamic> userdata;
  CreateWidgetFromMapToDashboard({super.key, required this.userdata, required this.placeName});

  @override
  // ignore: library_private_types_in_public_api
  _CreateWidgetFromMapToDashboardState createState() =>
      _CreateWidgetFromMapToDashboardState();
}

class _CreateWidgetFromMapToDashboardState
    extends State<CreateWidgetFromMapToDashboard> {
  String show = 'init';
  DocumentReference? day;
  DateTime? selectedDate;
  @override
  Widget build(BuildContext context) {
    switch (show) {
      case 'init':
        return Column(
          children: [
            CupertinoDatePickerButton(
              showFuture: false,
              mode: CupertinoDatePickerMode.date,
              onDateSelected: (date) {
                setState(() {
                  selectedDate = date.date;
                });
              },
              presetDate: selectedDate != null
                  ? DateFormat('dd.MM.yyyy').format(selectedDate!)
                  : "Select Date",
            ),
            const SizedBox(
              height: 20,
            ),
            GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              children: [
                ModalButton(
                    icon: Icons.date_range,
                    onTap: () => {
                          setState(() {
                            show = 'appointment';
                          })
                        },
                    text: "Add Appointment"),
                ModalButton(
                    icon: Icons.poll,
                    onTap: () => {
                          setState(() {
                            show = 'questionsurvey';
                          })
                        },
                    text: "Add Question Survery"),
                ModalButton(
                    icon: Icons.poll,
                    onTap: () => {
                          setState(() {
                            show = 'appointmentsurvey';
                          })
                        },
                    text: "Add Appointment Survery"),
              ],
            ),
          ],
        );
      case 'note':
        setState(() async {
          day = await getDayReferenceFromSelectedDate(selectedDate!);
        });
        return AddNoteWidgetToDashboard(
          userdata: widget.userdata,
         day: day!);
      case 'appointment':
        setState(() async {
          day = await getDayReferenceFromSelectedDate(selectedDate!);
        });
        return AddAppointmentWidgetToDashboard(
            userdata: widget.userdata, day: day!);
      case 'questionsurvey':
        setState(() async {
          day = await getDayReferenceFromSelectedDate(selectedDate!);
        });
        return AddSurveyWidgetToDashboard(
          userdata: widget.userdata,
          day: day!,
          typeOfSurvey: 'questionsurvey',
        );
      case 'appointmentsurvey':
        setState(() async {
          day = await getDayReferenceFromSelectedDate(selectedDate!);
        });
        return AddSurveyWidgetToDashboard(
          userdata: widget.userdata,
          day: day!,
          typeOfSurvey: 'appointmentsurvey',
        );
      default:
        return const Text('default');
    }
  }

  fromselectedDateToTimestamp(DateTime? selectedDate) {
    return Timestamp.fromDate(selectedDate!);
  }

  Future<DocumentReference> getDayReferenceFromSelectedDate(
      DateTime selectedDate) async {
    User user = FirebaseAuth.instance.currentUser!;
    var uid = user.uid;

    var doc = await FirebaseFirestore.instance
        .collection("trips")
        .doc(uid)
        .collection("days")
        .where("date", isEqualTo: fromselectedDateToTimestamp(selectedDate))
        .get();

    return doc.docs[0].reference;
  }
}
