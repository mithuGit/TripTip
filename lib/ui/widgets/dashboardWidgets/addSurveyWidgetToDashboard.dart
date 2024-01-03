// ignore: file_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/core/services/manageDashboardWidget.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';
import 'package:internet_praktikum/ui/widgets/dashboardWidgets/selectDeadline.dart';
import 'package:internet_praktikum/ui/widgets/datepicker.dart';
import 'package:internet_praktikum/ui/widgets/errorSnackbar.dart';
import 'package:internet_praktikum/ui/widgets/inputfield.dart';
import 'package:internet_praktikum/ui/widgets/my_button.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

abstract class SelectedOption {
  bool get isNotEmpty;
  bool get isDate => this is SelectedDate;
  bool get isQuestion => this is SelectedQuestion;
  Object? get value;
  set value(Object? value);
  Map toMap();
}

class SelectedDate extends SelectedOption {
  DateTime? date;
  @override
  bool get isNotEmpty => date != null;
  @override
  Map toMap() => {
        "string": DateFormat('hh:mm').format(date!),
        "date": date!,
        "voters": []
      };
  @override
  Object? get value => date;
  @override
  set value(Object? value) => date = value as DateTime?;
  @override
  String toString() => DateFormat('HH:mm').format(date!);
}

class SelectedQuestion extends SelectedOption {
  TextEditingController question = TextEditingController();
  @override
  bool get isNotEmpty => true;
  @override
  Map toMap() => {"string": question.text, "voters": []};
  @override
  Object? get value => question;
  @override
  set value(Object? value) => question.text = value as String;
  @override
  String toString() => question.text;
}

// ignore: must_be_immutable
class AddSurveyWidgetToDashboard extends StatefulWidget {
  DocumentReference day;
  String typeOfSurvey;
  Map<String, dynamic> userdata;
  Map<String, dynamic>? data;
  AddSurveyWidgetToDashboard(
      {super.key,
      required this.day,
      required this.userdata,
      this.data,
      required this.typeOfSurvey});

  @override
  AddSurveyWidgetToDashboardState createState() =>
      AddSurveyWidgetToDashboardState();
}

