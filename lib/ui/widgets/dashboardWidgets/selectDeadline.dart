// ignore: file_names
import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';


//Dropdown menu to select a deadline on the addSurveyWidgetToDashboard

class Deadline {
  DateTime? deadline;
  get isSet => deadline != null;
  Deadline({this.deadline});
}

class SelectDeadlineButton extends StatefulWidget {
  final ValueChanged<Deadline> notifier;
  const SelectDeadlineButton({super.key, required this.notifier});
  @override
  State<SelectDeadlineButton> createState() => _DropdownMenuExampleState();
}

class _DropdownMenuExampleState extends State<SelectDeadlineButton> {
  String dropdownValue = "none";
  List<String> list = ["no deadline", "in 1h", "in 5h", "in 10h", "in 24h"];
  @override
  void initState() {
    super.initState();
    dropdownValue = list.first;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      dropdownColor: Colors.white,
      elevation: 16,
      borderRadius: BorderRadius.circular(11),

      items: list.map((String value) {
        return DropdownMenuItem<String>(

          value: value,
          child: Text(
            value,
            style: Styles.datepicker,
          ),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          dropdownValue = newValue!;
        });
        DateTime deadline = DateTime.now();
        if (newValue == "no deadline") {
          widget.notifier.call(Deadline());
        } else if (newValue == "in 1h") {
          deadline = deadline.add(const Duration(hours: 1));
        } else if (newValue == "in 5h") {
          deadline = deadline.add(const Duration(hours: 5));
        } else if (newValue == "in 10h") {
          deadline = deadline.add(const Duration(hours: 10));
        } else if (newValue == "in 24h") {
          deadline = deadline.add(const Duration(hours: 24));
        }
        widget.notifier.call(Deadline(deadline: deadline));
      },
    );
  }
}
