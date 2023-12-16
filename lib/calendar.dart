import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Calendar extends StatefulWidget {
  final Function(DateTime) onDateSelected;
  const Calendar({Key? key, required this.onDateSelected}) : super(key: key);

  @override
  State<Calendar> createState() => _CalendarState();
}

Future<DateTime> getStartDate() async {
  final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
      await FirebaseFirestore.instance
          .collection('trips')
          .doc('OYcU9dTsakHTtYs5k5uw')
          .get();
  if (documentSnapshot.exists) {
    final DateTime startDate = documentSnapshot.data()!['startdate'].toDate();
    int day = startDate.day;
    int month = startDate.month;
    int year = startDate.year;
    DateTime result = DateTime(year, month,
        day); // Testen ob hier manchmal ein Fehler auftriit und bei day + 1 muss
    return result;
  } else {
    throw Exception('No trips selected');
  }
}

Future<DateTime> getEndtDate() async {
  final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
      await FirebaseFirestore.instance
          .collection('trips')
          .doc('OYcU9dTsakHTtYs5k5uw')
          .get();
  if (documentSnapshot.exists) {
    final DateTime endDate = documentSnapshot.data()!['enddate'].toDate();
    int day = endDate.day;
    int month = endDate.month;
    int year = endDate.year;
    DateTime result = DateTime(year, month,
        day); // Testen ob hier manchmal ein Fehler auftriit und bei day + 1 muss
    return result;
  } else {
    throw Exception('No trips selected');
  }
}

class _CalendarState extends State<Calendar> {
  DateTime? selectedDate; // Ausgewähltes Datum
  DateTime? firstDate;
  DateTime? lastDate;

  DateTime? newStart; // Neues Startdatum
  DateTime? newEnd; // Neues Enddatum

  @override
  void initState() {
    super.initState();
    // Hole Startdatum aus Firebase und initialisiere selectedDate, firstDate und lastDate
    fetchDate();
  }

  void fetchDate() async {
    DateTime startDate = await getStartDate();
    if (DateTime.now().isBefore(startDate)) {
      // Hole Startdatum aus Firebase und initialisiere selectedDate, firstDate und lastDate
      setState(() {
        selectedDate = startDate;
        firstDate = startDate.add(const Duration(days: 1));
        lastDate = startDate.subtract(const Duration(days: 1));
      });
    } else {
      // Hole aktuelles Datum und initialisiere selectedDate, firstDate und lastDate
      setState(() {
        selectedDate = DateTime.now();
        firstDate = DateTime.now().add(const Duration(days: 1));
        lastDate = DateTime.now().subtract(const Duration(days: 1));
      });
    }
  }

  //DateTime getSelectedDate() {
  //  return selectedDate!;
  //}

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
        //Currently DarkMode Calendar
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData
                .dark(), // Hier DarkMode aktivieren Dark und Light Mode noch vlt einbauen
            child: child!,
          );
        },
      );

      if (pickedRange != null) {
        setState(() {
          newStart = pickedRange.start;
          newEnd = pickedRange.end;
          _setNewDateRange(newStart, newEnd);
        });
      }
    }
  }

  void _setNewDateRange(DateTime? newStart, DateTime? newEnd) async {
    if (newStart != null && newEnd != null) {
      final DocumentReference<Map<String, dynamic>> documentReference =
          FirebaseFirestore.instance
              .collection('trips')
              .doc('OYcU9dTsakHTtYs5k5uw');
      try {
        await documentReference.update({
          'startdate': newStart,
          'enddate': newEnd,
        });
        setState(() {
          selectedDate = newStart;
          firstDate = newStart.add(const Duration(days: 1));
          lastDate = newStart.subtract(const Duration(days: 1));
        });
      } catch (e) {
        print(e);
        throw Exception('Could not update date range');
      }
    }
    if(selectedDate != null){
      widget.onDateSelected(selectedDate!);
    }
  }

  void _goToLatestDate() async {
    DateTime startTrip = await getStartDate();
    setState(() {
      if (selectedDate!.isBefore(startTrip)) {
        selectedDate = startTrip;
        firstDate = startTrip.add(const Duration(days: 1));
        lastDate = startTrip.subtract(const Duration(days: 1));
      }
      if (selectedDate!.isAfter(startTrip)) {
        selectedDate = DateTime.now();
        firstDate = DateTime.now().add(const Duration(days: 1));
        lastDate = DateTime.now().subtract(const Duration(days: 1));
      }
    });
    widget.onDateSelected(selectedDate!);
  }

  void _goToNextDate() {
    setState(() {
      selectedDate = selectedDate!.add(const Duration(days: 1));
      firstDate = firstDate!.add(const Duration(days: 1));
      lastDate = lastDate!.add(const Duration(days: 1));
    });
    widget.onDateSelected(selectedDate!);
  }

  void _goToPreviousDate() {
    setState(() {
      selectedDate = selectedDate!.subtract(const Duration(days: 1));
      firstDate = firstDate!.subtract(const Duration(days: 1));
      lastDate = lastDate!.subtract(const Duration(days: 1));
    });
    widget.onDateSelected(selectedDate!);
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
                        child: lastDate != null ? _buildDateText(lastDate!) : _loadingContainer(),
                      ),
                      selectedDate != null ? _buildDateText(selectedDate!, size: 15, selected: true) : _loadingContainer(),
                      GestureDetector(
                        onTap: () {
                          _goToNextDate();
                        },
                        child:firstDate != null ?  _buildDateText(firstDate!) : _loadingContainer(),
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

    DateTime today = DateTime.now();
    DateTime tomorrow = DateTime.now().add(const Duration(days: 1));
    DateTime yesterday = DateTime.now().subtract(const Duration(days: 1));

    return Container(
      width: selected ? 101 : 92.8,
      height: selected ? 76 : 66,
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          Text(
            date.isAtSameMomentAs(DateTime(today.year, today.month, today.day)) ? "Today" 
            : date.isAtSameMomentAs(DateTime(tomorrow.year, tomorrow.month, tomorrow.day)) ? "Tomorrow" 
            : date.isAtSameMomentAs(DateTime(yesterday.year, yesterday.month, yesterday.day)) ? "Yesterday" 
            : DateFormat('dd.MM.yyyy').format(date),
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
