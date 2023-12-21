import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/core/services/manageDashboardWidget.dart';
import 'package:internet_praktikum/ui/views/dashboard/dashboard.dart';
import 'package:internet_praktikum/ui/widgets/errorSnackbar.dart';
import 'package:internet_praktikum/ui/widgets/inputfield.dart';
import 'package:internet_praktikum/ui/widgets/my_button.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class AddNoteWidgetToDashboard extends StatefulWidget {
  Map<String, dynamic> userdata;
  DocumentReference day;
  Map<String, dynamic>? data;
  @override
  AddNoteWidgetToDashboard(
      {super.key, required this.day, required this.userdata, this.data});

  _AddNoteWidgetToDashboardState createState() =>
      _AddNoteWidgetToDashboardState();
}

class _AddNoteWidgetToDashboardState extends State<AddNoteWidgetToDashboard> {
  final nameOfNote = TextEditingController();
  final note = TextEditingController();
  var uuid = Uuid();
  @override void initState() {
    super.initState();
    if(widget.data != null){
      nameOfNote.text = widget.data!["title"];
      note.text = widget.data!["content"];
    }
  }

  @override
  Widget build(BuildContext context) {
    Future<void> createNote() async {
      print(widget.userdata);
      Map<String, dynamic> data = {
        "type": "note",
        "content": note.text,
        "title": nameOfNote.text,
      };
      DocumentReference by = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userdata!["uid"]);
      await ManageDashboardWidged().addWidget(widget.day!, by, data);
    }
    Future<void> updateNote() async {
      print(widget.userdata);
      Map<String, dynamic> data = {
        "content": note.text,
        "title": nameOfNote.text,
      };
      DocumentReference by = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userdata!["uid"]);
      await ManageDashboardWidged().updateWidget(widget.day!,by, data, widget.data!["key"]);
    }

    return Column(children: [
      InputField(
          controller: nameOfNote,
          hintText: "Title of Note",
          obscureText: false),
      InputField(controller: note, hintText: "Note", obscureText: false),
      if (widget.data == null) // creating mode when no data is passed
        MyButton(
            colors: Colors.blue,
            onTap: () => createNote().onError((error, stackTrace) => {
                  print(error.toString()),
                  print(stackTrace.toString()),
                  print("error"),
                  ErrorSnackbar.showErrorSnackbar(context, error.toString())
                }),
            text: "Create Note")
      else // editing mode when data is passed
        MyButton(
            colors: Colors.blue,
            onTap: () => updateNote().onError((error, stackTrace) => {
                  print(error.toString()),
                  print(stackTrace.toString()),
                  print("error"),
                  ErrorSnackbar.showErrorSnackbar(context, error.toString())
                }),
            text: "Update Note")
    ]);
  }
}
