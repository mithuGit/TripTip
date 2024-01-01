import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
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
  bool isInMoment = false;
  bool isOver = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    checkIfInMoment();
    timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      checkIfInMoment();
    });
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (isInMoment) ...[
          Text("write your Diary", style: Styles.noteTextstyle),
          IconButton(
              onPressed: () {
                GoRouter.of(context).go('/diary/write', extra: widget.day);
              },
              icon: const Icon(
                Icons.edit,
                size: 30,
                color: Colors.white,
              )),
        ] else if (!isInMoment && isOver) ...[
          Text("Diary Moment is already Over", style: Styles.noteTextstyle)
        ] else ...[
          Text(
              "Soon someone randomly will be\nchoosed to write a diary of the Day!\nYou will be notifiyed if you are the lucky one!",
              style: Styles.noteTextstyle),
        ]
      ],
    );
  }
}
