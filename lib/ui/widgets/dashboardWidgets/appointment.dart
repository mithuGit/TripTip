import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internet_praktikum/core/services/map_service.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';
import 'package:internet_praktikum/ui/widgets/dashboardWidgets/usernameBagageDashboardWidget.dart';
import 'package:intl/intl.dart';

// An AppointmentWidget is used to display an appointment on the dashboard

class AppointmentWidget extends StatefulWidget {
  final Map<String, dynamic>? data;

  const AppointmentWidget({
    super.key,
    this.data,
  });

  @override
  State<AppointmentWidget> createState() => _AppointmentWidgetState();
}

void setNewTimeForAppointment(Map<String, dynamic> data, String time) {
  data["time"] = Timestamp.fromDate(DateTime.parse(time));
}

class _AppointmentWidgetState extends State<AppointmentWidget> {
  @override
  Widget build(BuildContext context) {
    String formattedTime = widget.data!["date"] != null
        ? DateFormat('HH:mm')
            .format((widget.data!["date"] as Timestamp).toDate())
        : '';

    return Center(
        child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: widget.data!["content"] != ""
                ? MainAxisAlignment.spaceBetween
                : MainAxisAlignment.center,
            children: [
              widget.data!["content"] != ""
                  ? SizedBox(
                      width: 250,
                      child: Text(
                        widget.data!["content"]!,
                        style: Styles.descriptionofwidget,
                      ),
                    )
                  : Container(),
              Column(
                children: [
                  Builder(builder: (context) {
                    if (widget.data!["place"] != null) {
                      return IconButton(
                          icon: const Icon(Icons.map_outlined),
                          color: Colors.white,
                          iconSize: 35,
                          onPressed: () {
                            context.pushReplacement("/map",
                                extra: Place.fromMap(widget.data!["place"]));
                          });
                    }
                    return const Icon(
                      Icons.group,
                      color: Colors.white,
                      size: 35,
                    );
                  }),
                  Container(
                    child: formattedTime != ""
                        ? Text(formattedTime,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold))
                        : Container(),
                  ),
                ], /////DateFormat('dd.MM.yyyy').format(date),
              )
            ],
          ),
          UsernameBagageDashboardWidget(data: widget.data),
        ],
      ),
    ));
  }
}