class AddSurveyWidgetToDashboardState
    extends State<AddSurveyWidgetToDashboard> {
  final nameofSurvey = TextEditingController();
  late SelectedOption selectedOption;
  late DateTime dateofDay;
  DateTime? deadline;

  bool allowmultipleAnswers = true;
  final List<SelectedOption> _optionList = List.empty(growable: true);
  final List<bool> linkwith = [false, false, false];
  final firestore = FirebaseFirestore.instance;
  @override
  void initState() {
    super.initState();
    selectedOption = widget.typeOfSurvey == "questionsurvey"
        ? SelectedQuestion()
        : SelectedDate();
    getDay().then((value) => setState(() {
          dateofDay = value;
        }));
    // when you want to update a survey you have to pass the data
    if (widget.data != null) {
      nameofSurvey.text = widget.data!["title"];
      allowmultipleAnswers = widget.data!["allowmultipleanswers"];
      _optionList.clear();
      _optionList.addAll(widget.data!["options"]
          .map((e) {
            if (widget.typeOfSurvey == "questionsurvey") {
              return SelectedQuestion()..value = e["string"];
            } else {
              return SelectedDate()..value = e["date"].toDate();
            }
          })
          .toList()
          .cast<SelectedOption>());
    }
  }

  Future<DateTime> getDay() async {
    DocumentSnapshot dd = await widget.day.get();
    Map<String, dynamic> data = dd.data() as Map<String, dynamic>;
    return data["starttime"].toDate();
  }

  Future<void> createorUpdateSurvey() async {
    Map<String, dynamic> data = {
      "type": "survey",
      "title": nameofSurvey.text,
      "typeOfSurvey": widget.typeOfSurvey,
      "allowmultipleanswers": allowmultipleAnswers,
    };
    if (deadline != null) {
      data["deadline"] = deadline;  
    } 
    data["options"] = _optionList.map((e) => e.toMap()).toList();
    DocumentReference by = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userdata["uid"]);
    DocumentReference trip = FirebaseFirestore.instance
        .collection('trips')
        .doc(widget.userdata["selectedtrip"]);
    if (widget.data == null) {
      String key = const Uuid().v4();
      if (deadline != null) {
        DocumentReference converter = await firestore.collection("tasks").add({
          "worker": "SurveyConvertion",
          "performAt": deadline,
          "status": "pending",
          "options": {
            "day": widget.day,
            "widgetCreatedBy": by,
            "titleOfSurvey": nameofSurvey.text,
            "trip": trip,
            "key": key
          }
        });
        DocumentReference alerter = await firestore.collection("tasks").add({
          "worker": "LastChanceSurvey",
          "performAt": deadline!.subtract(const Duration(minutes: 15)),
          "status": "pending",
          "options": {
            "day": widget.day,
            "widgetCreatedBy": by,
            "titleOfSurvey": nameofSurvey.text,
            "trip": trip,
          }
        });
        data["workers"] = [converter, alerter];
      }
      await ManageDashboardWidged()
          .addWidget(day: widget.day, user: by, data: data, key: key);
    } else {
      await ManageDashboardWidged()
          .updateWidget(widget.day, by, data, widget.data!["key"]);
    }
    if (context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    Widget buildTenableListTile(SelectedOption item, int index) {
      return Dismissible(
        key: Key(_optionList[index].toString() + index.toString()),
        onDismissed: (direction) {
          setState(() {
            _optionList.removeAt(index);
          });
        },
        background: Container(color: Colors.red),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.shade400,
                width: 1.0,
              ),
            ),
          ),
          child: ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _optionList[index].toString(),
                  style: Styles.inputField,
                ),
                const Icon(Icons.drag_handle),
              ],
            ),
          ),
        ),
      );
    }
    // needed that the widget is moveable
    return SingleChildScrollView(
      child: Column(children: [
        InputField(
            controller: nameofSurvey,
            borderColor: Colors.grey.shade400,
            focusedBorderColor: const Color.fromARGB(255, 84, 113, 255),
            hintText: "Title of Survey",
            obscureText: false),
        const SizedBox(height: 10),
        // you can only change the deadline if you create a new survey

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (widget.data == null)
              SelectDeadlineButton(
                notifier: (Deadline value) {
                  setState(() {
                    if (value.isSet) deadline = value.deadline;
                  });
                },
              ),
            const SizedBox(width: 10),
            Row(
              children: [
                const Text(
                  "Allow multiple answers",
                  style: Styles.inputField,
                ),
                Checkbox(
                    value: allowmultipleAnswers,
                    onChanged: (value) {
                      setState(() {
                        allowmultipleAnswers = value!;
                      });
                    }),
              ],
            )
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            if (selectedOption.isQuestion) ...[
              Expanded(
                  flex: 2,
                  child: InputField(
                    controller: (selectedOption as SelectedQuestion).question,
                    hintText: "Question you can add",
                    borderColor: Colors.grey.shade400,
                    focusedBorderColor: const Color.fromARGB(255, 84, 113, 255),
                    obscureText: false,
                  ))
            ] else if (selectedOption.isDate) ...[
              Expanded(
                flex: 2,
                child: CupertinoDatePickerButton(
                  showFuture: true,
                  use24hFormat: true,
                  mode: CupertinoDatePickerMode.time,
                  boundingDate: DateTime(2023),
                  presetDate: selectedOption.value != null
                      ? selectedOption.toString()
                      : "select time",
                  onDateSelected: (date) {
                    setState(() {
                      selectedOption.value = date.date;
                    });
                  },
                ),
              )
            ],
            const SizedBox(width: 5),
            IconButton(
                onPressed: () => {
                      if (_optionList
                          .where((element) => element == selectedOption)
                          .isEmpty)
                        {
                          if (selectedOption.value != null &&
                              _optionList.length <= 5)
                            {
                              setState(() {
                                _optionList.add(selectedOption);
                                selectedOption =
                                    widget.typeOfSurvey == "questionsurvey"
                                        ? SelectedQuestion()
                                        : SelectedDate();
                              })
                            }
                        }
                    },
                icon: const Icon(
                  Icons.add,
                  size: 30,
                )),
          ],
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 200),
          child: ReorderableListView.builder(
            shrinkWrap: true,
            itemCount: _optionList.length,
            itemBuilder: (context, index) =>
                buildTenableListTile(_optionList[index], index),
            onReorder: (int oldIndex, int newIndex) {
              setState(() {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                final SelectedOption item = _optionList.removeAt(oldIndex);
                _optionList.insert(newIndex, item);
              });
            },
          ),
        ),
        const SizedBox(height: 5),
        if (_optionList.length >= 2)
          MyButton(
              colors: Colors.blue,
              onTap: () =>
                  createorUpdateSurvey().onError((error, stackTrace) => {
                        // ignore: avoid_print
                        print(error.toString()),
                        // ignore: avoid_print
                        print(stackTrace.toString()),
                        ErrorSnackbar.showErrorSnackbar(
                            context, error.toString())
                      }),
              text: widget.data == null
                  ? "Add Survey to Dasboard"
                  : "Update Survey")
        else
          const Text(
            "Please add at least two options and a title",
            style: Styles.inputField,
          )
      ]),
    );
  }
}
