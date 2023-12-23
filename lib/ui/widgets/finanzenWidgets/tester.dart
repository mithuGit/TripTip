import 'package:flutter/material.dart';

class ResizableContainer extends StatefulWidget {
  const ResizableContainer({Key? key}) : super(key: key);

  @override
  State<ResizableContainer> createState() => ResizableContainerState();
}

class ResizableContainerState extends State<ResizableContainer> {
  double containerHeight = 200;

  void increaseHeight() {
    setState(() {
      containerHeight += 100;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          children: [
            Container(
              height: containerHeight,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xE51E1E1E), // Grey background color
                border: Border.all(color: const Color(0xE51E1E1E)),
                borderRadius: BorderRadius.circular(34.5),
              ),
              child: Center(
                child: Text(
                  'Container Height: ${containerHeight.toString()} px',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: increaseHeight,
                  child: const Text('Increase Height'),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
