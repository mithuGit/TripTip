import '../styles/Styles.dart';
import 'package:flutter/material.dart';

class CustomContainer extends StatelessWidget {
  final String title;
  final bool? smallSize;
  final List<Widget> children;

  const CustomContainer(
      {super.key, required this.title, this.smallSize, required this.children});

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double screenHeight = screenSize.height;
    double screenWidth = screenSize.width;
    return Container(
        width: screenWidth * (0.925),
        height: smallSize != null && true
            ? screenHeight * (0.50335)
            : screenHeight * (0.74375),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 43, 43, 43).withOpacity(0.90),
          borderRadius: BorderRadius.circular(34.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Container(
              margin: const EdgeInsets.only(bottom: 30),
              height: 25,
              child: Text(
                title,
                style: Styles.overlayTitle,
                textAlign: TextAlign.left,
              ),
            ),
            ...children
          ]),
        ));
  }
}
