import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class VotingPoll extends StatefulWidget {
  final Map<String, dynamic> data;
  final int index;
  DocumentReference? day;
  Map<String, dynamic>? userdata;
  VotingPoll(
      {super.key,
      required this.data,
      required this.index,
      required this.userdata,
      required this.day});

  @override
  State<VotingPoll> createState() => _VotingPollState();
}

class _VotingPollState extends State<VotingPoll> {
  bool isClicked = false;
  int? numberOfVoters;
  @override
  void initState() {
    super.initState();
    Map<String, dynamic> voteelement = widget.data["options"][widget.index];
    if (voteelement["voters"] != null) {
      if (voteelement["voters"].contains(widget.userdata!["uid"])) {
        setState(() {
          isClicked = true;
        });
      }
    }
  }

  int getNumberOfVoters() {
    Map<String, dynamic> voteelement = widget.data["options"][widget.index];
    if (voteelement["voters"] != null) {
      return voteelement["voters"].length;
    } else {
      return 0;
    }
  }

  int getNumberOfUsers() {
    return widget.userdata!["numberofusers"];
  }

  double getPercentage() {
    return getNumberOfVoters() / getNumberOfUsers();
  }

  void vote() async {
    Map<String, dynamic> voteelement = widget.data["options"][widget.index];
    Map<String, dynamic> widgetdata = widget.data;

    if (voteelement["voters"] == null) {
      voteelement["voters"] = [];
    }
    voteelement["voters"].add(widget.userdata!["uid"]);
    Map<String, dynamic> dayData =
        (await widget.day!.get()).data() as Map<String, dynamic>;
    Map<String, dynamic> widgets = dayData['active'];
    widgetdata["options"][widget.index] = voteelement;
    widgets[widget.data["key"]] = widgetdata;
    await widget.day!.update({'active': widgets});
  }

  void unvote() async {
    Map<String, dynamic> voteelement = widget.data["options"][widget.index];
    Map<String, dynamic> widgetdata = widget.data;

    if (voteelement["voters"] == null) {
      voteelement["voters"] = [];
    }
    voteelement["voters"].remove(widget.userdata!["uid"]);
    Map<String, dynamic> dayData =
        (await widget.day!.get()).data() as Map<String, dynamic>;
    Map<String, dynamic> widgets = dayData['active'];
    widgetdata["options"][widget.index] = voteelement;
    widgets[widget.data["key"]] = widgetdata;
    await widget.day!.update({'active': widgets});
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            if (isClicked) {
              unvote();
            } else {
              vote();
            }
          },
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: isClicked
                ? Image.asset("assets/votingbutton_pic/on.png")
                : Image.asset("assets/votingbutton_pic/off.png"),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Stack(children: [
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(widget.data!["options"][widget.index]["string"],
                        style:
                            const TextStyle(fontSize: 20, color: Colors.white)),
                    Text("${getNumberOfVoters()}/${getNumberOfUsers()}",
                        style:
                            const TextStyle(fontSize: 20, color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 2),
                LinearProgressIndicator(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  minHeight: 5,
                  value: getPercentage(),
                  backgroundColor: Colors.white,
                  color: const Color.fromARGB(255, 86, 153, 123),
                ),
              ],
            ),
          ]),
        )
      ],
    );
  }
}
