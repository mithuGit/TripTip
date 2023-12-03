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
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: SlideAction(
          borderRadius: 40,
          elevation: 0,
          innerColor: const Color(0xFFD9D9D9),
          outerColor: Colors.white,
          textColor: Colors.black,
          sliderButtonIcon: const Icon(Icons.double_arrow_outlined),
          text: buttonText, // Use the provided buttonText property
          textStyle: Styles.title,
          // Icon dreht sich wenn true
          sliderRotate: true,
          onSubmit: () {
            return null;
          
            // do something
          },
        ),
      ),
    );
  }
}
