import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/widgets/dashboardWidgets/usernameBagageDashboardWidget.dart';
import 'package:internet_praktikum/ui/widgets/dashboardWidgets/votingWidgetItem.dart';

// This class is the widget for the survey
class SurveyWidget extends StatefulWidget {
  final Map<String, dynamic>? data;
  final Map<String, dynamic>? userdata;
  final DocumentReference? day;
  final bool isEditable;

  const SurveyWidget(
      {super.key,
      this.data,
      required this.userdata,
      required this.day,
      required this.isEditable});

  @override
  State<SurveyWidget> createState() => _SurveyWidgetState();
}

class _SurveyWidgetState extends State<SurveyWidget> {
  // This function is called when the user votes
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
      // we first have to check if the user has already voted
      for (int i = 0; i < widgetdata["options"].length; i++) {
        if (widgetdata["options"][i]["voters"] != null) {
          if (widgetdata["options"][i]["voters"]
              .contains(widget.userdata!["uid"])) {
                // and delete him from the list
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
            // here the options are created
            if (widget.data!["options"] != null)
              for (int i = 0; i < widget.data!["options"].length; i++)
                VotingWidgetItem(
                    index: i,
                    data: widget.data!,
                    userdata: widget.userdata,
                    onTap: (bool value) {
                      if (widget.isEditable) {
                        vote(i, value);
                      }
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
