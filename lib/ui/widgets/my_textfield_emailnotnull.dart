import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';

class MyTextFieldemailnotnull extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final EdgeInsets? margin;

  const MyTextFieldemailnotnull({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    this.margin,
  }) : super(key: key);

  bool isValidEmail(String email) {
    String emailRegex =
        r'^[\w-]+(\.[\w-]+)*@([a-z\d-]+(\.[a-z\d-]+)*?\.[a-z]{2,6}|(\d{1,3}\.){3}\d{1,3})$';
    RegExp regex = RegExp(emailRegex);
    return regex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: (value) {
          if (hintText == 'Email') {
            // Validierung für die E-Mail-Adresse
            if (value == null || value.isEmpty) {
              return 'please enter a email adress';
            } else if (!isValidEmail(value)) {
              return 'please enter an valid email adress';
            }
          }
          return null;
        },
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
          contentPadding: const EdgeInsets.only(top: 16, bottom: 16, left: 14, right: 14),
          hintText: hintText,
          hintStyle: Styles.textfieldHintStyle
        ),
      ),
    );
  }
}
