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

  // TesterList
  List<ExpandableItem> items = [
    ExpandableItem(text: 'Test1', price: '10 €'),
    ExpandableItem(text: 'Test2', price: '20 €'),
    ExpandableItem(text: 'Test3', price: '30 €'),
    /*ExpandableItem(text: 'Test4', price: '40 €'),
    ExpandableItem(text: 'Test5', price: '50 €'),
    ExpandableItem(text: 'Test6', price: '60 €'),*/
  ];

  double calculateMainHight(List<ExpandableItem> list, double screenHeight) {
    if (list.length >= 4) {
      return screenHeight * 0.33;
    } else if (list.length == 3) {
      return screenHeight * 0.295;
    } else if (list.length == 2) {
      return screenHeight * 0.25;
    } else {
      return screenHeight * 0.21;
    }
  }

  double calculateSmallHight(List<ExpandableItem> list, double height) {
    if (list.length >= 4) {
      return height * 0.159 + 13;
    } else if (list.length == 3) {
      return height * 0.126 + 13;
    } else if (list.length == 2) {
      return height * 0.08 + 13;
    } else {
      return height * 0.038 + 13;
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
            ? calculateMainHight(items, MediaQuery.of(context).size.height)
            : 65.0, // Adjust the height as needed
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
                      padding: const EdgeInsets.only(top: 5.0),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle, color: Colors.grey),
                          ),
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
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.only(top: 5.0),
                      child: Text(
                        '0 €',
                        style: TextStyle(
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
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: SizedBox(
                  height: calculateSmallHight(
                      items, MediaQuery.of(context).size.height),
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 5, right: 5, bottom: 10),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(
                              left: 20, right: 20, top: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                items[index].text,
                                style: Styles.listView,
                              ),
                              Text(
                                items[index].price,
                                style: Styles.listView,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const Padding(
                padding:
                    EdgeInsets.only(top: 5, left: 20, right: 20, bottom: 5),
                child: SlideButton(
                  buttonText: 'Slide to Pay',
                  margin: EdgeInsets.only(bottom: 8),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ExpandableItem {
  final String text;
  final String price;

  ExpandableItem({required this.text, required this.price});
}
