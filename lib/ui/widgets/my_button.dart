import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';

class MyButton extends StatelessWidget {
  final Function()? onTap;
  final String text;
  final IconData? iconData;
  final String? imagePath;
  final Color? colors;
  final EdgeInsets? margin;
  final Color? borderColor;
  final TextStyle? textStyle;

  const MyButton(
      {Key? key,
      required this.onTap,
      required this.text,
      this.iconData,
      this.imagePath,
      this.colors,
      this.margin,
      this.borderColor,
      this.textStyle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: margin,
        child: OutlinedButton(
            onPressed: onTap,
            style: OutlinedButton.styleFrom(
              backgroundColor: colors,
              foregroundColor: const Color.fromARGB(100, 255, 255, 255),
              padding: (iconData == null && imagePath == null)
                  ? const EdgeInsets.all(16)
                  : const EdgeInsets.only(
                      top: 8, bottom: 8, left: 12, right: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11)),
              side: BorderSide(
                width: 1.5,
                color: borderColor ?? Colors.white
              ),
            ),
            child: Row(
                mainAxisAlignment: (iconData == null && imagePath == null)
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                children: [
                  if ((iconData != null || imagePath != null)) ...[
                    if (imagePath != null) ...[
                      if(imagePath!.startsWith("http") == true) ...[
                        Image.network(
                        imagePath!,
                        width: 30,
                        height: 30,
                      )
                       ] else ...[
                        Image.asset(
                          imagePath!,
                          width: 30,
                          height: 30,
                        )
                      ]
                    ] else ...[
                      Icon(iconData)
                    ],
                    const SizedBox(width: 20),
                  ],
                  Text(
                    text,
                    style: textStyle ?? Styles.buttonFontStyle,
                  )
                ])));
  }
}
