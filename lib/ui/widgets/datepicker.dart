import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../styles/Styles.dart';

class CupertinoDatePickerButton extends StatefulWidget {
  final margin;
  final ValueChanged<String>? onDateSelected;

  const CupertinoDatePickerButton(
      {super.key, this.margin, this.onDateSelected});

  @override
  _CupertinoDatePickerButtonState createState() =>
      _CupertinoDatePickerButtonState();
}

class _CupertinoDatePickerButtonState extends State<CupertinoDatePickerButton> {
  DateTime? selectedDate;

  String f_String = "";

  Future<void> _selectDate(BuildContext context) async {
    DateTime currentDate = selectedDate ?? DateTime.now();

    await showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.3,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the bottom sheet
                },
                child: const Text('Done'),
              ),
              Expanded(
                  child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  color: Colors.white,
                ),
                child: CupertinoDatePicker(
                    initialDateTime: DateTime.now(),
                    mode: CupertinoDatePickerMode.date,
                    maximumDate: DateTime.now(),
                    onDateTimeChanged: (DateTime newDate) {
                      currentDate = newDate;
                      //formatieren des Strings
                      f_String =
                          '${newDate.day}.${newDate.month}.${newDate.year}';
                      //pass to callback
                      widget.onDateSelected?.call(f_String);
                    }),
              ))
            ],
          ),
        );
      },
    );

    if (currentDate != selectedDate) {
      setState(() {
        selectedDate = currentDate;
        f_String =
            '${currentDate.day}.${currentDate.month}.${currentDate.year}';
        widget.onDateSelected?.call(f_String);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
      height: 50,
      child: ElevatedButton(
        onPressed: () => _selectDate(context),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
          ),
          padding: const EdgeInsets.all(0),
        ),
        child: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Text(
            selectedDate != null ? f_String : 'Select Date',
            style: selectedDate != null
                ? Styles.inputField
                : Styles.textfieldHintStyle,
          ),
        ),
      ),
    );
  }
}
