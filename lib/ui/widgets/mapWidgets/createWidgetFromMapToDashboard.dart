// ignore_for_file: file_names, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/core/services/dashboardData.dart';
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
  DateTime? startDateRange;
  DateTime? endDateRange;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getStartDate();
  }

  getStartDate() async {
    final auth = FirebaseAuth.instance.currentUser;
    if (auth == null) {
      // Handle the case where the user is not authenticated
      return Future.error('User not authenticated');
    }
    final DocumentSnapshot<Map<String, dynamic>> userDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(auth.uid)
            .get();

    final String tripId = userDoc.data()!['selectedtrip'].toString();

    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await FirebaseFirestore.instance.collection('trips').doc(tripId).get();
    if (documentSnapshot.exists) {
      final DateTime startDate = documentSnapshot.data()!['startdate'].toDate();
      int day = startDate.day;
      int month = startDate.month;
      int year = startDate.year;
      DateTime startresult = DateTime(year, month, day);
      startDateRange = startresult;
    } else {
      ErrorSnackbar.showErrorSnackbar(context, "No trip found");
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (show) {
      case 'init':
        return Column(
          children: [
            //TODO hier weiter machen, irgendwie ist startDateRange null
            CupertinoDatePickerButton(
              boundingDate: startDateRange != null
                  ? (DateTime.now().isAfter(startDateRange!)
                      ? DateTime.now()
                      : startDateRange)
                  : DateTime.now().add(const Duration(days: 1)),
              showFuture: true,
              mode: CupertinoDatePickerMode.date,
              onDateSelected: (date) {
                setState(() {
                  selectedDate = date.date;
                });
                getDayReference(date.date);
              },
              presetDate: selectedDate != null
                  ? DateFormat('dd.MM.yyyy').format(selectedDate!)
                  : "Select date where you want to add a widget",
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
                    onTap: selectedDate != null && day != null
                        ? () => {
                              setState(() {
                                show = 'note';
                              })
                            }
                        : selectedDate == null
                            ? () {
                                ErrorSnackbar.showErrorSnackbar(
                                    context, "Please select a date first");
                              }
                            : () {
                                ErrorSnackbar.showErrorSnackbar(context,
                                    "Select a date that is in the right time range of the trip");
                              },
                    text: "Add Note"),
                ModalButton(
                    icon: Icons.date_range,
                    onTap: selectedDate != null && day != null
                        ? () => {
                              setState(() {
                                show = 'appointment';
                              })
                            }
                        : selectedDate == null
                            ? () {
                                ErrorSnackbar.showErrorSnackbar(
                                    context, "Please select a date first");
                              }
                            : () {
                                ErrorSnackbar.showErrorSnackbar(context,
                                    "Select a date that is in the right time range of the trip");
                              },
                    text: "Add Appointment"),
                ModalButton(
                    icon: Icons.poll,
                    onTap: selectedDate != null && day != null
                        ? () => {
                              setState(() {
                                show = 'questionsurvey';
                              })
                            }
                        : selectedDate == null
                            ? () {
                                ErrorSnackbar.showErrorSnackbar(
                                    context, "Please select a date first");
                              }
                            : () {
                                ErrorSnackbar.showErrorSnackbar(context,
                                    "Select a date that is in the right time range of the trip");
                              },
                    text: "Add Question Survery"),
                ModalButton(
                    icon: Icons.poll,
                    onTap: selectedDate != null && day != null
                        ? () => {
                              setState(() {
                                show = 'appointmentsurvey';
                              })
                            }
                        : selectedDate == null
                            ? () {
                                ErrorSnackbar.showErrorSnackbar(
                                    context, "Please select a date first");
                              }
                            : () {
                                ErrorSnackbar.showErrorSnackbar(context,
                                    "Select a date that is in the right time range of the trip");
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

  Future<void> getDayReference(DateTime selectedDate) async {
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
        DashBoardData.getCurrentDaySubCollection(selectedDate);
      }
    } else {
      ErrorSnackbar.showErrorSnackbar(context, "No user found for this trip");
    }
  }
}
