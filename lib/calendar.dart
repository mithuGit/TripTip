import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Calendar extends StatefulWidget {
  const Calendar({Key? key}) : super(key: key);

  @override
  State<Calendar> createState() => _CalendarState();
}

Future<DateTime> getStartDate() async {
  final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
      await FirebaseFirestore.instance
          .collection('trips')
          .doc('BmGvil7kYHjvOiUGzjiR')
          .get();
  final DateTime startDate = documentSnapshot.data()!['startdate'].toDate();
  int day = startDate.day;
  int month = startDate.month;
  int year = startDate.year;
  DateTime result = DateTime(year, month, day + 1);
  return result;
}

Future<DateTime> getEndtDate() async {
  final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
      await FirebaseFirestore.instance
          .collection('trips')
          .doc('BmGvil7kYHjvOiUGzjiR')
          .get();
  final DateTime endDate = documentSnapshot.data()!['enddate'].toDate();
  int day = endDate.day;
  int month = endDate.month;
  int year = endDate.year;
  DateTime result = DateTime(year, month, day + 1);
  return result;
}

class _CalendarState extends State<Calendar> {
  DateTime selectedDate = DateTime.now();
  DateTime firstDate = DateTime.now().add(const Duration(days: 1));
  DateTime lastDate = DateTime.now().subtract(const Duration(days: 1));

  /*void initState() {
    super.initState();
    fetchDateTime();
  }

  Future<void> fetchDateTime() async {
    final select  = await getStartDate();
    setState(() {
      selectedDate = select;
      firstDate = select.add(const Duration(days: 1));
      lastDate = select.subtract(const Duration(days: 1));
    });
  }*/

  // Erstelle DateTimeRange-Variable

  Future<void> _showDateRangePicker() async {
    DateTime start = await getStartDate();
    DateTime end = await getEndtDate();
    if (context.mounted) {
      DateTimeRange? pickedRange = await showDateRangePicker(
        context: context,
        initialDateRange: DateTimeRange(start: start, end: end),
        firstDate: DateTime(2023),
        lastDate: DateTime(2060),
        currentDate: DateTime.now(),
        // DarkMode Calendar ????????
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.dark(),
            child: child!,
          );
        },
      );

      if (pickedRange != null) {
        setState(() {
          //_dateTimeRange = pickedRange;
        });
      }
    }
  }

  void _goToLatestDate() {
    setState(() {
      selectedDate = DateTime.now();
      firstDate = DateTime.now().add(const Duration(days: 1));
      lastDate = DateTime.now().subtract(const Duration(days: 1));
    });
  }

  void _goToNextDate() {
    setState(() {
      selectedDate = selectedDate.add(const Duration(days: 1));
      firstDate = firstDate.add(const Duration(days: 1));
      lastDate = lastDate.add(const Duration(days: 1));
    });
  }

  void _goToPreviousDate() {
    setState(() {
      selectedDate = selectedDate.subtract(const Duration(days: 1));
      firstDate = firstDate.subtract(const Duration(days: 1));
      lastDate = lastDate.subtract(const Duration(days: 1));
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 76,
      width: double.infinity,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            children: [
              // Zeige ausgewähltes Datum oder Zeitintervall an
              Stack(
                alignment: AlignmentDirectional.centerStart,
                children: [
                  Positioned(
                    left: 10,
                    bottom: 7,
                    child: GestureDetector(
                      onTap: _goToLatestDate,
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.calendar_today, // Verwende das gewünschte Icon
                          size: 30.0,
                          color: Colors.black, // Ändere die Farbe nach Bedarf
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          _goToPreviousDate();
                        },
                        child: _buildDateText(lastDate),
                      ),
                      _buildDateText(selectedDate, size: 15, selected: true),
                      GestureDetector(
                        onTap: () {
                          _goToNextDate();
                        },
                        child: _buildDateText(firstDate),
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
                      tooltip: 'Zeitintervall auswählen',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateText(DateTime date,
      {double size = 12, bool selected = false}) {
    return Container(
      //width: selected ? 220 : 160,  Hier ändern damit Container fest bleibt und bei Today nicht kleiner wird
      //height: selected ? 200 : 140, Mit selected arbeiten, weil mitte Container größer ist als die anderen
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          Text(
            DateFormat('dd.MM.yyyy').format(date),
            style: TextStyle(
                fontSize: size,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal),
          ), // Spacer zwischen Text und Kreis
          Container(
            width: selected ? 35 : 22 + size, // Durchmesser des Kreises
            height: selected ? 35 : 28,
            decoration: const BoxDecoration(
              shape:
                  BoxShape.circle, // Farbe des Kreises ändern, falls gewünscht
              border: Border.fromBorderSide(
                  BorderSide(color: Colors.black, width: 2)),
            ),
          ),
        ],
      ),
    );
  }
}
