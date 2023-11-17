import 'package:flutter/material.dart';

import '../styles/Styles.dart';

class InputField extends StatelessWidget {
  final String hintText;
  final controller;
  final bool obscureText;
  final EdgeInsets? margin;

  const InputField({
      super.key,
      required this.hintText,
      this.controller,
      required this.obscureText,
      this.margin
  });

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double screenHeight = screenSize.height;
    double screenWidth = screenSize.width;

    return Container(
      margin: margin,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
            borderRadius: BorderRadius.circular(11.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(11.0),
          ),
          fillColor: Colors.white,
          filled: true,
          contentPadding: const EdgeInsets.only(top: 16, bottom: 16, left: 14, right: 14),
          hintText: hintText,
          hintStyle: Styles.textfieldHintStyle
        ),
      ),
    );
  }
}
