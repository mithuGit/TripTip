import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';
import 'package:internet_praktikum/ui/widgets/dashboardWidgets/usernameBagageDashboardWidget.dart';

class SimpleNoteWidget extends StatelessWidget {
  final Map<String, dynamic>? data;

  const SimpleNoteWidget({required this.data});

  @override
  Widget build(BuildContext context) {
    return 
    Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(data!["content"], style: Styles.noteTextstyle),
        UsernameBagageDashboardWidget(data: data!),
      ],
    );
  }
}
