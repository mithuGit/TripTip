import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';

class InputFieldPasswortOrIcon extends StatefulWidget {
  final dynamic controller;
  final String hintText;
  final bool obscureText;
  final IconData? icon;
  final bool eyeCheckerStatus;
  final bool useSuffixIcon; // Flag to determine whether to use a suffix icon
  final EdgeInsets? margin;

  const InputFieldPasswortOrIcon({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    this.icon,
    required this.eyeCheckerStatus,
    required this.useSuffixIcon,
    this.margin,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _InputFieldPasswortOrIconState createState() =>
      _InputFieldPasswortOrIconState();
}

class _InputFieldPasswortOrIconState extends State<InputFieldPasswortOrIcon> {
  bool _eye = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
      child: TextFormField(
        controller: widget.controller,
        obscureText: widget.eyeCheckerStatus ? _eye : widget.obscureText,
        textInputAction: TextInputAction.next,
        autovalidateMode:
            widget.useSuffixIcon ? AutovalidateMode.onUserInteraction : null,
        validator: widget.useSuffixIcon
            ? (value) => value != null && value.length < 6
                ? 'Enter min. 6 characters '
                : null
            : null,
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
          hintText: widget.hintText,
          hintStyle: Styles.textfieldHintStyle,
          prefixIcon: widget.useSuffixIcon ? null : Icon(widget.icon),
          suffixIcon: widget.useSuffixIcon
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      _eye = !_eye;
                    });
                  },
                  child: Icon(
                    _eye ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
