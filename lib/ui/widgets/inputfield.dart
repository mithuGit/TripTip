import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../styles/Styles.dart';

class InputField extends StatelessWidget {
  final String hintText;
  final dynamic controller;
  final bool obscureText;
  final EdgeInsets? margin;
  final FocusNode? focusNode;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final bool? multiline;
  final bool? numberField;
  final bool? readOnly;
  final bool? textAlignCenter;
  final String? Function(String?)? validator;

  const InputField(
      {super.key,
      required this.hintText,
      this.controller,
      required this.obscureText,
      this.margin,
      this.multiline,
      this.focusNode,
      this.borderColor,
      this.focusedBorderColor,
      this.numberField,
      this.validator,
      this.textAlignCenter,
      this.readOnly});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: TextFormField(
        textAlign: textAlignCenter != null ? TextAlign.center : TextAlign.start,
        readOnly: readOnly == true,
        controller: controller,
        obscureText: obscureText,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: validator,
        style: Styles.inputField,
        focusNode: focusNode,
        cursorColor: Colors.grey.shade400,
        cursorWidth: 1.5,
        maxLines: multiline == true ? 5 : 1,
        keyboardType: multiline == true
            ? TextInputType.multiline
            : numberField == true
                ? TextInputType.number
                : TextInputType.text,
        decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderSide: borderColor != null
                  ? BorderSide(color: borderColor!)
                  : const BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(11.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: focusedBorderColor != null
                  ? BorderSide(color: focusedBorderColor!)
                  : BorderSide(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(11.0),
            ),
            fillColor: readOnly == true ? Colors.grey[300] : Colors.white,
            filled: true,
            contentPadding:
                const EdgeInsets.only(top: 16, bottom: 16, left: 14, right: 14),
            hintText: hintText,
            hintStyle: Styles.textfieldHintStyle),
      ),
    );
  }
}
