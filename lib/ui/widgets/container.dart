
import 'package:flutter/material.dart';

class CustomContainer extends StatelessWidget {
  final String title;
  final double fontSize;
  final Color? color;

  const CustomContainer({super.key, required this.title, required this.fontSize, this.color});

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double screenHeight = screenSize.height;
    double screenWidth = screenSize.width;
    return Container(
      width: screenWidth * (0.925),
      height: screenHeight * (0.74375),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.58),
        borderRadius: BorderRadius.circular(38.5),
      ),
      child: Column(
        children: [
          SizedBox(
            height: (screenHeight * (0.74375)) * 0.036974,
          ),
          Center(
            child: SizedBox(
              width: (screenWidth * (0.925)) * 0.873,
              height: (screenHeight * (0.74375)) * 0.0773,
              child: TextField(
                decoration: InputDecoration(
                  hintText: title,
                  hintStyle: TextStyle(
                    color: color ?? Colors.white,
                    fontSize: fontSize,
                  ),
                  border: InputBorder.none,
                  filled: true,
                  fillColor: Colors.transparent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
