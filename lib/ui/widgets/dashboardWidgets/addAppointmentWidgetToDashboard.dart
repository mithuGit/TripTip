
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/core/services/manageDashboardWidget.dart';
import 'package:internet_praktikum/ui/views/main_pages/dashboard.dart';
import 'package:internet_praktikum/ui/widgets/errorSnackbar.dart';
import 'package:internet_praktikum/ui/widgets/inputfield.dart';
import 'package:internet_praktikum/ui/widgets/my_button.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class AddAppointmentWidgetToDashboard extends StatefulWidget {
  DocumentReference day;
  Map<String, dynamic> userdata;
  AddAppointmentWidgetToDashboard({super.key, required this.day, required this.userdata});

  _AddAppointmentWidgetToDashboardState createState() =>
      _AddAppointmentWidgetToDashboardState();
}

class _AddAppointmentWidgetToDashboardState extends State<AddAppointmentWidgetToDashboard> {
  final nameOfAppointment = TextEditingController();
  final appointment = TextEditingController();
  var uuid = const Uuid();

  @override
  Widget build(BuildContext context) {

    Future<void> createNote() async {
      Map<String, dynamic> data = {
        "type": "appointment",
        "content": appointment.text,
        "title": nameOfAppointment.text,
      };
      DocumentReference by = FirebaseFirestore.instance.collection('users')
      .doc(widget.userdata["uid"]);
      await ManageDashboardWidged().addWidget(widget.day, by, data);
    }

    return Column(children: [
      const Text("Title of Appointment"),
      InputField(
          controller: nameOfAppointment,
          hintText: "Title of Appointment",
          obscureText: false),
      InputField(controller: appointment, hintText: "Appointment", obscureText: false),
      MyButton(
          colors: Colors.blue,
          onTap: () => createNote().onError((error, stackTrace) => {
                print(error.toString()),
                print(stackTrace.toString()),
                print("error"),
                ErrorSnackbar.showErrorSnackbar(context, error.toString())
              }),
          text: "Create Appointment")
    ]);
  }
}
