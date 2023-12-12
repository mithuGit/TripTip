import 'package:flutter/material.dart';

class ExpandableContainer extends StatefulWidget {
  const ExpandableContainer({Key? key, required this.name}) : super(key: key);

  final String name;

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
        height: isExpanded ? 100.0 : 60.0, // Adjust the height as needed
        decoration: BoxDecoration(
          color: const Color(0xE51E1E1E), // Grey background color
          border: Border.all(color: const Color(0xE51E1E1E)),
          borderRadius: BorderRadius.circular(34.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 25),
              child: Text(
                widget.name,
                style: const TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 25),
              child: Icon(
                isExpanded ? Icons.remove : Icons.add,
                size: 18.0,
                color: Colors.white,
              ),
            ),
            if (isExpanded) ...[
              const SizedBox(height: 6.0),
              const Text(
                'Additional Text',
                style: TextStyle(fontSize: 12.0),
              ),
              // You can add more text or widgets here based on your requirements
            ],
          ],
        ),
      ),
    );
  }
}
