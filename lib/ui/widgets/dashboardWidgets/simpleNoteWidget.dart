import 'package:flutter/material.dart';

class SimpleNoteWidget extends StatelessWidget {
  final Map<String, dynamic>? data;

  const SimpleNoteWidget({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(data!["content"]),
    );
  }
}
