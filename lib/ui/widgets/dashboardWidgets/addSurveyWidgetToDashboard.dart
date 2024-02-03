// ignore: file_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/core/services/JobworkerService.dart';
import 'package:internet_praktikum/core/services/manageDashboardWidget.dart';
import 'package:internet_praktikum/core/services/map_service.dart';
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
        "string": DateFormat('HH:mm').format(date!),
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
  bool get isNotEmpty => question.text.isNotEmpty;
  @override
  Map toMap() => {"string": question.text, "voters": []};
  @override
  Object? get value => question.text;
  @override
  set value(Object? value) => question.text = value as String;
  @override
  String toString() => question.text;
}

class AddSurveyWidgetToDashboard extends StatefulWidget {
  final Place? place;
  final DocumentReference day;
  final String typeOfSurvey;
  final Map<String, dynamic> userdata;
  final Map<String, dynamic>? data;
  const AddSurveyWidgetToDashboard(
      {super.key,
      required this.day,
      required this.userdata,
      this.data,
      this.place,
      required this.typeOfSurvey});

  @override
  AddSurveyWidgetToDashboardState createState() =>
      AddSurveyWidgetToDashboardState();
}

class AddSurveyWidgetToDashboardState
    extends State<AddSurveyWidgetToDashboard> {
  final nameofSurvey = TextEditingController();
  late SelectedOption selectedOption;
  DateTime? dateofDay;
  DateTime? deadline;

  bool allowmultipleAnswers = true;
  final List<SelectedOption> _optionList = List.empty(growable: true);
  final List<bool> linkwith = [false, false, false];
  final firestore = FirebaseFirestore.instance;
  @override
  void initState() {
    super.initState();
    getPlaceDetails();
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

  void getPlaceDetails() {
    if (widget.place != null) {
      String title = widget.place!.name;
      nameofSurvey.text = widget.typeOfSurvey == "questionsurvey"
          ? "Do you want to go to $title?"
          : "When do you want to go to $title?";
      if (widget.typeOfSurvey == "questionsurvey") {
        _optionList.add(SelectedQuestion()..value = "Yes?");
        _optionList.add(SelectedQuestion()..value = "No?");
      }
    }
  }

  Future<DateTime> getDay() async {
    DocumentSnapshot dd = await widget.day.get();
    Map<String, dynamic> data = dd.data() as Map<String, dynamic>;
    return data["starttime"].toDate();
  }

  Future<void> createorUpdateSurvey() async {
    if (nameofSurvey.text.isEmpty) {
      throw Exception("Please enter a title for this survey");
    }
    Map<String, dynamic> data = {
      "type": "survey",
      "title": nameofSurvey.text,
      "typeOfSurvey": widget.typeOfSurvey,
      "allowmultipleanswers": allowmultipleAnswers,
    };
    if (widget.place != null) {
      data["place"] = widget.place!.toMap();
    }
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
        // A Worker to convert the survey to special Widget
        DocumentReference converter =
            await JobworkerService.generateSurveyConvertionWorker(
                deadline!, widget.day, by, trip, key, nameofSurvey.text);
        // A Worker 15inutes before the deadline to alert the user
        DocumentReference alerter =
            await JobworkerService.generateLastChanceSurveryWorker(
                deadline!.subtract(const Duration(minutes: 15)),
                widget.day,
                by,
                trip,
                key,
                nameofSurvey.text);
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
        direction:
            widget.place != null && widget.typeOfSurvey == "questionsurvey"
                ? DismissDirection.none
                : DismissDirection.endToStart,
        onDismissed: (direction) {
          setState(() {
            _optionList.removeAt(index);
          });
        },
        background: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11.0),
              color: Colors.red,
            ),
            child: const Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Text(
                    "Swipe to Delete   ",
                    style: Styles.buttonFontStyle,
                    textAlign: TextAlign.center,
                  ),
                )),
          ),
        ),
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

        if (widget.place != null) ...[
          const SizedBox(height: 10),
          Text(
            "Is bound to location: ${widget.place!.name}",
            style: Styles.inputField,
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 20),
        ],

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
                    readOnly: widget.place != null,
                    controller: (selectedOption as SelectedQuestion).question,
                    hintText: widget.place == null
                        ? "Question or Answer you can add"
                        : "Question or Answer can't be added",
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
                  boundingDate: getBoundingDate(),
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
                      if (widget.place == null ||
                          (widget.place != null &&
                              widget.typeOfSurvey == "appointmentsurvey"))
                        {
                          if (_optionList
                              .where((element) =>
                                  element.value == selectedOption.value)
                              .isEmpty)
                            {
                              if (selectedOption.isNotEmpty &&
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
                        }
                    },
                icon: const Icon(
                  Icons.add,
                  size: 30,
                )),
          ],
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 180),
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
        const SizedBox(height: 10),
        if (_optionList.length >= 2)
          MyButton(
              borderColor: Colors.black,
              textStyle: Styles.buttonFontStyleModal,
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

  DateTime getBoundingDate() {
    if (dateofDay != null) {
      if (dateofDay!.isBefore(DateTime.now()) ||
          dateofDay!.isAtSameMomentAs(DateTime.now())) {
        return DateTime.now();
      }
      return DateTime(dateofDay!.year, dateofDay!.month, dateofDay!.day, 0, 0);
    } else {
      return DateTime(2021, 1, 1, 0, 0);
    }
  }
}
