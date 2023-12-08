import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';
import 'package:slide_to_act/slide_to_act.dart';

class SlideButton extends StatelessWidget {
  final String buttonText;
  final EdgeInsets? margin;

  // Constructor to receive the text when creating an instance
  const SlideButton({Key? key, required this.buttonText, this.margin})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: SlideAction(
        borderRadius: 40, // Adjust the border radius as needed
        elevation: 0,
        innerColor: const Color(0xFFD9D9D9),
        outerColor: Colors.white,
        textColor: Colors.black,
        sliderButtonIcon: Transform.scale(
          scale: 2.33, // Adjust the scale factor as needed
          child: const Icon(
            Icons.arrow_forward,
            size: 12,
          ),
        ),
        text: buttonText, // Use the provided buttonText property
        textStyle: Styles.title,
        // Icon dreht sich wenn true
        sliderRotate: true,
        height: 50,
        onSubmit: () {
          return Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Payment()),
          );
        },
      ),
    );
  }
}
