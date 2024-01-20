// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';

class ProfileButton extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Function()? onTap;
  final Color? textcolor;
  final Color? backgroundColor;

  const ProfileButton({
    super.key,
    required this.title,
    this.icon,
    this.onTap,
    this.textcolor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final Shader linearGradient = const LinearGradient(
      colors: <Color>[Color(0xffDA44bb), Color(0xff8921aa)],
    ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 10),
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor ??
              const Color.fromARGB(255, 43, 43, 43).withOpacity(0.90),
          foregroundColor: textcolor,
          padding: const EdgeInsets.all(16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
          side: const BorderSide(
            width: 1.5,
            color: Colors.white,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon),
                const SizedBox(width: 20),
                textcolor == Colors.white
                    ? Text(title, style: Styles.buttonStyle)
                    : textcolor == Colors.purpleAccent
                        ? Text(
                            title,
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                foreground: Paint()..shader = linearGradient),
                          )
                        : textcolor == Colors.red
                            ? Text(title, style: Styles.buttonStyleRed)
                            : Text(title,
                                style: TextStyle(
                                    fontFamily: 'fonts/Ubuntu-Regular.ttf',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                    color: textcolor)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
