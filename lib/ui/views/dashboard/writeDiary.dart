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
  String diaryEntry = '';
  QuillController _controller = QuillController.basic();
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Future<DocumentReference> createDiary() async {
      if ((await widget.day.collection("diary").get()).docs.isNotEmpty) {
        QuerySnapshot diary =
            await widget.day.collection("diary").limit(1).get();
        diary.docs[0];
        return diary.docs[0].reference;
      } else {
        DocumentReference diary =
            await widget.day.collection("diary").add({"content": {}});
        return diary;
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
        body: FutureBuilder<DocumentReference>(
            future: createDiary(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(child: Text("Error"));
              }
              snapshot.data!.snapshots().listen((event) {
                debugPrint("sad");
                _controller = QuillController(
                    selection: TextSelection.collapsed(offset: 0),
                    document: Document.fromJson(jsonDecode(
                        (event.data()! as Map<String, dynamic>)["content"])));
              });
              _controller.addListener(() {
                print("kkllklk");
                snapshot.data!.set(
                    {"content": _controller.document.toDelta().toJson()},
                    SetOptions(merge: true));
              });
              return Column(children: [
                QuillToolbar.simple(
                  configurations: QuillSimpleToolbarConfigurations(
                    controller: _controller,
                    sharedConfigurations: const QuillSharedConfigurations(
                      locale: Locale('en'),
                    ),
                  ),
                ),
                Expanded(
                  child: QuillEditor.basic(
                    configurations: QuillEditorConfigurations(
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
