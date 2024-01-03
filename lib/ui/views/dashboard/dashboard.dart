import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/calendar.dart';
import 'package:internet_praktikum/core/services/dashboardData.dart';
import 'package:internet_praktikum/ui/widgets/bottom_sheet.dart';
import 'package:internet_praktikum/ui/views/dashboard/scrollview.dart';
import 'package:internet_praktikum/ui/widgets/dashboardWidgets/createNewWidgetOnDashboard.dart';
import 'package:internet_praktikum/ui/widgets/headerWidgets/topbar.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({super.key});
  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  final user = FirebaseAuth.instance.currentUser!;
  DateTime? selectedDay = DateTime(2023, 10, 1);
  bool showSomething = false;
  DocumentReference? currentDay;

  // A function that automatecly loads the data from the user and fetches the profilepicture

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(
          isDash: true,
          icon: Icons.menu_rounded,
          onTapForIconWidget: () {
            // Hier muss Bürge Menü rein und in diesem Menü soll das was unten steht über ein Add Widget Button aufgerufen werden
            CustomBottomSheet.show(context,
                title: "Add new Widget to your Dashboard",
                content: [
                  FutureBuilder(
                      future: Future.wait([
                        DashBoardData.getUserData(selectedDay!),
                        DashBoardData.getCurrentDaySubCollection(selectedDay!),
                      ]),
                      builder:
                          (context, AsyncSnapshot<List<dynamic>> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snapshot.hasError) {
                          return const Center(
                            child: Text('An error occured!'),
                          );
                        }
                        return CreateNewWidgetOnDashboard(
                            day: snapshot.data![1],
                            userdata: snapshot.data![0]);
                      })
                ]);
          }),
      body: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/background_forest.png'), // assets/BackgroundCity.png
                fit: BoxFit.fitWidth,
              ),
            ),
            child: Column(children: [
              Calendar(onDateSelected: (date) {
                setState(() {
                  selectedDay = date;
                });
              }),
              FutureBuilder(
                  future: Future.wait([
                    DashBoardData.getUserData(selectedDay!),
                    DashBoardData.getCurrentDaySubCollection(selectedDay!),
                  ]),
                  builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (snapshot.hasError) {
                      print(snapshot.error);
                      return const Center(
                        child: Text(
                            'An error occured while fetching data! check your internet connection!'),
                      );
                    }
                    return ScrollViewWidget(
                        day: snapshot.data![1], userdata: snapshot.data![0]);
                  })
            ]),
          ),
        ],
      ),
    );
  }
}
