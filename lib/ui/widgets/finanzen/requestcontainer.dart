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

class _RequestContainerState extends State<RequestContainer> {
  late double mainHeight;
  late double minHeight;
  late List<Widget> liste = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // man ruft den Button immer mit zwei Widgets auf
    mainHeight = MediaQuery.of(context).size.height * 0.27;
    minHeight = MediaQuery.of(context).size.height * 0.17 + 10;
  }

  bool isExpanded = true;

  @override
  Widget build(BuildContext context) {
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
                          print(
                              "List length: ${(widget.items + liste).length}");
                          setState(() {
                            if ((widget.items + liste).length == 2) {
                              mainHeight += mainHeight * 33 / 100;
                              minHeight += minHeight * 30 / 100;
                            } else if ((widget.items + liste).length == 3) {
                              mainHeight += mainHeight * 20 / 100;
                              minHeight += minHeight * 36 / 100;
                            }

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
                          ...(widget.items + liste),
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
