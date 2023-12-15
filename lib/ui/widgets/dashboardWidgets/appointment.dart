import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/widgets/dashboardWidgets/widgetContainer.dart';

class Appointment extends StatefulWidget {
  final IconData icon;
  final String title;
  final String? description;
  final TimeOfDay time;
  const Appointment({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    required this.time,
  });

  @override
  State<Appointment> createState() => _AppointmentState();
}

class _AppointmentState extends State<Appointment> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 18,
        right: 18,
      ),
      child: WidgetContainer(
        isSurvey: false,
        time: widget.time,
        description: widget.description,
        title: widget.title,
        icon: widget.icon,
      ),
    );
  }
}
