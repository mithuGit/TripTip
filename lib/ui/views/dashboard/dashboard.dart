import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:internet_praktikum/calendar.dart';
import 'package:internet_praktikum/core/services/dashboardData.dart';
import 'package:internet_praktikum/ui/widgets/bottom_sheet.dart';
import 'package:internet_praktikum/ui/views/dashboard/scrollview.dart';
import 'package:internet_praktikum/ui/widgets/centerText.dart';
import 'package:internet_praktikum/ui/widgets/dashboardWidgets/createNewWidgetOnDashboard.dart';
import 'package:internet_praktikum/ui/widgets/headerWidgets/topbar.dart';

class DashBoard extends StatefulWidget {
  final String? showDateViaLink;
  const DashBoard({super.key, this.showDateViaLink});
  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  final user = FirebaseAuth.instance.currentUser!;
  DateTime? selectedDay;
  bool isLoading = true;
  bool hasErrorWhileLoadingUser = false;
  bool hasErrorWhileLoadingDay = false;

  Error? errorWhileLoadingUser;
  Error? errorWhileLoadingDay;

  Map<String, dynamic>? userdata;
  DocumentReference? selectedDayReference;

  // After the DashBoard is loaded, the userdata is loaded
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      try {
        userdata = await DashBoardData.getUserData();
      } catch (e) {
        setState(() {
          isLoading = false;
          hasErrorWhileLoadingUser = true;
          errorWhileLoadingUser = e as Error;
        });
      }
    });
  }

  // When ever the selectedDay is changed, the the current selectedDay is loaded
  Future<void> changeDay(DateTime selectedDayParam) async {
    if (selectedDayReference == null) {
      setState(() {
        isLoading = true;
      });
    }
    try {
      selectedDayReference =
          await DashBoardData.getCurrentDaySubCollection(selectedDayParam);
      setState(() {
        isLoading = false;
        selectedDay = selectedDayParam;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        hasErrorWhileLoadingDay = true;
        errorWhileLoadingDay = e as Error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(
          isDash: true,
          popupButton: PopupMenuButton(
            icon: const Icon(Icons.menu_rounded),
            onSelected: (value) => {
              // This is the popup menu in the dashboard
              switch (value) {
                "archive" => {context.go("/archive")},
                "changeTrip" => {context.go("/changetrip")},
                "createWidget" => {
                    CustomBottomSheet.show(context,
                        title: "Add new Widget to your Dashboard",
                        content: [
                          Builder(builder: (context) {
                            if (isLoading) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (hasErrorWhileLoadingDay) {
                              return Center(
                                child: Text(
                                    "An error occured while loading Daydata data: ${errorWhileLoadingDay!.toString()}"),
                              );
                            }
                            if (hasErrorWhileLoadingUser) {
                              return Center(
                                child: Text(
                                    "An error occured while loading User data: ${errorWhileLoadingUser!.toString()}"),
                              );
                            }
                            return CreateNewWidgetOnDashboard(
                                day: selectedDayReference!,
                                userdata: userdata!);
                          })
                        ])
                  },
                _ => (),
              }
            },
            itemBuilder: (BuildContext c) {
              return [
                const PopupMenuItem(
                  value: "changeTrip",
                  child: Text("Trip Management"),
                ),
                // You can't create widgets for days in the past
                if (dashboardIsEditable()) ...[
                  const PopupMenuItem(
                    value: "createWidget",
                    child: Text("Create Widget"),
                  ),
                ],
                const PopupMenuItem(
                  value: "archive",
                  child: Text("Archive"),
                )
              ];
            },
          )),
      body: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background_forest.png'),
                fit: BoxFit.fitWidth,
              ),
            ),
            // Here the calendar and the scrollview are loaded
            child: Padding(
              padding: const EdgeInsets.only(bottom: 65),
              child: Column(children: [
                Calendar(onDateSelected: (date) {
                  changeDay(date);
                }),
                Builder(builder: (context) {
                  if (isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (hasErrorWhileLoadingDay) {
                    return CenterText(
                        text:
                            "An error occured while loading Daydata data: ${errorWhileLoadingDay!.toString()}");
                  }
                  if (hasErrorWhileLoadingUser) {
                    return CenterText(
                        text:
                            "An error occured while loading User data: ${errorWhileLoadingUser!.toString()}");
                  }

                  // here are all Scrollview Widgets loaded
                  return ScrollViewWidget(
                      day: selectedDayReference!, userdata: userdata!, isEditable: dashboardIsEditable(),);
                })
              ]),
            ),
          ),
        ],
      ),
    );
  }

  bool dashboardIsEditable() {
    return selectedDay!.isAfter(DateTime(
            DateTime.now().year, DateTime.now().month, DateTime.now().day)) ||
        selectedDay!.isAtSameMomentAs(DateTime(
            DateTime.now().year, DateTime.now().month, DateTime.now().day));
  }
}
