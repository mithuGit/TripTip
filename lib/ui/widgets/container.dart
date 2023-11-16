import 'dart:ui';
import '../styles/Styles.dart';

import 'package:flutter/material.dart';

class CustomContainer extends StatelessWidget {
  final String title;
  final double fontSize;

  CustomContainer({required this.title, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double screenHeight = screenSize.height;
    double screenWidth = screenSize.width;
    return Container(
      width: screenWidth * (0.925),
      height: screenHeight * (0.74375),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.90),
        borderRadius: BorderRadius.circular(34.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
        children: [
          FittedBox(
              alignment: Alignment.topLeft,
              child: Text(
                  title,
                  style: Styles.overlayTitle,
                  textAlign: TextAlign.left,
                ),
          ),
        ]
      ),
      )
    );
  }
}
