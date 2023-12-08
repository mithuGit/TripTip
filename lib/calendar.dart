import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
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
  final DateTime startDate = documentSnapshot.data()!['enddate'].toDate();
  int day = startDate.day;
  int month = startDate.month;
  int year = startDate.year;
  DateTime result = DateTime(year, month, day + 1);
  return result;
}

class _CalendarState extends State<Calendar> {
  // Erstelle DateTimeRange-Variable

  DateTimeRange _dateTimeRange = DateTimeRange(
    start: DateTime.now(),
    end: DateTime.now(),
  );

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
      );

      if (pickedRange != null) {
        setState(() {
          _dateTimeRange = pickedRange;
        });
      }
    }
  }

  void _goToLatestDate() {
    setState(() {
      _dateTimeRange = DateTimeRange(
        start: DateTime.now(),
        end: DateTime.now(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Zeige ausgewähltes Datum oder Zeitintervall an
            Stack(
              alignment: AlignmentDirectional.center,
              children: [
                GestureDetector(
                  onTap: _goToLatestDate,
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.arrow_left, // Verwende das gewünschte Icon
                      size: 30.0,
                      color: Colors.blue, // Ändere die Farbe nach Bedarf
                    ),
                  ),
                ),
                Positioned(
                  top: -20,
                  child: Text(
                    '${DateFormat('dd.MM.yyyy').format(_dateTimeRange.start)} - ${DateFormat('dd.MM.yyyy').format(_dateTimeRange.end)}',
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _dateTimeRange = DateTimeRange(
                            start: _dateTimeRange.start
                                .subtract(const Duration(days: 1)),
                            end: _dateTimeRange.end
                                .subtract(const Duration(days: 1)),
                          );
                        });
                      },
                      child: _buildDateText(_dateTimeRange.start
                          .subtract(const Duration(days: 1))),
                    ),
                    _buildDateText(_dateTimeRange.start, size: 15),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _dateTimeRange = DateTimeRange(
                            start: _dateTimeRange.start
                                .add(const Duration(days: 1)),
                            end:
                                _dateTimeRange.end.add(const Duration(days: 1)),
                          );
                        });
                      },
                      child: _buildDateText(
                          _dateTimeRange.end.add(const Duration(days: 1))),
                    ),
                  ],
                ),
                Positioned(
                  right: 10,
                  bottom: 7,
                  child: IconButton(
                    onPressed: _showDateRangePicker,
                    icon: const Icon(
                      Icons.calendar_today,
                      size: 30.0,
                      color: Colors.grey,
                    ),
                    tooltip: 'Zeitintervall auswählen',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateText(DateTime date, {String label = '', double size = 10}) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.black,
              width: 2.0,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              DateFormat('dd.MM.yyyy').format(date),
              style: TextStyle(fontSize: size),
            ),
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 8),
        ),
      ],
    );
  }
}
