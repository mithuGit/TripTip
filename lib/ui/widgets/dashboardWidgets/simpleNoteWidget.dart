// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';
import 'package:internet_praktikum/ui/widgets/dashboardWidgets/usernameBagageDashboardWidget.dart';

class SimpleNoteWidget extends StatefulWidget {
  final Map<String, dynamic>? data;
  const SimpleNoteWidget({super.key, required this.data});

  @override
  SimpleNoteWidgetState createState() => SimpleNoteWidgetState();
}

// This class is the widget for the simple note
// not much to say here
class SimpleNoteWidgetState extends State<SimpleNoteWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(widget.data!["content"], style: Styles.noteTextstyle),
        UsernameBagageDashboardWidget(data: widget.data!),
      ],
    );
  }
}
