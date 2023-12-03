import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internet_praktikum/main.dart';
import 'package:internet_praktikum/ui/views/trip_setup_pages/create_trip.dart';
import 'package:internet_praktikum/ui/views/trip_setup_pages/join_trip.dart';
import 'package:internet_praktikum/ui/widgets/container.dart';
import 'package:internet_praktikum/ui/widgets/my_button.dart';

class SelectTrip extends StatelessWidget {
  const SelectTrip({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFCBEFFF),
        resizeToAvoidBottomInset: false,
        body: SafeArea(
            child: Stack(children: [
          Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/BackgroundCity.png'),
                    fit: BoxFit.cover),
              ),
              child: Center(
                child: Padding(
                    padding: const EdgeInsets.only(
                        top: 80, left: 14, right: 14, bottom: 45),
                    child: CustomContainer(
                        title: "Start your next Adventure",
                        children: [
                          MyButton(
                              onTap: () {
                               context.go('/createtrip');
                              },
                              text: "Create Trip"),
                          MyButton(
                              onTap: () {
                                context.go('/jointrip');
                              },
                              text: "Join Trip")
                        ])),
              )),
        ])));
  }
}
