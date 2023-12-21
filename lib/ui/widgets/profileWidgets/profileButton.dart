import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';

class ProfileButton extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Function()? onTap;
  final Color? textcolor;

  const ProfileButton({
    super.key,
    required this.title,
    this.icon,
    this.onTap,
    this.textcolor,
  });

  @override
  Widget build(BuildContext context) {
    final Shader linearGradient = const LinearGradient(
      colors: <Color>[Color(0xffDA44bb), Color(0xff8921aa)],
    ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

    return Container(
      margin: const EdgeInsets.only(top: 10, right: 30, left: 30, bottom: 10),
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: textcolor,
          padding: const EdgeInsets.all(16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
          side: const BorderSide(
            width: 1.5,
            color: Colors.black,
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
                textcolor == Colors.black
                    ? Text(title, style: Styles.buttonStyle)
                    : textcolor == Colors.purpleAccent ? 
                    Text(
                        title,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            foreground: Paint()..shader = linearGradient),
                      ): Text(title, style: Styles.buttonStyleRed)
              ],
            ),
          ],
        ),
      ),
    );
  }
}
