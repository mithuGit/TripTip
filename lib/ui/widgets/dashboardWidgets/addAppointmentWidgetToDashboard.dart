
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
  Map<String, dynamic> userdata;
  DocumentReference day;
  Map<String, dynamic>? data;
  AddAppointmentWidgetToDashboard({super.key, required this.day, required this.userdata, this.data});

  _AddAppointmentWidgetToDashboardState createState() =>
      _AddAppointmentWidgetToDashboardState();
}

class _AddAppointmentWidgetToDashboardState extends State<AddAppointmentWidgetToDashboard> {
  final nameOfAppointment = TextEditingController();
  final appointment = TextEditingController();
  var uuid = const Uuid();

  @override
  Widget build(BuildContext context) {
    if(widget.data != null){
      nameOfAppointment.text = widget.data!["title"];
      appointment.text = widget.data!["content"];
    }
    Future<void> createOrAddAppointment() async {
      Map<String, dynamic> data = {
        "type": "appointment",
        "content": appointment.text,
        "title": nameOfAppointment.text,
      };
      DocumentReference by = FirebaseFirestore.instance.collection('users')
      .doc(widget.userdata["uid"]);
      if(widget.data == null){
        await ManageDashboardWidged().addWidget(widget.day, by, data);
      } else {
        await ManageDashboardWidged().updateWidget(widget.day, by, data, widget.data!["key"]);
      }
      if(context.mounted) Navigator.pop(context);
    }

    return Column(children: [
      InputField(
          controller: nameOfAppointment,
          hintText: "Title of Appointment",
          obscureText: false),
      InputField(controller: appointment, hintText: "Appointment", obscureText: false),
      MyButton(
          colors: Colors.blue,
          onTap: () => createOrAddAppointment().onError((error, stackTrace) => {

                print(error.toString()),
                print(stackTrace.toString()),
                print("error"),
                ErrorSnackbar.showErrorSnackbar(context, error.toString())
              }),
          text: widget.data == null ? "Add Appointment to Dashboard" : "Update Appointment")
    
    ]);
  }
}
