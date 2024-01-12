import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';
import 'package:internet_praktikum/ui/widgets/dashboardWidgets/usernameBagageDashboardWidget.dart';
import 'package:intl/intl.dart';

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
                  GestureDetector(
                    onTap: () {},
                    child: const Icon(
                      //Hier muss entschieden werden, ob Icons Group oder Icon Map ist
                      //formattedTime.compareTo(TimeOfDay.now().format(context)) < 0 ? Icons.check : widget.icon,
                      Icons.map_outlined,
                      color: Colors.white,
                      size: 35,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      showCupertinoModalPopup(
                          context: context,
                          builder: (BuildContext context) {
                            return CupertinoTimerPicker(
                              alignment: Alignment.center,
                              mode: CupertinoTimerPickerMode.hm,
                              backgroundColor: Colors.white,
                              onTimerDurationChanged: (value) {
                                setState(() {
                                  formattedTime =
                                      value.toString().substring(0, 5);
                                  print(formattedTime);
                                  setNewTimeForAppointment(
                                      widget.data!, formattedTime);
                                });
                              },
                            );
                          });
                    },
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
