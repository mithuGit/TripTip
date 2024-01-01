// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:go_router/go_router.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';

class ReadDiary extends StatefulWidget {
  final DocumentReference day;
  const ReadDiary({super.key, required this.day});
  @override
  ReadDiaryState createState() => ReadDiaryState();
}

class ReadDiaryState extends State<ReadDiary> {
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
          title: const Text("Read Diary", style: Styles.title),
        ),
        body: FutureBuilder<DocumentReference>(
            future: createDiary(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(child: Text("Error in FutureBuilder"));
              }

              return StreamBuilder<DocumentSnapshot>(
                  stream: snapshot.data!.snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Center(child: Text("Error in StremBuilder"));
                    }
                    Map<String, dynamic> data =
                        snapshot.data!.data() as Map<String, dynamic>;
                    _controller = QuillController(
                        document: Document.fromJson(data["content"]),
                        selection: const TextSelection.collapsed(offset: 0));
                    return Expanded(
                      child: QuillEditor.basic(
                        configurations: QuillEditorConfigurations(
                          padding: const EdgeInsets.all(8),
                          controller: _controller,
                          readOnly: true,
                          showCursor: false,
                          enableInteractiveSelection: false,
                          customStyles: DefaultStyles(
                            h1: DefaultTextBlockStyle(
                                TextStyle(
                                    fontSize: 30,
                                    fontFamily: 'fonts/Ubuntu-Bold.ttf',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                                VerticalSpacing(5, 5),
                                VerticalSpacing(5, 5),
                                null),
                            h2: DefaultTextBlockStyle(
                                TextStyle(
                                    fontSize: 30,
                                    fontFamily: 'fonts/Ubuntu-Regular.ttf',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                                VerticalSpacing(5, 5),
                                VerticalSpacing(5, 5),
                                null),
                            h3: DefaultTextBlockStyle(
                                TextStyle(
                                    fontSize: 30,
                                    fontFamily: 'fonts/Ubuntu-Regular.ttf',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                                VerticalSpacing(5, 5),
                                VerticalSpacing(5, 5),
                                null),
                            paragraph: DefaultTextBlockStyle(
                                TextStyle(
                                    fontSize: 30,
                                    fontFamily: 'fonts/Ubuntu-Regular.ttf',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                                VerticalSpacing(5, 5),
                                VerticalSpacing(5, 5),
                                null),
                          ),
                          sharedConfigurations: const QuillSharedConfigurations(
                            locale: Locale('en'),
                          ),
                        ),
                      ),
                    );
                  });
            }));
  }
}
