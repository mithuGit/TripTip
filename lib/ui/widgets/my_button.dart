import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';

class MyButton extends StatelessWidget {
  final Function()? onTap;
  final String text;
  final IconData? iconData;
  final String? imagePath;
  final Color? colors;

  const MyButton({
    Key? key,
    required this.onTap,
    required this.text,
    this.iconData,
    this.imagePath,
    this.colors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(top: 8, bottom: 8, left: 12, right: 12),
        decoration: BoxDecoration(
          color: colors ?? Colors.transparent,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: Colors.white),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (iconData != null)
              Icon(
                iconData!, // nicht sicher ob hier ein ! kommt
              ),
            if (imagePath != null)
              Image.asset(
                imagePath!, // nicht sicher ob hier ein ! kommt
                height: 30,
              ),
            if (imagePath != null || iconData != null)
              const SizedBox(width: 20),
            Expanded(
              child: iconData != null || imagePath != null
                  ? Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        text,
                        style: Styles.buttonFontStyle,
                      ),
                    )
                  : Align(
                      alignment: Alignment.center,
                      child: Text(
                        text,
                        style: Styles.buttonFontStyle
                      ),
                    ),
            )
          ],
        ),
      ),
    );
  }
}
