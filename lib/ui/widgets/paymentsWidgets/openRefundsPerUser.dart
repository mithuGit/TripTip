// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/core/services/paymentsHandeler.dart';
import 'package:internet_praktikum/ui/widgets/errorSnackbar.dart';
import 'package:internet_praktikum/ui/widgets/paymentsWidgets/slidablebutton.dart';

// This Container is used to display the open refunds of a user
// It is expandable and can be expanded by clicking on it

class OpenRefundsPerUser extends StatefulWidget {
  final double sum;
  final EdgeInsetsGeometry? margin;
  final DocumentSnapshot currentUser;
  final DocumentReference me;
  final DocumentReference trip;
  final List<Map<String, dynamic>> openRefunds;
  const OpenRefundsPerUser({
    Key? key,
    required this.sum,
    required this.currentUser,
    required this.openRefunds,
    required this.me,
    required this.trip,
    this.margin,
  }) : super(key: key);

  @override
  State<OpenRefundsPerUser> createState() => _OpenRefundsPerUserState();
}

class _OpenRefundsPerUserState extends State<OpenRefundsPerUser> {
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
  }

  double calculateHeight(double height) {
    // 80 because of slideable Button
    // 43 because of every refund
    return 57 + widget.openRefunds.length * 43 + 80;
  }

  double calculateHeightSmallList(double containerWidth) {
    if (widget.openRefunds.length >= 4 || widget.openRefunds.length == 3) {
      return containerWidth * 0.58;
    } else if (widget.openRefunds.length == 2) {
      return containerWidth * 0.40;
    }
    return containerWidth * 0.24;
  }
  /*
  color: const Color(0xE51E1E1E),
          border: Border.all(color: const Color(0xE51E1E1E)),
          borderRadius: BorderRadius.circular(34.5),
        ),
  */

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height:
          isExpanded ? calculateHeight(MediaQuery.of(context).size.height) : 68,
      decoration: BoxDecoration(
        color: const Color(0xE51E1E1E),
        border: Border.all(color: const Color(0xE51E1E1E)),
        borderRadius: BorderRadius.circular(34.5),
      ),
      child: GestureDetector(
        onTap: () {
          setState(() {
            isExpanded = !isExpanded;
          });
        },
        child: ClipRect(
          child: Wrap(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: 7.0,
                  left: 10,
                  right: 25,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundImage: (widget.currentUser.data()! as Map<
                                  String, dynamic>)["profilePicture"] !=
                              null
                          ? NetworkImage((widget.currentUser.data()!
                              as Map<String, dynamic>)["profilePicture"])
                          : const AssetImage('assets/Personavatar.png')
                              as ImageProvider<Object>,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      (widget.currentUser.data()!
                              as Map<String, dynamic>)["prename"] +
                          " " +
                          (widget.currentUser.data()!
                              as Map<String, dynamic>)["lastname"],
                      style: const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${widget.sum} €',
                      style: const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              if (isExpanded) ...[
                Padding(
                  padding: const EdgeInsets.only(
                    top: 10,
                    left: 10,
                    right: 25,
                  ),
                  child: Column(
                    children: [
                      for (int i = 0; i < widget.openRefunds.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 5, top: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  widget.openRefunds[i]["title"],
                                  style: const TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                '${widget.openRefunds[i]["amount"]} €',
                                style: const TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              if (isExpanded) ...[
                Padding(
                  padding: const EdgeInsets.only(
                      top: 20, left: 10, right: 10, bottom: 7),
                  child: SlideButton(
                    onSubmit: () => PaymentsHandeler.payOpenRefundsPerUser(
                            widget.currentUser.reference, widget.trip)
                        .onError((error, stackTrace) =>
                            ErrorSnackbar.showErrorSnackbar(
                                context, error.toString())),
                    buttonText: 'Slide to Pay',
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
