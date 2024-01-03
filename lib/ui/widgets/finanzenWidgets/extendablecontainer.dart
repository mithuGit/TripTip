import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/widgets/finanzenWidgets/slidablebutton.dart';

class ExpandableContainer extends StatefulWidget {
  final List<String> items;
  final double sum;
  DocumentSnapshot currentUser;
  ExpandableContainer({
    Key? key,
    required this.items,
    required this.sum,
    required this.currentUser,
  }) : super(key: key);

  @override
  State<ExpandableContainer> createState() => _ExpandableContainerState();
}

class _ExpandableContainerState extends State<ExpandableContainer> {
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
  }

  double calculateHeight(double height) {
    if (widget.items.length >= 4 || widget.items.length == 3) {
      return height * 0.38;
    } else if (widget.items.length == 2) {
      return height * 0.30;
    }
    return height * 0.24;
  }

  double calculateHeightSmallList(double containerWidth) {
    if (widget.items.length >= 4 || widget.items.length == 3) {
      return containerWidth * 0.58;
    } else if (widget.items.length == 2) {
      return containerWidth * 0.40;
    }
    return containerWidth * 0.24;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isExpanded = !isExpanded;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: isExpanded
            ? calculateHeight(MediaQuery.of(context).size.height)
            : 66.0,
        decoration: BoxDecoration(
          color: const Color(0xE51E1E1E),
          border: Border.all(color: const Color(0xE51E1E1E)),
          borderRadius: BorderRadius.circular(34.5),
        ),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 5.0,
                      left: 10,
                      right: 25,
                      bottom: 5.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding:
                                const EdgeInsets.only(top: 2.0, bottom: 2.0),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 25,
                                  backgroundImage: (widget.currentUser.data()!
                                                  as Map<String, dynamic>)[
                                              "profilePicture"] !=
                                          null
                                      ? NetworkImage((widget.currentUser.data()!
                                              as Map<String, dynamic>)[
                                          "profilePicture"])
                                      : const AssetImage(
                                              'assets/Personavatar.png')
                                          as ImageProvider<Object>,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 10.0),
                                  child: Text(
                                    (widget.currentUser.data()! as Map<String,
                                            dynamic>)["prename"] +
                                        " " +
                                        (widget.currentUser.data()! as Map<
                                            String, dynamic>)["lastname"],
                                    style: const TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 5.0, left: 140, right: 5),
                            child: Text(
                              '${widget.sum} €',
                              style: const TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isExpanded) ...[
                    SizedBox(
                      width: double.infinity,
                      height: calculateHeightSmallList(
                          calculateHeight(MediaQuery.of(context).size.height)),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: widget.items.length,
                        itemBuilder: (BuildContext context, int index) {
                          List<String> itemParts =
                              widget.items[index].split(':');
                          String activity = itemParts[0];
                          String price = itemParts[1];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 0, right: 5),
                            child: ListTile(
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    activity,
                                    style: const TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    '$price€',
                                    style: const TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isExpanded)
              const Positioned(
                left: 15,
                right: 15,
                bottom: 5,
                child: SlideButton(
                  buttonText: 'Slide to Pay',
                  margin: EdgeInsets.only(bottom: 8),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
