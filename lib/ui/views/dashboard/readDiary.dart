// ignore_for_file: prefer_const_constructors, file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:go_router/go_router.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';
import 'package:internet_praktikum/ui/widgets/centerText.dart';

//this is the ReadDiary class which is used to read the diary
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

  // Since we are using a StreamBuilder we need an extra collection to store the diary
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
                    return const Center(
                        child: CenterText(text: "Error in getting the Diary"));
                  }
                  if (snapshot.data!.data() == null) {
                    return const Center(
                        child: CenterText(text: "No Diary written yet"));
                  }
                  Map<String, dynamic> data =
                      snapshot.data!.data() as Map<String, dynamic>;
                  if (data["content"] == null || data["content"].isEmpty) {
                    return const Center(
                        child: CenterText(text: "No Diary written yet"));
                  }
                  if (data["content"].length == 1 &&
                      data["content"][0]["insert"].length == 1) {
                    debugPrint(data["content"][0]["insert"]);
                    return const Center(
                        child: CenterText(text: "No Diary written yet"));
                  }

                  // This block is used to prevent null error
                  try {
                    _controller = QuillController(
                        document: Document.fromJson(data["content"]),
                        selection: const TextSelection.collapsed(offset: 0));
                  } catch (e) {
                    _controller = QuillController.basic();
                  }

                  // here we use the Quill Text Editor to Edit a Text

                  return Column(
                    children: [
                      if(data["lastEdit"] != null)
                      Text(calculateDiaryTime(data["lastEdit"].toDate()), style: Styles.descriptionofwidget,),
                      const SizedBox(height: 10),
                      Expanded(
                        child: QuillEditor.basic(
                          configurations: QuillEditorConfigurations(
                            padding: const EdgeInsets.all(8),
                            controller: _controller,
                            readOnly: true,
                            showCursor: false,
                            enableInteractiveSelection: false,
                            sharedConfigurations: const QuillSharedConfigurations(
                              locale: Locale('en'),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                });
          }),
    );
  }
}
// is used to show when the Diaray has been modified the last time
String calculateDiaryTime(DateTime lastEdit) {
  final DateTime now = DateTime.now();
  final int differenceInDays = now.difference(lastEdit).inDays;
  
  
  if(differenceInDays == 0) {
    final int differenceInHours = now.difference(lastEdit).inHours;
    if(differenceInHours == 0) {
      final int differenceInMinutes = now.difference(lastEdit).inMinutes;
      return "$differenceInMinutes minutes ago";
    } else {
      return "$differenceInHours hours ago";
    }
  } else if(differenceInDays == 1) {
    return "Yesterday";
  } else if(differenceInDays < 7) {
    return "$differenceInDays days ago";
  } else if(differenceInDays < 30) {
    return "${(differenceInDays/7).floor()} weeks ago";
  } else if(differenceInDays < 365) {
    return "${(differenceInDays/30).floor()} months ago";
  } else {
    return "${(differenceInDays/365).floor()} years ago";
  }
}
