import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internet_praktikum/core/services/date_service.dart';
import 'package:internet_praktikum/ui/widgets/errorSnackbar.dart';
import 'package:intl/intl.dart';

/*
  This class is used to display the calendar on the dashboard
  The user can select a date and the appointments for that date will be displayed
*/

class Calendar extends StatefulWidget {
  final Function(DateTime) onDateSelected;
  final DateTime? initSelectedDate;
  final DocumentReference selectedTrip;
  const Calendar(
      {Key? key,
      required this.onDateSelected,
      this.initSelectedDate,
      required this.selectedTrip})
      : super(key: key);

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  DateTime? selectedDate;
  DateTime? firstDate;
  DateTime? lastDate;

  DateTime? newStart;
  DateTime? newEnd;

  bool? isToday = false;
  bool? isTomorrow = false;
  bool? isYesterday = false;

  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    // Fetch start date from Firebase and initialize selectedDate, firstDate, and lastDate
    fetchDate();
  }

  void fetchDate() async {
    if (await _checkSelectedTrip()) {
      return;
    }
    StartEndDate startEndDate =
        await DateService.getStartEndDate(widget.selectedTrip);
    endDate = startEndDate.endDate;
    startDate = startEndDate.startDate;

    if (widget.initSelectedDate != null) {
      setState(() {
        selectedDate = widget.initSelectedDate;
        firstDate = widget.initSelectedDate!.add(const Duration(days: 1));
        lastDate = widget.initSelectedDate!.subtract(const Duration(days: 1));
      });
      widget.onDateSelected(selectedDate!);
      return;
    }

    if (DateTime.now().isBefore(startDate!)) {
      setState(() {
        selectedDate = startDate;
        firstDate = startDate!.add(const Duration(days: 1));
        lastDate = startDate!.subtract(const Duration(days: 1));
      });
    } else {
      // Fetch current date and initialize selectedDate, firstDate, and lastDate
      setState(() {
        selectedDate = DateTime.now();
        firstDate = DateTime.now().add(const Duration(days: 1));
        lastDate = DateTime.now().subtract(const Duration(days: 1));
      });
    }
    widget.onDateSelected(selectedDate!);
  }

  Future<void> _showDateRangePicker() async {
    if (context.mounted) {
      DateTimeRange? pickedRange = await showDateRangePicker(
        context: context,
        initialDateRange: DateTimeRange(start: startDate!, end: endDate!),
        initialEntryMode: DatePickerEntryMode.calendarOnly,
        firstDate: DateTime(2023),
        lastDate: DateTime(2060),
        currentDate: DateTime.now(),
        //Currently DarkMode Calendar
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.dark(),
            child: child!,
          );
        },
      );

      if (pickedRange != null) {
        setState(() {
          newStart = pickedRange.start;
          newEnd = pickedRange.end;
          if (newEnd!.difference(newStart!).inDays > 100) {
            ErrorSnackbar.showErrorSnackbar(
                context, 'Date range can\'t be longer than 100 days');
          } else {
            _setNewDateRange(newStart, newEnd);
          }
        });
      }
    }
  }

  void _setNewDateRange(DateTime? newStart, DateTime? newEnd) async {
    if (newStart != null && newEnd != null) {
      try {
        await widget.selectedTrip.update({
          'startdate': newStart,
          'enddate': newEnd,
        });
        setState(() {
          selectedDate = newStart;
          firstDate = newStart.add(const Duration(days: 1));
          lastDate = newStart.subtract(const Duration(days: 1));
          startDate = newStart;
          endDate = newEnd;
        });
      } catch (e) {
        // ignore: use_build_context_synchronously
        ErrorSnackbar.showErrorSnackbar(context, 'Could not update date range');
        throw Exception('Could not update date range');
      }
    }
    if (selectedDate != null) {
      widget.onDateSelected(selectedDate!);
    }
  }

  void _goToLatestDate() async {
    setState(() {
      if (selectedDate!.isBefore(startDate!)) {
        selectedDate = startDate!;
        firstDate = startDate!.add(const Duration(days: 1));
        lastDate = startDate!.subtract(const Duration(days: 1));
      }
      if (selectedDate!.isAfter(startDate!)) {
        selectedDate = DateTime.now();
        firstDate = DateTime.now().add(const Duration(days: 1));
        lastDate = DateTime.now().subtract(const Duration(days: 1));
      }
    });
    widget.onDateSelected(selectedDate!);
  }

  void _goToNextDate() {
    setState(() {
      if (selectedDate!.isAfter(endDate!) == false &&
          isSameDay(selectedDate!, endDate!) == false) {
        selectedDate = selectedDate!.add(const Duration(days: 1));
        firstDate = firstDate!.add(const Duration(days: 1));
        lastDate = lastDate!.add(const Duration(days: 1));
      }
    });
    widget.onDateSelected(selectedDate!);
  }

  void _goToPreviousDate() {
    setState(() {
      if (selectedDate!.isBefore(startDate!) == false &&
          isSameDay(selectedDate!, startDate!) == false) {
        selectedDate = selectedDate!.subtract(const Duration(days: 1));
        firstDate = firstDate!.subtract(const Duration(days: 1));
        lastDate = lastDate!.subtract(const Duration(days: 1));
      }
    });
    widget.onDateSelected(selectedDate!);
  }

  Future<bool> _checkSelectedTrip() async {
    var auth = FirebaseAuth.instance.currentUser!;
    var trips = [];
    await FirebaseFirestore.instance
        .collection("trips")
        .where("members",
            arrayContains: FirebaseFirestore.instance.doc("/users/${auth.uid}"))
        .get()
        .then((QuerySnapshot doc) {
      trips = doc.docs;
    });
    final DocumentSnapshot<Map<String, dynamic>> userDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(auth.uid)
            .get();

    if (userDoc.data()!['selectedtrip'] == '') {
      if (trips.isEmpty) {
        if (context.mounted) {
          context.pushReplacementNamed("selecttrip",
              pathParameters: {"noTrip": "true"});
        }
        return true;
      } else {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(auth.uid)
            .update({"selectedtrip": trips.first.id});
        if (context.mounted) {
          context.pushReplacementNamed("home");
        }
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 76,
      width: double.infinity,
      child: Column(
        children: [
          Stack(
            alignment: AlignmentDirectional.centerStart,
            children: [
              Positioned(
                left: 10,
                bottom: 7,
                child: IconButton(
                  onPressed: _goToLatestDate,
                  icon: const Icon(
                    Icons.today,
                    size: 30.0,
                    color: Colors.black,
                  ),
                  tooltip: 'go to trip Start',
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      _goToPreviousDate();
                    },
                    child: lastDate != null
                        ? _buildDateText(lastDate!)
                        : _loadingContainer(),
                  ),
                  GestureDetector(
                    onTap: () async {
                      await showCupertinoModalPopup<void>(
                        context: context,
                        builder: (BuildContext context) =>
                            FutureBuilder<Container>(
                          future: getDateRangeCupertino(
                              MediaQuery.of(context).size),
                          builder: (BuildContext context,
                              AsyncSnapshot<Container> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              if (snapshot.hasData) {
                                return snapshot.data!;
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              }
                            }
                            return const CircularProgressIndicator();
                          },
                        ),
                      );
                    },
                    child: selectedDate != null
                        ? _buildDateText(selectedDate!,
                            size: 15, selected: true)
                        : _loadingContainer(),
                  ),
                  GestureDetector(
                    onTap: () {
                      _goToNextDate();
                    },
                    child: firstDate != null
                        ? _buildDateText(firstDate!)
                        : _loadingContainer(),
                  ),
                ],
              ),
              Positioned(
                right: 10,
                bottom: 7,
                child: IconButton(
                  onPressed: _showDateRangePicker,
                  icon: const Icon(
                    Icons.edit_calendar,
                    size: 30.0,
                    color: Colors.black,
                  ),
                  tooltip: 'Change Date Range',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // builds the date text and the circle
  Widget _buildDateText(DateTime date,
      {double size = 12, bool selected = false}) {
    DateTime today = DateTime.now();
    DateTime tomorrow = DateTime.now().add(const Duration(days: 1));
    DateTime yesterday = DateTime.now().subtract(const Duration(days: 1));
    today = DateTime(today.year, today.month, today.day);
    tomorrow = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
    yesterday = DateTime(yesterday.year, yesterday.month, yesterday.day);

    bool isNotInTripRange =
        date.isAfter(endDate!.add(const Duration(days: 1))) ||
            isSameDay(date, endDate!.add(const Duration(days: 1))) ||
            date.isBefore(startDate!);

    return Container(
      width: selected ? 101 : 92.8,
      height: selected ? 76 : 66,
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          Text(
            isSameDay(date, DateTime(today.year, today.month, today.day))
                ? "Today"
                : isSameDay(date,
                        DateTime(tomorrow.year, tomorrow.month, tomorrow.day))
                    ? "Tomorrow"
                    : isSameDay(
                            date,
                            DateTime(
                                yesterday.year, yesterday.month, yesterday.day))
                        ? "Yesterday"
                        : DateFormat('dd.MM.yyyy').format(date),
            style: TextStyle(
                color: isNotInTripRange ? Colors.grey[900] : Colors.black,
                fontSize: size,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal),
          ), // Spacer zwischen Text und Kreis
          Container(
            width: selected ? 35 : 22 + size, // Diameter of the circle
            height: selected ? 35 : 28,
            decoration: BoxDecoration(
              color: isNotInTripRange
                  ? Colors.grey[400]
                  : Colors
                      .white, // Change color of circle if date is not in range
              shape: BoxShape.circle,
              border: const Border.fromBorderSide(
                  BorderSide(color: Colors.black, width: 2)),
            ),
          ),
        ],
      ),
    );
  }

  // builds the loading container
  Widget _loadingContainer({double size = 12, bool selected = false}) {
    return Container(
      width: selected ? 101 : 92.8,
      height: selected ? 76 : 66,
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          Text(
            "Loading",
            style: TextStyle(
                fontSize: size,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal),
          ), // Spacer between Text and circle
          Container(
            width: selected ? 35 : 22 + size, // radius of the circle
            height: selected ? 35 : 28,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              border: Border.fromBorderSide(
                  BorderSide(color: Colors.black, width: 2)),
            ),
          ),
        ],
      ),
    );
  }

  // checks if two dates are the same
  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // the CupertinoDatePicker is used to select a date
  Future<Container> getDateRangeCupertino(Size size) async {
    DateTime? tmpDate;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(34.5),
          topRight: Radius.circular(34.5),
        ),
      ),
      height: size.height * 0.32,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5.0, right: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      if (tmpDate != null) {
                        selectedDate = tmpDate!;
                        firstDate = tmpDate!.add(const Duration(days: 1));
                        lastDate = tmpDate!.subtract(const Duration(days: 1));
                        widget.onDateSelected(selectedDate!);
                      }
                    });
                    context.pop();
                  },
                  child: const Text('Done'),
                ),
              ],
            ),
          ),
          Flexible(
            child: SizedBox(
              height: size.height * 0.25,
              child: CupertinoDatePicker(
                initialDateTime: lastDate!.isBefore(selectedDate!) ? startDate! : selectedDate!,
                minimumDate: startDate!,
                maximumDate: endDate!,
                mode: CupertinoDatePickerMode.date,
                onDateTimeChanged: (value) {
                  tmpDate = value;
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
