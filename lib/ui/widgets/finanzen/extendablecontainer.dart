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
              const SizedBox(height: 10.0),
              const Text(
                'Essen',
                style: TextStyle(color: Colors.white),
              ),
              const Text(
                'Fahrkarte',
                style: TextStyle(color: Colors.white),
              ),
              const Text(
                'Eintritt',
                style: TextStyle(color: Colors.white),
              ),
              // Add more items as needed
            ],
          ],
        ),
      ),
    );
  }
}
