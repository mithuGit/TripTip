import 'package:flutter/material.dart';

class MyTextFieldeye extends StatefulWidget {
  final controller;
  final String hintText;
  final bool obscureText;

  const MyTextFieldeye({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
  }) : super(key: key);

  @override
  _MyTextFieldeyeState createState() => _MyTextFieldeyeState();
}

class _MyTextFieldeyeState extends State<MyTextFieldeye> {
  bool eyechecker  = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        controller: widget.controller,
        obscureText: eyechecker,
        decoration: InputDecoration(
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey.shade400,
            ),
          ),
          fillColor: Colors.grey.shade200,
          filled: true,
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: Colors.grey[500],
          ),
          suffixIcon: GestureDetector(
            onTap: () {
              setState(() {
                eyechecker = !eyechecker;
              });
            },
            child: Icon(
              eyechecker ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}
