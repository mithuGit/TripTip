// ignore: file_names
import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';

class MemberMoney extends StatelessWidget {
  final dynamic controller;
  const MemberMoney({super.key, this.controller});

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
      child: TextFormField(
        controller: controller,
        style: Styles.inputField,
        cursorColor: Colors.grey.shade400,
        cursorWidth: 1.5,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(11.0),
            ),
            focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Color.fromARGB(255, 84, 113, 255)),
              borderRadius: BorderRadius.circular(11.0),
            ),
            fillColor: Colors.white,
            filled: true,
            contentPadding:
                const EdgeInsets.only(top: 16, bottom: 16, left: 14, right: 14),
           ),
      ),
    );
  }
}