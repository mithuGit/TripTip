import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:go_router/go_router.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';

class WriteDiary extends StatefulWidget {
  final DocumentReference day;
  const WriteDiary({super.key, required this.day});
  @override
  WriteDiaryState createState() => WriteDiaryState();
}

class WriteDiaryState extends State<WriteDiary> {
  QuillController _controller = QuillController.basic();
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Future<DocumentSnapshot> createDiary() async {
      if ((await widget.day.collection("diary").get()).docs.isNotEmpty) {
        QuerySnapshot diary =
            await widget.day.collection("diary").limit(1).get();
        diary.docs[0];

        return await diary.docs[0].reference.get();
      } else {
        Map<String, dynamic> dayData =
            (await widget.day.get()).data() as Map<String, dynamic>;
        Map<String, dynamic> active = dayData["active"];
        active["diary"]["written"] = true;
        await widget.day.update({"active": active});
        DocumentReference diary = await widget.day.collection("diary").add({
          "content": [
            {"insert": ""}
          ]
        });
        return await diary.get();
      }
    }

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              context.go("/");
            },
            icon: const Icon(Icons.arrow_back_ios),
            color: Colors.black,
          ),
          centerTitle: true,
          title: const Text("Write Diary", style: Styles.title),
        ),
        body: FutureBuilder<DocumentSnapshot>(
            future: createDiary(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(child: Text("Error"));
              }
              Map<String, dynamic> data =
                  snapshot.data!.data() as Map<String, dynamic>;
             /*  _controller = QuillController(
                  document: Document.fromJson(data["content"]),
                  selection: const TextSelection.collapsed(offset: 0)); */
              _controller.addListener(() {
                snapshot.data!.reference.update(
                    {"content": _controller.document.toDelta().toJson()});
              });
              return Column(children: [
                QuillToolbar.simple(
                    configurations: QuillSimpleToolbarConfigurations(
                  controller: _controller,
                  showFontFamily: false,
                  showLink: false,
                  showFontSize: false,
                  showColorButton: false,
                  showListCheck: false,
                  showSubscript: false,
                  showSuperscript: false,
                  showSearchButton: false,
                  showClearFormat: false,
                  showInlineCode: false,
                  showCodeBlock: false,
                )),
                Expanded(
                  child: QuillEditor.basic(
                    configurations: QuillEditorConfigurations(
                      padding: const EdgeInsets.all(8.0),
                      controller: _controller,
                      readOnly: false,
                      sharedConfigurations: const QuillSharedConfigurations(
                        locale: Locale('en'),
                      ),
                    ),
                  ),
                )
              ]);
            }));
  }
}
