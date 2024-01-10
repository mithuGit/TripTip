import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';

class CenterText extends StatelessWidget {
  final String text;
  const CenterText({super.key, required this.text});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(34.5),
          color: const Color.fromARGB(255, 43, 43, 43).withOpacity(0.90),
        ),
        child: Text(
          text,
          style: Styles.centerText,
        ),
      ),
    );
  }
}
