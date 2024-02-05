// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internet_praktikum/ui/widgets/container.dart';
import 'package:internet_praktikum/ui/widgets/my_button.dart';

///Site to choose for either joining or creating trips
class SelectTrip extends StatelessWidget {
  SelectTrip({super.key, required this.noTrip});

  bool noTrip;

  ///Widget builder, changes with noTrip to not allow the user to go back when there is nothing to go back(no other trips available)
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
                        top: 200, left: 14, right: 14, bottom: 230),
                    child: CustomContainer(
                        smallSize: true,
                        title: "Start your next Adventure",
                        children: [
                          MyButton(
                              margin:
                                  const EdgeInsets.only(top: 15, bottom: 10),
                              onTap: () {
                                context.push('/createtrip');
                              },
                              text: "Create Trip"),
                          MyButton(
                              margin: const EdgeInsets.only(bottom: 10),
                              onTap: () {
                                context.push('/jointrip');
                              },
                              text: "Join Trip"),
                          if (!noTrip) ...[
                            MyButton(
                                margin: const EdgeInsets.only(bottom: 10),
                                onTap: () {
                                  context.pop();
                                },
                                text: "Cancel")
                          ],
                        ])),
              )),
        ])));
  }
}
