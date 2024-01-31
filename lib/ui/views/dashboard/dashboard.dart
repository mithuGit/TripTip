import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:internet_praktikum/ui/widgets/dashboardWidgets/calendar.dart';
import 'package:internet_praktikum/core/services/dashboardData.dart';
import 'package:internet_praktikum/ui/widgets/bottom_sheet.dart';
import 'package:internet_praktikum/ui/views/dashboard/scrollview.dart';
import 'package:internet_praktikum/ui/widgets/centerText.dart';
import 'package:internet_praktikum/ui/widgets/dashboardWidgets/createNewWidgetOnDashboard.dart';
import 'package:internet_praktikum/ui/widgets/errorSnackbar.dart';
import 'package:internet_praktikum/ui/widgets/headerWidgets/topbar.dart';

class DashBoard extends StatefulWidget {
  final String? showDay;
  final String? showTrip;
  const DashBoard({super.key, this.showDay, this.showTrip});
  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  final user = FirebaseAuth.instance.currentUser!;
  DateTime? selectedDay;
  bool isLoading = true;
  bool hasErrorWhileLoadingUser = false;
  bool hasErrorWhileLoadingDay = false;

  String? errorWhileLoadingUser;
  String? errorWhileLoadingDay;

  Map<String, dynamic>? userdata;
  DocumentReference? selectedDayReference;
  DocumentReference? selectedTripReference;

  Future<void> loadData() async {
    try {
      if (widget.showDay != null && widget.showTrip != null) {
        DocumentReference selectedDayReferenceP =
            FirebaseFirestore.instance.doc(widget.showDay!);
        DocumentSnapshot selectedDaySnapshot =
            await selectedDayReferenceP.get();
        if (!selectedDaySnapshot.exists) throw "Day does not exist";
        DateTime startDate =
            (selectedDaySnapshot.data()! as Map<String, dynamic>)["starttime"]
                .toDate();
        try {
          DocumentSnapshot selectedTripSnapshot =
              await FirebaseFirestore.instance.doc(widget.showTrip!).get();
          if (!selectedTripSnapshot.exists) throw "Trip does not exist";
        } catch (e) {
          throw UserIsNotInTripException();
        }
        DocumentReference selectedTripReferenceP =
            FirebaseFirestore.instance.doc(widget.showTrip!);

        Map<String, dynamic> userdataP = await DashBoardData.getUserData();
        setState(() {
          isLoading = false;
          selectedDay = startDate;
          selectedDayReference = selectedDayReferenceP;
          selectedTripReference = selectedTripReferenceP;
          userdata = userdataP;
        });
      } else {
        Map<String, dynamic> userdataP = await DashBoardData.getUserData();
        DocumentReference selectedTripReferenceP =
            await DashBoardData.getCurrentTrip();
        setState(() {
          userdata = userdataP;
          selectedTripReference = selectedTripReferenceP;
        });
      }
    } on UserIsNotInTripException catch (_) {
      if (mounted) {
        context.go("/changetrip");
      }
    } on UserHasNoSelectedTripException catch (_) {
      if (mounted) {
        context.go("/changetrip");
      }
    } catch (e) {
      debugPrint(e.toString());
      setState(() {
        isLoading = false;
        hasErrorWhileLoadingUser = true;
        errorWhileLoadingUser = e.toString();
      });
    }
  }

  // After the DashBoard is loaded, the userdata is loaded
  @override
  void initState() {
    super.initState();
    //  loadData();
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await loadData();
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
      selectedDayReference = await DashBoardData.getCurrentDaySubCollection(
          selectedDayParam, selectedTripReference!);
      setState(() {
        isLoading = false;
        selectedDay = selectedDayParam;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        hasErrorWhileLoadingDay = true;
        errorWhileLoadingDay = e.toString();
      });
    }
  }

  // This function checks if the user has already created 100 widgets for the selected day
  // If so, the user can't create more widgets
  Future<void> checkIfMaxWidgetIsReached(DocumentReference selectedDayReference,
      Map<String, dynamic> userdata) async {
    try {
      DocumentSnapshot daySnapshot = await selectedDayReference.get();
      if (!daySnapshot.exists) throw "Day does not exist";
      Map<String, dynamic> dayData =
          daySnapshot.data()! as Map<String, dynamic>;
      if (dayData["active"] != null) {
        if (dayData["active"].length >= 100) {
          if (context.mounted) {
            ErrorSnackbar.showErrorSnackbar(
                context, "You can't create more than 100");
            return;
          }
        }
      }
      if (context.mounted) {
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
                    day: selectedDayReference, userdata: userdata);
              })
            ]);
      }
    } catch (e) {
      if (context.mounted) {
        ErrorSnackbar.showErrorSnackbar(
            context, "Error while checking if to many widgets are created");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // loadData();
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
                    checkIfMaxWidgetIsReached(selectedDayReference!, userdata!),
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
                if (selectedTripReference != null) ...[
                  Calendar(
                      selectedTrip: selectedTripReference!,
                      initSelectedDate: selectedDay,
                      onDateSelected: (date) {
                        changeDay(date);
                      }),
                ],
                Builder(builder: (context) {
                  if (isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (hasErrorWhileLoadingUser) {
                    return CenterText(
                        text:
                            "An error occured while loading User data: ${errorWhileLoadingUser!}");
                  }
                  if (hasErrorWhileLoadingDay) {
                    return CenterText(
                        text:
                            "An error occured while loading Daydata data: ${errorWhileLoadingDay!}");
                  }

                  // here are all Scrollview Widgets loaded
                  return ScrollViewWidget(
                    day: selectedDayReference!,
                    userdata: userdata!,
                    isEditable: dashboardIsEditable(),
                  );
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
