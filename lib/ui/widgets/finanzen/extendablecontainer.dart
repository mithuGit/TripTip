import 'package:flutter/material.dart';

class ExpandableContainer extends StatefulWidget {
  const ExpandableContainer({Key? key}) : super(key: key);

  @override
  State<ExpandableContainer> createState() => _ExpandableContainerState();
}

class _ExpandableContainerState extends State<ExpandableContainer> {
  bool isExpanded = false;

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
        width: 200.0,
        height: isExpanded ? 150.0 : 50.0,
        color: Colors.grey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isExpanded ? 'Clicked Me' : 'Click Me',
              style: const TextStyle(color: Colors.white),
            ),
            if (isExpanded) ...[
              SizedBox(height: 10.0),
              Text(
                'Essen',
                style: const TextStyle(color: Colors.white),
              ),
              Text(
                'Fahrkarte',
                style: const TextStyle(color: Colors.white),
              ),
              Text(
                'Eintritt',
                style: const TextStyle(color: Colors.white),
              ),
              // Add more items as needed
            ],
          ],
        ),
      ),
    );
  }
}
