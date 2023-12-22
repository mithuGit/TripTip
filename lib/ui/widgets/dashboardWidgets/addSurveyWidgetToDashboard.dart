import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/core/services/manageDashboardWidget.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';
import 'package:internet_praktikum/ui/widgets/errorSnackbar.dart';
import 'package:internet_praktikum/ui/widgets/inputfield.dart';
import 'package:internet_praktikum/ui/widgets/my_button.dart';
import 'package:uuid/uuid.dart';

// ignore: must_be_immutable
class AddSurveyWidgetToDashboard extends StatefulWidget {
  DocumentReference day;
  Map<String, dynamic> userdata;
  Map<String, dynamic>? data;
  AddSurveyWidgetToDashboard(
      {super.key, required this.day, required this.userdata, this.data});

  // ignore: library_private_types_in_public_api
  _AddSurveyWidgetToDashboardState createState() =>
      _AddSurveyWidgetToDashboardState();
}

class _AddSurveyWidgetToDashboardState
    extends State<AddSurveyWidgetToDashboard> {
  final nameofSurvey = TextEditingController();
  final survey = TextEditingController();
  final option = TextEditingController();

  var uuid = const Uuid();
  final List<String> _items = List.empty(growable: true);
  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color oddItemColor = colorScheme.primary.withOpacity(0.05);
    final Color evenItemColor = colorScheme.primary.withOpacity(0.15);
    if (widget.data != null) {
      nameofSurvey.text = widget.data!["title"];
      survey.text = widget.data!["content"];
    }
    Future<void> createorUpdateSurvey() async {
      print(widget.userdata);
      Map<String, dynamic> data = {
        "type": "survey",
        "content": survey.text,
        "title": nameofSurvey.text,
        // hier muss noch die Anzahl an Member gespeichert werden
        // und in Options soll die Anzahl an Stimmen gespeichert werden
        // "options": [option1.text, options2.text, options3.text, options4.text],
      };
      DocumentReference by = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userdata["uid"]);
      if (widget.data == null) {
        await ManageDashboardWidged().addWidget(widget.day, by, data);
      } else {
        await ManageDashboardWidged()
            .updateWidget(widget.day, by, data, widget.data!["key"]);
      }
      if (context.mounted) Navigator.pop(context);
    }

    Widget _buildTenableListTile(String item, int index) {
      return Dismissible(
        key: Key('$index'),
        onDismissed: (direction) {
          setState(() {
            _items.removeAt(index);
          });
        },
        background: Container(
            color: Colors.red,
            child:const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.delete, color: Colors.white),
                SizedBox(width: 10),
              ],
            )),
        child: ListTile(
          key: ValueKey('$index-$index'),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _items[index],
                style: Styles.inputField,
              ),
              const Icon(Icons.drag_handle),
            ],
          ),
        ),
      );
    }

    List<Widget> _getListItems() => _items
        .asMap()
        .map((i, item) => MapEntry(i, _buildTenableListTile(item, i)))
        .values
        .toList();
    return SingleChildScrollView(
      child: Column(children: [
        InputField(
            controller: nameofSurvey,
            borderColor: Colors.grey.shade400,
            focusedBorderColor: const Color.fromARGB(255, 84, 113, 255),
            hintText: "Title of Survey",
            obscureText: false),
        SizedBox(height: 10),
        InputField(
          controller: survey,
          hintText: "Question of Survey",
          borderColor: Colors.grey.shade400,
          focusedBorderColor: const Color.fromARGB(255, 84, 113, 255),
          obscureText: false,
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: InputField(
                controller: option,
                hintText: "Option you can add",
                borderColor: Colors.grey.shade400,
                focusedBorderColor: const Color.fromARGB(255, 84, 113, 255),
                obscureText: false,
              ),
            ),
            const SizedBox(width: 5),
            IconButton(
                onPressed: () => {
                      setState(() {
                        if (option.text.isNotEmpty) {
                          _items.add(option.text);
                          option.clear();
                        }
                      })
                    },
                icon: const Icon(
                  Icons.add,
                  size: 30,
                )),
          ],
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 200),
          child: ReorderableListView(
            shrinkWrap: true,
            children: _getListItems(),
            onReorder: (int oldIndex, int newIndex) {
              setState(() {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                final String item = _items.removeAt(oldIndex);
                _items.insert(newIndex, item);
              });
            },
          ),
        ),
        SizedBox(height: 5),
        if (_items.isNotEmpty)
          MyButton(
              colors: Colors.blue,
              onTap: () =>
                  createorUpdateSurvey().onError((error, stackTrace) => {
                        print(error.toString()),
                        print(stackTrace.toString()),
                        print("error"),
                        ErrorSnackbar.showErrorSnackbar(
                            context, error.toString())
                      }),
              text: widget.data == null
                  ? "Add Survey to Dasboard"
                  : "Update Survey")
        else
          const Text(
            "Please add at least one option",
            style: Styles.inputField,
          )
      ]),
    );
  }
}
