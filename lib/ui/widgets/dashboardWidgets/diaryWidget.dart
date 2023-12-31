import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';

class DiaryWidget extends StatelessWidget {
  final Map<String, dynamic>? data;
  final DocumentReference? day;
  const DiaryWidget({super.key, required this.data, required this.day});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("write your Diary", style: Styles.noteTextstyle),
        IconButton(
            onPressed: () {
              GoRouter.of(context).go('/diary', extra: day);
            },
            icon: const Icon(
              Icons.edit,
              size: 30,
              color: Colors.white,
            )),
      ],
    );
  }
}
