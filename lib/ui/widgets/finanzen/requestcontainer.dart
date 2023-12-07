import 'package:flutter/material.dart';
import '../inputfield.dart';

import '../../styles/Styles.dart';
import '../addButton.dart';

class RequestContainer extends StatefulWidget {
  final List<Widget> items;
  final String name;
  const RequestContainer({Key? key, required this.items, required this.name})
      : super(key: key);

  @override
  State<RequestContainer> createState() => _RequestContainerState();
}

double calculateMainHight(List<Widget> list, double screenHeight) {
  if (list.length >= 4) {
    return screenHeight * 0.33;
  } else if (list.length == 3) {
    return screenHeight * 0.39;
  } else if (list.length == 2) {
    return screenHeight * 0.3;
  } else {
    return screenHeight * 0.34;
  }
}

double calculateSmallHight(List<Widget> list, double height) {
  if (list.length >= 4) {
    return height * 0.159 + 10;
  } else if (list.length == 3) {
    return height * 0.24 + 10;
  } else if (list.length == 2) {
    return height * 0.15 + 10;
  } else {
    return height * 0.038 + 10;
  }
}

class _RequestContainerState extends State<RequestContainer> {
  late double mainHeight;
  late double minHeight;
  late List<Widget> liste;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    mainHeight = MediaQuery.of(context).size.height * 0.36;
    minHeight = MediaQuery.of(context).size.height * 0.24 + 10;
    liste = List.from(widget.items);
  }

  bool isExpanded = true;

  @override
  Widget build(BuildContext context) {
    print("List length: ${liste.length}");
    return GestureDetector(
      onTap: () {
        setState(() {
          isExpanded = !isExpanded;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        height: isExpanded ? mainHeight : 65.0,
        decoration: BoxDecoration(
          color: const Color(0xE51E1E1E),
          border: Border.all(color: const Color(0xE51E1E1E)),
          borderRadius: BorderRadius.circular(34.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Text(
                              widget.name,
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
                      padding: EdgeInsets.only(top: 5.0),
                      child: AddButton(
                        color: Colors.white,
                        onPressed: () {
                          setState(() {
                            mainHeight += 150;
                            liste = [
                              ...liste,
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: InputField(
                                      hintText: 'Aktivität',
                                      obscureText: false,
                                      margin: EdgeInsets.only(
                                          bottom: 25, right: 5, left: 15),
                                    ),
                                  ),
                                  Expanded(
                                    child: InputField(
                                      hintText: 'Preis',
                                      obscureText: false,
                                      margin: EdgeInsets.only(
                                          bottom: 25, left: 5, right: 15),
                                    ),
                                  ),
                                ],
                              ),
                            ];
                          });
                        },
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isExpanded) ...[
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: SizedBox(
                  height: minHeight,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 5,
                      right: 5,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // New Row with InputField widgets
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: InputField(
                                  hintText: 'Aktivität',
                                  obscureText: false,
                                  margin: EdgeInsets.only(
                                      bottom: 25, right: 5, left: 15),
                                ),
                              ),
                              Expanded(
                                child: InputField(
                                  hintText: 'Preis',
                                  obscureText: false,
                                  margin: EdgeInsets.only(
                                      bottom: 25, left: 5, right: 15),
                                ),
                              ),
                            ],
                          ),
                          // Concatenate liste and widget.items
                          ...(liste + widget.items),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
