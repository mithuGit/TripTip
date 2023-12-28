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
        width: fill != null
            ? MediaQuery.of(context).size.width
            : MediaQuery.of(context).size.width * 0.5,
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 49, 48, 78),
        ),
        child: Column(children: [
          // Image (genauer gesagt ein GiF )
          Container(
              decoration: BoxDecoration(
                color: color,
                border: Border.all(color: Colors.black),
              ),
              width: fill != null
                  ? MediaQuery.of(context).size.width
                  : MediaQuery.of(context).size.width * 0.5,
              child: Image.asset(image, height: 170)),

          // Charakter Name
          Text(name, style: Styles.characterStyle),

          // Charakter Beschreibung
          Text(
            description,
            style: Styles.characterStyle,
          ),

          // Link von LinkedIn
          RichText(
            text: TextSpan(
              text: 'LinkedIn',
              style: const TextStyle(color: Colors.blue),
              recognizer: TapGestureRecognizer()
                ..onTap = () async {
                  launchUrl(Uri.parse(link));
                },
            ),
          )
        ]));
  }
}
