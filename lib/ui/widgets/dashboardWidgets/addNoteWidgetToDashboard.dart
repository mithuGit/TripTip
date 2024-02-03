// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/core/services/manageDashboardWidget.dart';
import 'package:internet_praktikum/core/services/map_service.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';
import 'package:internet_praktikum/ui/widgets/errorSnackbar.dart';
import 'package:internet_praktikum/ui/widgets/inputfield.dart';
import 'package:internet_praktikum/ui/widgets/my_button.dart';
import 'package:uuid/uuid.dart';

// ignore: must_be_immutable
class AddNoteWidgetToDashboard extends StatefulWidget {
  Map<String, dynamic> userdata;
  DocumentReference day;
  Map<String, dynamic>? data;
  Place? place;
  @override
  AddNoteWidgetToDashboard(
      {super.key,
      required this.day,
      required this.userdata,
      this.data,
      this.place});

  @override
  // ignore: library_private_types_in_public_api
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
    getPlaceDetails();
    if (widget.data != null) {
      nameOfNote.text = widget.data!["title"];
      note.text = widget.data!["content"];
    }
  }

  void getPlaceDetails() {
    if (widget.place != null) {
      nameOfNote.text = widget.place!.name;
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
          .doc(widget.userdata["uid"]);
      if (widget.data == null) {
        await ManageDashboardWidged()
            .addWidget(day: widget.day, user: by, data: data);
      } else {
        await ManageDashboardWidged()
            .updateWidget(widget.day, by, data, widget.data!["key"]);
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
      /*if (widget.place != null) ...[
        const SizedBox(height: 10),
        Text(
          "Is bound to location: ${widget.place!.name}",
          style: Styles.inputField,
          textAlign: TextAlign.left,
        ),
        const SizedBox(height: 20),
      ],*/
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
