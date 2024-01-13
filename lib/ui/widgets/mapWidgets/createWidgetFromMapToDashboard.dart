// ignore_for_file: file_names, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/core/services/map_service.dart';
import 'package:internet_praktikum/ui/widgets/dashboardWidgets/addAppointmentWidgetToDashboard.dart';
import 'package:internet_praktikum/ui/widgets/dashboardWidgets/addNoteWidgetToDashboard.dart';
import 'package:internet_praktikum/ui/widgets/dashboardWidgets/addSurveyWidgetToDashboard.dart';
import 'package:internet_praktikum/ui/widgets/datepicker.dart';
import 'package:internet_praktikum/ui/widgets/errorSnackbar.dart';
import 'package:internet_praktikum/ui/widgets/modalButton.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class CreateWidgetFromMapToDashboard extends StatefulWidget {
  final Place place;
  Map<String, dynamic> userdata;
  CreateWidgetFromMapToDashboard(
      {super.key, required this.userdata, required this.place});

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
                getDayReferenceFromSelectedDate(date.date);
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
                    icon: Icons.note_add,
                    onTap: day != null
                        ? () => {
                              setState(() {
                                show = 'note';
                              })
                            }
                        : () {
                            ErrorSnackbar.showErrorSnackbar(context,
                                "Please select a date first or select a date that is in the right time range of the trip");
                          },
                    text: "Add Note"),
                ModalButton(
                    icon: Icons.date_range,
                    onTap: day != null
                        ? () => {
                              setState(() {
                                show = 'appointment';
                              })
                            }
                        : () {
                            ErrorSnackbar.showErrorSnackbar(context,
                                "Please select a date first or select a date that is in the right time range of the trip");
                          },
                    text: "Add Appointment"),
                ModalButton(
                    icon: Icons.poll,
                    onTap: day != null
                        ? () => {
                              setState(() {
                                show = 'questionsurvey';
                              })
                            }
                        : () {
                            ErrorSnackbar.showErrorSnackbar(context,
                                "Please select a date first or select a date that is in the right time range of the trip");
                          },
                    text: "Add Question Survery"),
                ModalButton(
                    icon: Icons.poll,
                    onTap: day != null
                        ? () => {
                              setState(() {
                                show = 'appointmentsurvey';
                              })
                            }
                        : () {
                            ErrorSnackbar.showErrorSnackbar(context,
                                "Please select a date first or select a date that is in the right time range of the trip");
                          },
                    text: "Add Appointment Survery"),
              ],
            ),
          ],
        );

      case 'note':
        return AddNoteWidgetToDashboard(
            userdata: widget.userdata, day: day!, place: widget.place);

      case 'appointment':
        return AddAppointmentWidgetToDashboard(
            userdata: widget.userdata, day: day!, place: widget.place);
      case 'questionsurvey':
        return AddSurveyWidgetToDashboard(
          userdata: widget.userdata,
          day: day!,
          typeOfSurvey: 'questionsurvey',
          place: widget.place,
        );
      case 'appointmentsurvey':
        return AddSurveyWidgetToDashboard(
          userdata: widget.userdata,
          day: day!,
          typeOfSurvey: 'appointmentsurvey',
          place: widget.place,
        );
      default:
        return const Text('default');
    }
  }

  Future<void> getDayReferenceFromSelectedDate(DateTime selectedDate) async {
    User user = FirebaseAuth.instance.currentUser!;

    final DocumentSnapshot<Map<String, dynamic>> userDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

    if (userDoc.exists) {
      final String tripId = userDoc.data()!['selectedtrip'].toString();

      final QuerySnapshot<Map<String, dynamic>> doc = await FirebaseFirestore
          .instance
          .collection("trips")
          .doc(tripId)
          .collection("days")
          .where("starttime", isEqualTo: Timestamp.fromDate(selectedDate))
          .get();

      if (doc.docs.isNotEmpty) {
        day = doc.docs.first.reference;
      } else {
        ErrorSnackbar.showErrorSnackbar(
            context, "No day found for the selected date");
        Navigator.pop(context);
      }
    } else {
      ErrorSnackbar.showErrorSnackbar(
          context, "No day found for the selected date");
      Navigator.pop(context);
    }
  }
}
