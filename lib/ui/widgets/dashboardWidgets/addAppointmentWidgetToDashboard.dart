// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/core/services/addWidget.dart';
import 'package:internet_praktikum/ui/views/main_pages/dashboard.dart';
import 'package:internet_praktikum/ui/widgets/errorSnackbar.dart';
import 'package:internet_praktikum/ui/widgets/inputfield.dart';
import 'package:internet_praktikum/ui/widgets/my_button.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

// ignore: must_be_immutable
class AddAppointmentWidgetToDashboard extends StatefulWidget {
  DocumentReference<Object?> day;
  AddAppointmentWidgetToDashboard({super.key, required this.day});

  // ignore: library_private_types_in_public_api
  _AddAppointmentWidgetToDashboardState createState() =>
      _AddAppointmentWidgetToDashboardState();
}

class _AddAppointmentWidgetToDashboardState extends State<AddAppointmentWidgetToDashboard> {
  final nameOfAppointment = TextEditingController();
  final appointment = TextEditingController();
  var uuid = const Uuid();

  @override
  Widget build(BuildContext context) {
    final userdata = context.watch<ProviderUserdata?>();
    if (userdata == null) {
      return const Text("no userdata");
    }

    Future<void> createNote() async {
      print(userdata);
      Map<String, dynamic> data = {
        "type": "appointment",
        "content": appointment.text,
        "title": nameOfAppointment.text,
      };
      DocumentReference by = FirebaseFirestore.instance.collection('users')
      .doc(userdata.userdata["uid"]);
      await AddWidget().addWidget(widget.day, by, data);
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
