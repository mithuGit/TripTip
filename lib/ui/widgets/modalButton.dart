import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';

class ModalButton extends StatelessWidget {
  final Function()? onTap;
  final String? text;
  final IconData? icon;
  final Image? image;
  ModalButton({Key? key, required this.onTap, this.text, this.icon, this.image})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      width: double.infinity,
      height: 50,
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
              const SizedBox(height: 10)],
            if (image != null) ...[
              image!,
              const SizedBox(height: 10)],
            Text(text!, style: Styles.buttonFontStyle),
          ],
        ),
      ),
    );
  }
}
