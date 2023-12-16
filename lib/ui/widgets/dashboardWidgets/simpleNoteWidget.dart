import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';
import 'package:internet_praktikum/ui/views/dashboard/scrollview.dart';
import 'package:internet_praktikum/ui/widgets/dashboardWidgets/usernameBagageDashboardWidget.dart';
import 'package:provider/provider.dart';

class SimpleNoteWidget extends StatelessWidget {
  final Map<String, dynamic>? data;

  const SimpleNoteWidget({required this.data});

  @override
  Widget build(BuildContext context) {
    PressdEditButton pressedEditButton = context.watch<PressdEditButton>();
    if(pressedEditButton.pressed) {
      print("pressed edit button....");
    }
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
