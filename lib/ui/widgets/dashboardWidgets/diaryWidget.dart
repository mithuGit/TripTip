import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';

class DiaryWidget extends StatefulWidget {
  final Map<String, dynamic>? data;
  final DocumentReference? day;
  const DiaryWidget({super.key, required this.data, required this.day});
  @override
  DiaryWidgetState createState() => DiaryWidgetState();
}

class DiaryWidgetState extends State<DiaryWidget> {
  FirebaseAuth auth = FirebaseAuth.instance;
  bool isInMoment = false;
  bool isOver = false;
  Timer? timer;
  bool isWriter = false;

  String? writerPrename;
  String? writerLastname;

  @override
  void initState() {
    super.initState();
    checkIfInMoment();
    timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      checkIfInMoment();
    });
    if (widget.data!["writer"] != null) {
      setState(() {
        writerPrename = widget.data!["writerPrename"];
        writerLastname = widget.data!["writerLastname"];
        if ((widget.data!["writer"] as DocumentReference).id ==
            auth.currentUser!.uid) {
          isWriter = true;
        }
      });
    }
  }

  void checkIfInMoment() {
    setState(() {
      if (widget.data!["diaryStartTime"] != null &&
          widget.data!["diaryEndTime"] != null) {
        if (widget.data!["diaryStartTime"].toDate().isBefore(DateTime.now()) &&
            widget.data!["diaryEndTime"].toDate().isAfter(DateTime.now())) {
          isInMoment = true;
        } else if (widget.data!["diaryEndTime"]
            .toDate()
            .isBefore(DateTime.now())) {
          isInMoment = false;
          isOver = true;
        } else {
          isOver = false;
          isInMoment = false;
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (timer != null) timer!.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isInMoment && writerPrename != null && writerLastname != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (isWriter) ...[
                const Text("Write your Diary", style: Styles.noteTextstyle),
                IconButton(
                    onPressed: () {
                      GoRouter.of(context)
                          .go('/diary/write', extra: widget.day);
                    },
                    icon: const Icon(
                      Icons.edit,
                      size: 30,
                      color: Colors.white,
                    )),
              ] else ...[
                Text(
                    "$writerPrename $writerLastname is writing a Diary for the Day!",
                    style: Styles.noteTextstyle),
                IconButton(
                    onPressed: () {
                      GoRouter.of(context).go('/diary/read', extra: widget.day);
                    },
                    icon: const Icon(
                      Icons.preview,
                      size: 30,
                      color: Colors.white,
                    )),
              ]
            ],
          )
        ] else if (!isInMoment && isOver) ...[
          const Text("Diary Moment is already Over!",
              style: Styles.noteTextstyle),
          if (widget.data!["written"] == null &&
              writerPrename != null &&
              writerLastname != null) ...[
            Text(
                "Blame $writerPrename $writerLastname for not writing your diary!",
                style: Styles.noteTextstyle),
          ] else if (writerPrename != null && writerLastname != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    "$writerPrename $writerLastname has written\na Diary for the Day!",
                    style: Styles.noteTextstyle),
                IconButton(
                    onPressed: () {
                      GoRouter.of(context).go('/diary/read', extra: widget.day);
                    },
                    icon: const Icon(
                      Icons.preview,
                      size: 30,
                      color: Colors.white,
                    )),
              ],
            )
          ]
        ] else ...[
          const Text(
              "Soon someone randomly will be\nchoosed to write a diary of the Day!\nYou will be notifiyed if you are the lucky one!",
              style: Styles.noteTextstyle),
        ]
      ],
    );
  }
}
