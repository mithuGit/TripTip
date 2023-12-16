import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';
import 'package:intl/intl.dart';

class WidgetContainer extends StatefulWidget {
  final String title;
  final List<Widget>? children;
  final IconData? icon;
  final bool isSurvey;
  final String? description;
  final TimeOfDay? time;

  const WidgetContainer(
      {super.key,
      required this.title,
      this.children,
      this.icon,
      required this.isSurvey,
      this.description,
      this.time});

  @override
  State<WidgetContainer> createState() => _WidgetContainerState();
}

class _WidgetContainerState extends State<WidgetContainer> {
  @override
  Widget build(BuildContext context) {
    String formattedTime = '';

    if (widget.time != null) {
      final dateTime =
          DateTime(2023, 1, 1, widget.time!.hour, widget.time!.minute);
      formattedTime = DateFormat('HH:mm').format(dateTime);
    }

    return Container(
        decoration: const BoxDecoration(
          color: Color(0xE51E1E1E),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (widget.children != null)
                  for (var child in widget.children!) child,
                if (widget.description != null || widget.time != null)
                  Row(
                    mainAxisAlignment: widget.description != null
                        ? MainAxisAlignment.spaceBetween
                        : MainAxisAlignment.center,
                    children: [
                      widget.description != null
                          ? SizedBox(
                              width: 250,
                              child: Text(
                                widget.description!,
                                style: Styles.descriptionofwidget,
                              ),
                            )
                          : Container(),
                      Column(
                        children: [
                          Icon(
                            //formattedTime.compareTo(TimeOfDay.now().format(context)) < 0 ? Icons.check : widget.icon,
                            widget.icon,
                            color: Colors.white,
                            size: 35,
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
                                          formattedTime = value
                                              .toString()
                                              .substring(0, 5);
                                          print(formattedTime);
                                        });
                                      },
                                    );
                                  });
                            },
                            child: Text(formattedTime,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ], /////DateFormat('dd.MM.yyyy').format(date),
                      )
                    ],
                  ),
              ],
            ),
          ),
        ));
  }
}