// ignore_for_file: file_names, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internet_praktikum/core/services/dashboardData.dart';
import 'package:internet_praktikum/core/services/date_service.dart';
import 'package:internet_praktikum/core/services/map_service.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';
import 'package:internet_praktikum/ui/widgets/dashboardWidgets/addAppointmentWidgetToDashboard.dart';
import 'package:internet_praktikum/ui/widgets/dashboardWidgets/addNoteWidgetToDashboard.dart';
import 'package:internet_praktikum/ui/widgets/dashboardWidgets/addSurveyWidgetToDashboard.dart';
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    switch (show) {
      case 'init':
        return Column(
          children: [
            const Text(
                'Select a date that is in the right time range of the trip',
                style: Styles.headlineForDateInMapWidget),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () async {
                await showCupertinoModalPopup<void>(
                  context: context,
                  builder: (BuildContext context) => FutureBuilder<Container>(
                    future: getDateRangeCupertiono(MediaQuery.of(context).size),
                    builder: (BuildContext context,
                        AsyncSnapshot<Container> snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasData) {
                          return snapshot.data!;
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }
                      }
                      return const CircularProgressIndicator();
                    },
                  ),
                );
              },
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.4,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: Colors.black,
                    ),
                    selectedDate != null
                        ? Text(
                            DateFormat('dd-MM-yyyy').format(selectedDate!),
                            style: Styles.datepicker,
                          )
                        : const Text('Select Date'),
                  ],
                ),
              ),
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
                        : () {
                            ErrorSnackbar.showErrorSnackbar(
                                context, "Please select a date first");
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
                        : () {
                            ErrorSnackbar.showErrorSnackbar(
                                context, "Please select a date first");
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
                        : () {
                            ErrorSnackbar.showErrorSnackbar(
                                context, "Please select a date first");
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
                        : () {
                            ErrorSnackbar.showErrorSnackbar(
                                context, "Please select a date first");
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
      final DocumentReference selectedTripDoc =
          FirebaseFirestore.instance.collection('trips').doc(tripId);

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
        DashBoardData.getCurrentDaySubCollection(selectedDate, selectedTripDoc);
      }
    } else {
      ErrorSnackbar.showErrorSnackbar(context, "No user found for this trip");
    }
  }

  // Die Funktion, die den Container asynchron erstellt
  Future<Container> getDateRangeCupertiono(Size size) async {
    StartEndDate startEndDate =
        await DateService.getStartEndDate(await DashBoardData.getCurrentTrip());
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(34.5),
          topRight: Radius.circular(34.5),
        ),
      ),
      height: size.height * 0.35,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5.0, right: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () async {
                    // Führen Sie die asynchrone Arbeit außerhalb von setState durch
                    DateTime? newSelectedDate;
                    if (selectedDate == null) {
                      newSelectedDate = (await DateService.getStartDate())
                              .isAfter(DateTime.now())
                          ? await DateService.getStartDate()
                          : DateTime.now();

                      await getDayReference(newSelectedDate);
                      setState(() {
                        selectedDate = newSelectedDate;
                      });
                    }

                    context.pop();
                  },
                  child: const Text('Done'),
                ),
              ],
            ),
          ),
          Flexible(
            child: SizedBox(
              height: size.height * 0.25,
              child: CupertinoDatePicker(
                minimumDate: (startEndDate.startDate).isAfter(DateTime.now())
                    ? startEndDate.startDate
                    : DateTime.now(),
                maximumDate: startEndDate.endDate,
                initialDateTime:
                    (await DateService.getStartDate()).isAfter(DateTime.now())
                        ? await DateService.getStartDate()
                        : DateTime.now(),
                minimumDate: await DateService.getStartDate(),
                maximumDate: await DateService.getEndDate(),
                mode: CupertinoDatePickerMode.date,
                onDateTimeChanged: (value) {
                  setState(() {
                    selectedDate = value;
                    getDayReference(value);
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
