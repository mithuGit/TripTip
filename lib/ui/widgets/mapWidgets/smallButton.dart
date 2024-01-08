import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';

class MySmallButton extends StatelessWidget {
  final Function()? onTap;
  final String? text;
  final IconData? iconData;
  final Color? colors;
  final Color? borderColor;
  const MySmallButton(
      {super.key,
      this.onTap,
      this.text,
      this.iconData,
      this.colors,
      this.borderColor});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 60 + (text != null ? 8 : 0) - (iconData != null ? 18 : 0),
        child: OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            backgroundColor: colors,
            foregroundColor: const Color.fromARGB(100, 255, 255, 255),
            padding: const EdgeInsets.all(8),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
            side: BorderSide(width: 1.5, color: borderColor ?? Colors.white),
          ),
          child: Row(
            mainAxisAlignment: (iconData == null)
                ? MainAxisAlignment.center
                : (iconData != null && text == null)
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
            children: [
              if (iconData != null) ...[
                Icon(
                  iconData,
                  size: 18,
                  color: borderColor ?? Colors.white,
                ),
                if (text != null) ...[
                  const SizedBox(
                    width: 8,
                  )
                ],
              ],
              if (text != null) ...[
                Text(
                  text!,
                  style: Styles.smallButtonStyle,
                ),
              ],
            ],
          ),
        ));
  }
}
