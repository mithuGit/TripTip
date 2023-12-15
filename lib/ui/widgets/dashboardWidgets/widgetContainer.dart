import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';
import 'package:internet_praktikum/ui/widgets/bottom_sheet.dart';
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

    return LayoutBuilder(
      builder: (context, constraints) => Container(
          decoration: BoxDecoration(
            color: const Color(0xE51E1E1E),
            borderRadius: BorderRadius.circular(34.5),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          height: 25, // kurz entfernen
                          child: Text(
                            widget.title,
                            style: Styles.overlayTitle,
                            textAlign: TextAlign.left,
                          ),
                        ),
                        if (widget.isSurvey)
                          GestureDetector(
                              onTap: () {
                                CustomBottomSheet.show(context,
                                    title: "Add New Recommendation",
                                    content: [
                                      // HIER SOLLTE MAN NEUE VORSCHLÄGE HINZUFÜGEN KÖNNEN
                                    ]);
                              },
                              child: const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 35,
                              ))
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
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
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            image: const DecorationImage(
                              image:
                                  AssetImage('assets/mainpage_pic/profile.png'),
                              fit: BoxFit.cover,
                            ),
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(34.5),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        const SizedBox(
                          child: Text(
                            'Created at 12:00 by Mithu',
                            style: Styles.creatorofwidget,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )),
    );
  }
}
