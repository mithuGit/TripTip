import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/core/services/manageDashboardWidget.dart';
import 'package:internet_praktikum/ui/widgets/errorSnackbar.dart';
import 'package:internet_praktikum/ui/widgets/inputfield.dart';
import 'package:internet_praktikum/ui/widgets/my_button.dart';
import 'package:uuid/uuid.dart';

// ignore: must_be_immutable
class AddSurveyWidgetToDashboard extends StatefulWidget {
  DocumentReference day;
  Map<String, dynamic> userdata;
  Map<String, dynamic>? data;
  AddSurveyWidgetToDashboard({super.key, required this.day, required this.userdata, this.data});

  // ignore: library_private_types_in_public_api
  _AddSurveyWidgetToDashboardState createState() =>
      _AddSurveyWidgetToDashboardState();
}

class _AddSurveyWidgetToDashboardState
    extends State<AddSurveyWidgetToDashboard> {
  final nameofSurvey = TextEditingController();
  final survey = TextEditingController();
  final option1 = TextEditingController();
  final options2 = TextEditingController();
  final options3 = TextEditingController();
  final options4 = TextEditingController();

  var uuid = const Uuid();

  @override
  Widget build(BuildContext context) {
    if(widget.data != null){
      nameofSurvey.text = widget.data!["title"];
      survey.text = widget.data!["content"];
      option1.text = widget.data!["options"][0];
      options2.text = widget.data!["options"][1];
      options3.text = widget.data!["options"][2];
      options4.text = widget.data!["options"][3];
    }
    Future<void> createorUpdateSurvey() async {
      print(widget.userdata);
      Map<String, dynamic> data = {
        "type": "survey",
        "content": survey.text,
        "title": nameofSurvey.text,
        // hier muss noch die Anzahl an Member gespeichert werden
        // und in Options soll die Anzahl an Stimmen gespeichert werden
        "options": [option1.text, options2.text, options3.text, options4.text],
      };
      DocumentReference by = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userdata["uid"]);
      if(widget.data == null){
        await ManageDashboardWidged().addWidget(widget.day, by, data);
      } else {
        await ManageDashboardWidged().updateWidget(widget.day, by, data, widget.data!["key"]);
      }      
      if(context.mounted) Navigator.pop(context);
    }
    return Column(children: [
      const Text("Title of Survey"),
      InputField(
          controller: nameofSurvey,
          hintText: "Title of Survey",
          obscureText: false),
      InputField(controller: survey, hintText: "Survey", obscureText: false),
      InputField(
          controller: option1, hintText: "First Options", obscureText: false),
      InputField(
          controller: options2, hintText: "Second Option", obscureText: false),
      InputField(
          controller: options3, hintText: "Third Option", obscureText: false),
      InputField(
          controller: options4, hintText: "Fourth Option", obscureText: false),
      MyButton(
          colors: Colors.blue,
          onTap: () => createorUpdateSurvey().onError((error, stackTrace) => {
                print(error.toString()),
                print(stackTrace.toString()),
                print("error"),
                ErrorSnackbar.showErrorSnackbar(context, error.toString())
              }),
          text: widget.data == null ? "Create Survey" : "Update Survey")
    ]);
  }
}
