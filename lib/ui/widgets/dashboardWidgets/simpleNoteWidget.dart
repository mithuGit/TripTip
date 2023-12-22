import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';
import 'package:internet_praktikum/ui/widgets/dashboardWidgets/usernameBagageDashboardWidget.dart';

class SimpleNoteWidget extends StatefulWidget {
  final Map<String, dynamic>? data;
  SimpleNoteWidget({required this.data});

  @override
  _SimpleNoteWidgetState createState() => _SimpleNoteWidgetState();
}

class _SimpleNoteWidgetState extends State<SimpleNoteWidget> {
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
