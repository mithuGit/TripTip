// ignore_for_file: must_be_immutable, avoid_print, file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/core/services/JobworkerService.dart';
import 'package:internet_praktikum/core/services/manageDashboardWidget.dart';
import 'package:internet_praktikum/core/services/map_service.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';
import 'package:internet_praktikum/ui/widgets/datepicker.dart';
import 'package:internet_praktikum/ui/widgets/errorSnackbar.dart';
import 'package:internet_praktikum/ui/widgets/inputfield.dart';
import 'package:internet_praktikum/ui/widgets/my_button.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class AddAppointmentWidgetToDashboard extends StatefulWidget {
  Place? place;
  Map<String, dynamic> userdata;
  DocumentReference day;
  Map<String, dynamic>? data;
  AddAppointmentWidgetToDashboard(
      {super.key,
      required this.day,
      required this.userdata,
      this.data,
      this.place});

  @override
  // ignore: library_private_types_in_public_api
  _AddAppointmentWidgetToDashboardState createState() =>
      _AddAppointmentWidgetToDashboardState();
}

class _AddAppointmentWidgetToDashboardState
    extends State<AddAppointmentWidgetToDashboard> {
  final nameOfAppointment = TextEditingController();
  final appointment = TextEditingController();
  DateTime? selectedDate;
  DateTime boundingDate = DateTime(2021, 1, 1, 0, 0);
  var uuid = const Uuid();
  var firestore = FirebaseFirestore.instance;
  DateTime? oldselectedDate;
  Place? selectedPlace;

  @override
  void initState() {
    super.initState();
    selectedPlace = widget.place;

    if (widget.data != null) {
      nameOfAppointment.text = widget.data!["title"];
      appointment.text = widget.data!["content"];
      selectedDate = widget.data!["date"].toDate();
      oldselectedDate = widget.data!["date"].toDate();
      selectedPlace = widget.data!["place"] != null
          ? Place.fromMap(widget.data!["place"])
          : null;
    } else {
      getPlaceDetails();
    }
  }

  void getPlaceDetails() {
    if (widget.place != null) {
      nameOfAppointment.text = selectedPlace!.name;
      String adress = selectedPlace!.formattedAddress;
      if (selectedPlace!.formattedAddress == "") {
        adress = "No adress available";
      }
      appointment.text =
          "If you want to go there, this is the Adress :\n$adress";
    }
  }

  @override
  Widget build(BuildContext context) {
    Future<void> createOrAddAppointment() async {
      if (nameOfAppointment.text.isEmpty) {
        throw Exception("Please enter a title for this appointment");
      }
      DocumentSnapshot daySnapshot = await widget.day.get();
      Map<String, dynamic> dayData = daySnapshot.data() as Map<String, dynamic>;
      // check if the starttime is not null and if the starttime is not on the selected day
      if (dayData["starttime"] != null) {
        DateTime starttime = dayData["starttime"].toDate();
        // set the startime to the day of the selected day
        selectedDate = DateTime(starttime.year, starttime.month, starttime.day,
            selectedDate!.hour, selectedDate!.minute);
      }
      if (selectedDate!.day == DateTime.now().day &&
          selectedDate!.month == DateTime.now().month &&
          selectedDate!.year == DateTime.now().year) {
        // check if the starttime is before the current time
        if (selectedDate!.hour < DateTime.now().hour) {
          throw Exception("The appointment can't be in the past");
        } else if (selectedDate!.hour == DateTime.now().hour &&
            selectedDate!.minute < DateTime.now().minute) {
          throw Exception("The appointment can't be in the past");
        }
      }
      DocumentReference by = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userdata["uid"]);
      DocumentReference trip = FirebaseFirestore.instance
          .collection('trips')
          .doc(widget.userdata["selectedtrip"]);

      Map<String, dynamic> data = {
        "type": "appointment",
        "content": appointment.text,
        "date": selectedDate,
        "title": nameOfAppointment.text,
      };
      if (widget.place != null) {
        data["place"] = widget.place!.toMap();
      }

      if (widget.data == null) {
        DocumentReference worker =
            await JobworkerService.generateAppointmentWorker(
                selectedDate!, widget.day, by, trip, nameOfAppointment.text);
        data["workers"] = [worker];
        await ManageDashboardWidged()
            .addWidget(day: widget.day, user: by, data: data);
      } else {
        if (oldselectedDate != selectedDate) {
          List<DocumentReference> workers = (widget.data!["workers"] as List)
              .map((e) => e as DocumentReference)
              .toList();
          await JobworkerService.deleteAllWorkers(workers);
          DocumentReference worker =
              await JobworkerService.generateAppointmentWorker(
                  selectedDate!, widget.day, by, trip, nameOfAppointment.text);
          data["workers"] = [worker];
        }
        await ManageDashboardWidged()
            .updateWidget(widget.day, by, data, widget.data!["key"]);
      }
      if (context.mounted) Navigator.pop(context);
    }

    return Column(children: [
      InputField(
          controller: nameOfAppointment,
          hintText: "Title of Appointment",
          focusedBorderColor: const Color.fromARGB(255, 84, 113, 255),
          borderColor: Colors.grey.shade400,
          obscureText: false),
      const SizedBox(height: 10),
      CupertinoDatePickerButton(
        showFuture: true,
        mode: CupertinoDatePickerMode.time,
        initialDateTime: selectedDate,
        boundingDate: DateTime(2021, 1, 1, 0, 0),
        use24hFormat: true,
        onDateSelected: (date) {
          setState(() {
            selectedDate = date.date;
          });
        },
        presetDate: selectedDate != null
            ? DateFormat('HH:mm').format(selectedDate!)
            : "Select Time",
      ),
      const SizedBox(height: 10),
      if (selectedPlace != null) ... [
        Text("Is bound to locaition: ${selectedPlace!.name}", style: Styles.inputField, textAlign: TextAlign.left,),
        const SizedBox(height: 10),
      ],  
      InputField(
          controller: appointment,
          hintText: "Description of Appointment",
          focusedBorderColor: const Color.fromARGB(255, 84, 113, 255),
          borderColor: Colors.grey.shade400,
          multiline: true,
          obscureText: false),
      const SizedBox(height: 10),
      MyButton(
          borderColor: Colors.black,
          textStyle: Styles.buttonFontStyleModal,
          onTap: () => createOrAddAppointment().onError((error, stackTrace) => {
                print(error.toString()),
                print(stackTrace.toString()),
                print("error"),
                ErrorSnackbar.showErrorSnackbar(context, error.toString())
              }),
          text: widget.data == null
              ? "Add Appointment to Dashboard"
              : "Update Appointment")
    ]);
  }
}
