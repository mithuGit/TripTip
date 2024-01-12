import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/widgets/dashboardWidgets/usernameBagageDashboardWidget.dart';
import 'package:internet_praktikum/ui/widgets/dashboardWidgets/voting_poll.dart';

class SurveyWidget extends StatefulWidget {
  final Map<String, dynamic>? data;
  Map<String, dynamic>? userdata;
  DocumentReference? day;

  SurveyWidget(
      {super.key, this.data, required this.userdata, required this.day});

  @override
  State<SurveyWidget> createState() => _SurveyWidgetState();
}

class _SurveyWidgetState extends State<SurveyWidget> {
  void vote(int index, bool value) async {
    Map<String, dynamic> widgetdata = widget.data!;
    if (widgetdata["allowmultipleanswers"] == true) {
      if (widgetdata["options"][index]["voters"] == null) {
        widgetdata["options"][index]["voters"] = [];
      }
      if (value) {
        if (!widgetdata["options"][index]["voters"]
            .contains(widget.userdata!["uid"])) {
          widgetdata["options"][index]["voters"].add(widget.userdata!["uid"]);
        }
      } else {
        if (widgetdata["options"][index]["voters"]
            .contains(widget.userdata!["uid"])) {
          widgetdata["options"][index]["voters"]
              .remove(widget.userdata!["uid"]);
        }
      }
    } else {
      for (int i = 0; i < widgetdata["options"].length; i++) {
        if (widgetdata["options"][i]["voters"] != null) {
          if (widgetdata["options"][i]["voters"]
              .contains(widget.userdata!["uid"])) {
            widgetdata["options"][i]["voters"].remove(widget.userdata!["uid"]);
          }
        }
      }
      if (value) {
        if (widgetdata["options"][index]["voters"] == null) {
          widgetdata["options"][index]["voters"] = [];
        }
        widgetdata["options"][index]["voters"].add(widget.userdata!["uid"]);
      }
    }

    Map<String, dynamic> dayData =
        (await widget.day!.get()).data() as Map<String, dynamic>;
    Map<String, dynamic> widgets = dayData['active'];
    widgets[widgetdata["key"]] = widgetdata;
    await widget.day!.update({"active": widgets});
  }

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
                VotingPoll(
                    index: i,
                    data: widget.data!,
                    day: widget.day,
                    userdata: widget.userdata,
                    onTap: (bool value) {
                      vote(i, value);
                    }),
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
