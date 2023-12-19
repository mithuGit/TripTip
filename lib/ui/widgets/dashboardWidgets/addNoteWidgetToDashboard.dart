import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/core/services/addWidget.dart';
import 'package:internet_praktikum/ui/views/main_pages/dashboard.dart';
import 'package:internet_praktikum/ui/widgets/errorSnackbar.dart';
import 'package:internet_praktikum/ui/widgets/inputfield.dart';
import 'package:internet_praktikum/ui/widgets/my_button.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class AddNoteWidgetToDashboard extends StatefulWidget {
  Map<String, dynamic> userdata;
  DocumentReference day;
  @override
  AddNoteWidgetToDashboard({super.key, required this.day, required this.userdata});

  _AddNoteWidgetToDashboardState createState() =>
      _AddNoteWidgetToDashboardState();
}

class _AddNoteWidgetToDashboardState extends State<AddNoteWidgetToDashboard> {
  final nameOfNote = TextEditingController();
  final note = TextEditingController();
  var uuid = Uuid();

  @override
  Widget build(BuildContext context) {
    if (widget.day == null) {
      return Text("no userdata");
    }

    Future<void> createNote() async {
      print(widget.userdata);
      Map<String, dynamic> data = {
        "type": "note",
        "content": note.text,
        "title": nameOfNote.text,
      };
      DocumentReference by = FirebaseFirestore.instance.collection('users').doc(widget.userdata!["uid"]);
      await AddWidget().addWidget(widget.day!, by, data);
    }

    return Column(children: [
      InputField(
          controller: nameOfNote,
          hintText: "Title of Note",
          obscureText: false),
      InputField(controller: note, hintText: "Note", obscureText: false),
      MyButton(
          colors: Colors.blue,
          onTap: () => createNote().onError((error, stackTrace) => {
                print(error.toString()),
                print(stackTrace.toString()),
                print("error"),
                ErrorSnackbar.showErrorSnackbar(context, error.toString())
              }),
          text: "Create Note")
    ]);
  }
}
