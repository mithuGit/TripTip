// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';

// This is the button that is used in the modal bottom sheet
class ModalButton extends StatelessWidget {
  final Function()? onTap;
  final String? text;
  final IconData? icon;
  final Image? image;
  final EdgeInsets? padding;
  const ModalButton(
      {Key? key,
      required this.onTap,
      this.text,
      this.icon,
      this.image,
      this.padding})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xE51E1E1E),
          shadowColor: Colors.transparent,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          side: const BorderSide(
            width: 0,
            color: Colors.white,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 50),
              const SizedBox(height: 5)
            ],
            if (image != null) ...[image!, const SizedBox(height: 5)],
            Text(
              text!,
              style: Styles.buttonFontStyle,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
