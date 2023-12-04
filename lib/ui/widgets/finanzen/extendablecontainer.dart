import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/widgets/finanzen/slidablebutton.dart';

import '../../styles/Styles.dart';

class ExpandableContainer extends StatefulWidget {
  const ExpandableContainer({Key? key, required this.name}) : super(key: key);

  final String name;

  @override
  State<ExpandableContainer> createState() => _ExpandableContainerState();
}

class _ExpandableContainerState extends State<ExpandableContainer> {
  bool isExpanded = false;

  // Example list of strings
  List<String> additionalTexts = [
    'Test1',
    'Test1',
    'Test1',
    'Test1',
  ];

  double calculateMainHight(List<String> list) {
    if (list.length >= 4) {
      return 270;
    } else if (list.length == 3) {
      return 260;
    } else if (list.length == 2) {
      return 210;
    } else {
      return 200;
    }
  }

  double calculateSmallHight(List<String> list) {
    if (list.length >= 4) {
      return 230;
    } else if (list.length == 3) {
      return 220;
    } else if (list.length == 2) {
      return 170;
    } else {
      return 160;
    }
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
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        height: isExpanded
            ? calculateMainHight(additionalTexts)
            : 60.0, // Adjust the height as needed
        decoration: BoxDecoration(
          color: const Color(0xE51E1E1E), // Grey background color
          border: Border.all(color: const Color(0xE51E1E1E)),
          borderRadius: BorderRadius.circular(34.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 10.0,
                left: 25,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.name,
                    style: const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      right: 25,
                      top: 10,
                    ),
                    child: Icon(
                      isExpanded ? Icons.remove : Icons.add,
                      size: 18.0,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            if (isExpanded) ...[
              SizedBox(
                height: calculateSmallHight(additionalTexts),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, top: 10, right: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 20, top: 10, right: 20),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: additionalTexts.length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                child: Text(additionalTexts[index],
                                    style: Styles.listView),
                              );
                            },
                          ),
                        ),
                      ),
                      const SlideButton(
                        buttonText: 'Slide to Pay',
                        margin: EdgeInsets.only(top: 25, bottom: 20),
                      ),
                    ],
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
