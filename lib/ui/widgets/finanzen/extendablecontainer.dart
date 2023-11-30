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
        child: Center(
          child: Text(
            isExpanded ? 'Expanded - Click to Shrink' : 'Click to Expand',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
