import 'package:flutter/material.dart';

import '../styles/Styles.dart';

class InputField extends StatelessWidget {
  final String hintText;
  final controller;
  final bool obscureText;

  const InputField(
      {super.key,
      required this.hintText,
      this.controller,
      required this.obscureText});

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double screenHeight = screenSize.height;
    double screenWidth = screenSize.width;

    return Container(
     // width: screenWidth * 0.814,
      //height: screenHeight * 0.45,
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
          hintText: hintText,
          hintStyle: Styles.textfieldHintStyle
        ),
      ),
    );
  }
}
