import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';

class ModalButton extends StatelessWidget {
  final Function()? onTap;
  final String? text;
  final IconData? iconData;
  final String? imagePath;
  ModalButton(
      {Key? key, required this.onTap, this.text, this.iconData, this.imagePath})
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
          padding: (iconData == null && imagePath == null)
              ? const EdgeInsets.all(16)
              : const EdgeInsets.only(top: 8, bottom: 8, left: 12, right: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          side: const BorderSide(
            width: 0,
            color: Colors.white,
          ),
        ),
        child: Text(text!, style: Styles.buttonFontStyle),
      ),
    );
  }
}
