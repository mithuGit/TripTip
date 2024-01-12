// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';

class MemberFinance extends StatelessWidget {
  final String title;
  const MemberFinance({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 16, bottom: 16, left: 14, right: 14),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade400,
        ),
        borderRadius: BorderRadius.circular(11.0),
        color: Colors.white,
      ),
      child: Text(title, style: Styles.inputField),
    );
  }
}
