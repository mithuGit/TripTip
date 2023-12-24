import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/widgets/dashboardWidgets/usernameBagageDashboardWidget.dart';
import 'package:internet_praktikum/ui/widgets/dashboardWidgets/voting_poll.dart';

class SurveyWidget extends StatefulWidget {
  final Map<String, dynamic>? data;
  Map<String, dynamic>? userdata;
  DocumentReference? day;

  SurveyWidget({super.key, this.data, required this.userdata, required this.day});

  @override
  State<SurveyWidget> createState() => _SurveyWidgetState();
}

class _SurveyWidgetState extends State<SurveyWidget> {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (widget.data!["options"] != null)
              for (int i = 0; i < widget.data!["options"].length; i++)
                VotingPoll(index: i, data: widget.data!, day: widget.day, userdata: widget.userdata),
            const SizedBox(
              height: 2,
            ),
            UsernameBagageDashboardWidget(data: widget.data)
          ],
        ),
      ),
    ));
  }
}
