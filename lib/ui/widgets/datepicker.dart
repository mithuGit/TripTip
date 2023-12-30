import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../styles/Styles.dart';

//* Return Type for Tupel *//
class DateStringTupel {
  String dateString;
  DateTime date;
  DateStringTupel({required this.dateString, required this.date});
}

class CupertinoDatePickerButton extends StatefulWidget {
  final EdgeInsets? margin;
  final bool
      showFuture; // this field is set to true when the datepicker is used for the future Dates
  final ValueChanged<DateStringTupel>? onDateSelected;
  final String? presetDate;
  final CupertinoDatePickerMode? mode;
  DateTime? boundingDate;

  CupertinoDatePickerButton(
      {super.key,
      this.margin,
      this.onDateSelected,
      required this.showFuture,
      this.presetDate,
      this.mode = CupertinoDatePickerMode.date,
      this.boundingDate});

  @override
  _CupertinoDatePickerButtonState createState() =>
      _CupertinoDatePickerButtonState();
}

class _CupertinoDatePickerButtonState extends State<CupertinoDatePickerButton> {
  DateTime? selectedDate;

  String f_String = "";
  @override
  void initState() {
    super.initState();
    widget.boundingDate = widget.boundingDate ?? DateTime.now();
  }

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
                    initialDateTime:  widget.boundingDate,
                    mode: widget.mode!,
                    maximumDate: !widget.showFuture ? widget.boundingDate : null,
                    minimumDate: widget.showFuture ? widget.boundingDate : null,
                    onDateTimeChanged: (DateTime newDate) {
                      currentDate = newDate;
                      //formatieren des Strings
                      f_String =
                          '${newDate.day}.${newDate.month}.${newDate.year}';
                      //pass to callback
                      widget.onDateSelected?.call(DateStringTupel(
                          dateString: f_String, date: currentDate));
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
        widget.onDateSelected
            ?.call(DateStringTupel(dateString: f_String, date: currentDate));
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
            text(),
            /* widget.presetDate ??
                (selectedDate != null ? f_String : 'Select Date'),*/
            style: testStyle(),
          ),
        ),
      ),
    );
  }

  String text() {
    if (widget.presetDate != '') {
      return widget.presetDate.toString();
    } else if (selectedDate != null) {
      return f_String;
    } else {
      return 'Select Date';
    }
  }

  TextStyle testStyle() {
    if (widget.presetDate != '') {
      return Styles.datepicker;
    } else if (selectedDate != null) {
      return Styles.datepicker;
    }
    return Styles.textfieldHintStyle;
  }
}
