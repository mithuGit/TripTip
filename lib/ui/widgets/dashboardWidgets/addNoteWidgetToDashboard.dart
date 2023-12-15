import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/core/services/addWidget.dart';
import 'package:internet_praktikum/ui/widgets/errorSnackbar.dart';
import 'package:internet_praktikum/ui/widgets/inputfield.dart';
import 'package:internet_praktikum/ui/widgets/my_button.dart';
import 'package:uuid/uuid.dart';



class AddNoteWidgetToDashboard extends StatefulWidget {
  @override
  DocumentReference<Object?> day;
  AddNoteWidgetToDashboard({super.key, required this.day});

  _AddNoteWidgetToDashboardState createState() =>
      _AddNoteWidgetToDashboardState();
}

class _AddNoteWidgetToDashboardState extends State<AddNoteWidgetToDashboard> {
  final nameOfNote = TextEditingController();
  final note = TextEditingController();
  var uuid = Uuid();

  Future<void> createNote() async {
    Map<String, dynamic> data = {
      "type": "note",
      "content": note.text,
      "title": nameOfNote.text
    };
    await AddWidget().addWidget(widget.day, widget.day, data);
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text("Title of Note"),
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
