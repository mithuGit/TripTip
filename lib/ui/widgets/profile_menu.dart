import 'package:flutter/material.dart';

class ProfileMenuWidget extends StatelessWidget {
  const ProfileMenuWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.onPress,
    required this.endIcon,
    required this.textColor, // hab mal noch textColor hinzugefügt wenn wir was ändern wollen z.B Bei Logout text rot
  });

  final String title;
  final IconData icon;
  final VoidCallback onPress;
  final bool endIcon;
  final bool textColor;

  @override
  Widget build(BuildContext context) {
    var isDark = MediaQuery.of(context).platformBrightness ==
        Brightness.dark; // check if dark mode is enabled

    var iconColor = isDark
        ? Colors.grey
        : Colors
            .black; // if dark mode is enabled, icon color is grey, else black

    return ListTile(
      onTap: onPress,
      leading: Container(
        // linke Icon im Button
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: Colors.grey[300], // genauere Farbe wählen
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: textColor
          ? Text(title,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.black,
              ) // maybefontWeight: FontWeight.normal
              )
          : Text(title,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.red,
              )),
      trailing: endIcon
          ? Container(
              // Falls endIcon true ist wird das noch hinzugefügt
              // rechte Icon im Button
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: Colors.grey[300], // genauere Farbe wählen
              ),
              child: const Icon(Icons.arrow_right, color: Colors.grey),
            )
          : null,
    );
  }
}
