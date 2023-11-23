import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../styles/Styles.dart';

class InputField extends StatelessWidget {
  final String hintText;
  final dynamic controller;
  final bool obscureText;
  final EdgeInsets? margin;

  const InputField(
      {super.key,
      required this.hintText,
      this.controller,
      required this.obscureText,
      this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        //nur Groß und klein Buchstaben erlauben
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp('[a-zA-z]')),
        ],
        decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(11.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(11.0),
            ),
            fillColor: Colors.white,
            filled: true,
            contentPadding:
                const EdgeInsets.only(top: 16, bottom: 16, left: 14, right: 14),
            hintText: hintText,
            hintStyle: Styles.textfieldHintStyle),
      ),
    );
  }
}
