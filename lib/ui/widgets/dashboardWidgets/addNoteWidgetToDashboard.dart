import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/core/services/manageDashboardWidget.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';
import 'package:internet_praktikum/ui/widgets/errorSnackbar.dart';
import 'package:internet_praktikum/ui/widgets/inputfield.dart';
import 'package:internet_praktikum/ui/widgets/modalButton.dart';
import 'package:internet_praktikum/ui/widgets/my_button.dart';
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
  var uuid = const Uuid();
  @override
  void initState() {
    super.initState();
    if (widget.data != null) {
      nameOfNote.text = widget.data!["title"];
      note.text = widget.data!["content"];
    }
  }

  @override
  Widget build(BuildContext context) {
    Future<void> createOrUpdateNote() async {
      if (note.text.isEmpty || nameOfNote.text.isEmpty) {
        throw Exception("Please enter a title and a note");
      }
      Map<String, dynamic> data = {
        "type": "note",
        "content": note.text,
        "title": nameOfNote.text,
      };
      DocumentReference by = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userdata!["uid"]);
      if (widget.data == null) {
        await ManageDashboardWidged()
            .addWidget(day: widget.day!, user: by, data: data);
      } else {
        await ManageDashboardWidged()
            .updateWidget(widget.day!, by, data, widget.data!["key"]);
      }
      if (context.mounted) Navigator.pop(context);
    }

    return Column(children: [
      InputField(
          controller: nameOfNote,
          hintText: "Title of Note",
          borderColor: Colors.grey.shade400,
          focusedBorderColor: const Color.fromARGB(255, 84, 113, 255),
          obscureText: false),
      const SizedBox(
        height: 10,
      ),
      InputField(
          controller: note,
          hintText: "Note",
          borderColor: Colors.grey.shade400,
          multiline: true,
          focusedBorderColor: const Color.fromARGB(255, 84, 113, 255),
          obscureText: false),
      const SizedBox(
        height: 10,
      ), // creating mode when no data is passed
      MyButton(
          borderColor: Colors.black,
          textStyle: Styles.buttonFontStyleModal,
          onTap: () => createOrUpdateNote().onError((error, stackTrace) => {
                print(error.toString()),
                print(stackTrace.toString()),
                print("error"),
                ErrorSnackbar.showErrorSnackbar(context, error.toString())
              }),
          text: widget.data == null ? "Create Note" : "Update Note")
    ]);
  }
}
