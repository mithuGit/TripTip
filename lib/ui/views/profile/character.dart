import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';

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
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          children: [
            // Image (genauer gesagt ein GiF )
            Image.asset(image, width: 200, height: 190), //lieber mit Padding arbeiten statt mit manuellen zahlen
        
            // Charakter Name
            Text(name, style: Styles.characterStyle),
        
            // Charakter Beschreibung
            Text(description, style: Styles.characterStyle),
        
            // Link von LinkedIn
            Text(link, style: Styles.characterStyle),
          ],
        ));
  }
}
