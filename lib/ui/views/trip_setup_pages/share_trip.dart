// ignore_for_file: must_be_immutable, use_build_context_synchronously,

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';
import 'package:internet_praktikum/ui/widgets/container.dart';
import 'package:internet_praktikum/ui/widgets/errorSnackbar.dart';
import 'package:internet_praktikum/ui/widgets/inputfield.dart';
import 'package:internet_praktikum/ui/widgets/my_button.dart';

///Site to share tripid with others, or use user id to add them to current trip
class ShareTrip extends StatefulWidget {
  String tripId;
  String? afterCreate;
  ShareTrip({super.key, required this.tripId, this.afterCreate});

  Color buttonColor = Colors.grey;
  Color buttonFill = Colors.white;
  var buttonIcon = Icons.copy;
  final groupController = TextEditingController();
  var userReal = false;
  @override
  State<ShareTrip> createState() => _ShareTrip();
}

/// adds user from text field into current trip
class _ShareTrip extends State<ShareTrip> {
  Future userExists(String username) async {
    await FirebaseFirestore.instance
        .collection("users")
        .where("uid", isEqualTo: username)
        .get()
        .then((QuerySnapshot value) {
      setState(() {
        widget.userReal = value.size > 0;
      });
    });
  }

  ///Widget builder, adds tripid to copy, and textfield for userid
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
                        title: "Share your Adventure",
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SelectableText.rich(
                                  TextSpan(
                                      text: widget.tripId,
                                      style:
                                          Styles.mainDasboardinitializerTitle),
                                ),
                                Card(
                                    color: widget.buttonFill,
                                    margin: const EdgeInsets.only(left: 10),
                                    child: IconButton(
                                        onPressed: () {
                                          Clipboard.setData(ClipboardData(
                                              text: widget.tripId));
                                          setState(() {
                                            widget.buttonFill = Colors.green;
                                            widget.buttonIcon = Icons.check;
                                            widget.buttonColor = Colors.white;
                                          });
                                        },
                                        icon: Icon(
                                          widget.buttonIcon,
                                          color: widget.buttonColor,
                                        )))
                              ]),
                          InputField(
                              margin:
                                  const EdgeInsets.only(bottom: 10, top: 10),
                              controller: widget.groupController,
                              hintText: "FriendId",
                              obscureText: false,
                              multiline: false),
                          MyButton(
                              text: "Add Friend",
                              margin: const EdgeInsets.only(bottom: 10),
                              onTap: () async {
                                await userExists(widget.groupController.text);

                                if (widget.groupController.text == "") {
                                  ErrorSnackbar.showErrorSnackbar(
                                      context, "Id cant be empty!");
                                } else if (widget.userReal == false) {
                                  ErrorSnackbar.showErrorSnackbar(
                                      context, "User not found!");
                                } else {
                                  FirebaseFirestore.instance
                                      .collection("trips")
                                      .doc(widget.tripId)
                                      .update({
                                    "members": FieldValue.arrayUnion([
                                      // ignore: prefer_interpolation_to_compose_strings
                                      FirebaseFirestore.instance.doc("/users/" +
                                          widget.groupController.text)
                                    ])
                                  });
                                  widget.groupController.clear();
                                }
                              }),
                          if (widget.afterCreate == "true") ...[
                            MyButton(
                                margin: const EdgeInsets.only(bottom: 10),
                                onTap: () {
                                  context.go('/');
                                },
                                text: "Finish")
                          ] else ...[
                            MyButton(
                                margin: const EdgeInsets.only(bottom: 10),
                                onTap: () {
                                  context.pop();
                                },
                                text: "Back")
                          ]
                        ])),
              )),
        ])));
  }
}
