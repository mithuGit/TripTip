import 'package:cloud_firestore/cloud_firestore.dart';
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
/*
 Here we are writing a diary for the day before.
  We are using a Quill Editor to write the diary.
*/
class WriteDiaryState extends State<WriteDiary> {
  QuillController _controller = QuillController.basic();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  Future<DocumentSnapshot> createDiary() async {
      if ((await widget.day.collection("diary").get()).docs.isNotEmpty) {
        QuerySnapshot diary =
            await widget.day.collection("diary").limit(1).get();

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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

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
          title: const Text("Write a Diary for Yesterday", style: Styles.title),
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
              try {
                _controller = QuillController(
                    document: Document.fromJson(data["content"]),
                    selection: const TextSelection.collapsed(offset: 0));
              } catch (e) {
                _controller = QuillController.basic();
              }
              _controller.addListener(() async {
                await snapshot.data!.reference.update(
                    {"content": _controller.document.toDelta().toJson(), "lastEdit": DateTime.now()});
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
