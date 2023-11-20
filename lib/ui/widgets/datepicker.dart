import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../styles/Styles.dart';

class DatePicker extends StatefulWidget {
  final margin;
  const DatePicker({super.key, this.margin});

  @override
  State<DatePicker> createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  late DateTime dateTime;

  @override
  void initState() {
    dateTime = DateTime.now();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
      height: 55,
      child: ElevatedButton(
        onPressed: () {
          showCupertinoModalPopup(
              context: context,
              builder: (context) {
                return Container(
                  // Wie groß wird das Auswahlrad
                  height: MediaQuery.of(context).size.height * 0.3,
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("Done"),
                      ),
                      Expanded(
                        child: CupertinoDatePicker(
                          initialDateTime: dateTime,
                          mode: CupertinoDatePickerMode.date,
                          maximumDate: DateTime.now(),
                          onDateTimeChanged: (date) {
                            setState(() {
                              dateTime = date;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                );
              });
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black, backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
          ),
          padding: const EdgeInsets.all(0),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 14),
              child: Text(
                'Select Date of Birth',
                style: Styles.textfieldHintStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
