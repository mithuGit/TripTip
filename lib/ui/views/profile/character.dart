import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';
import 'package:url_launcher/url_launcher.dart';

class CharakterContainer extends StatelessWidget {
  final String name;
  final String description;
  final String link;
  final String image;
  final Color? color;
  final bool? fill;

  const CharakterContainer(
      {super.key,
      required this.name,
      required this.description,
      required this.link,
      required this.image,
      this.color,
      this.fill});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: fill != null ? MediaQuery.of(context).size.width : MediaQuery.of(context).size.width * 0.5,
        decoration: BoxDecoration(
          color: color,
        ),
        child: Column(children: [
          // Image (genauer gesagt ein GiF )
          Image.asset(image, height: 170),

          // Charakter Name
          Text(name, style: Styles.characterStyle),

          // Charakter Beschreibung
          Text(description, style: Styles.characterStyle),

          // Link von LinkedIn
          RichText(
            text: TextSpan(
              text: 'LinkedIn',
              style: const TextStyle(color: Colors.black),
              recognizer: TapGestureRecognizer()
                ..onTap = () async {
                  launchUrl(Uri.parse(link));
                },
            ),
          )
        ]));
  }
}
