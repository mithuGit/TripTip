import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final Function()? onTap;
  final String text;
  final IconData? iconData;
  final String? imagePath;

  const MyButton({
    Key? key,
    required this.onTap,
    required this.text,
    this.iconData,
    this.imagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: Colors.white),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (iconData != null)
              Icon(
                iconData!, // nicht sicher ob hier ein ! kommt
              ),
            if (imagePath != null)
              Image.asset(
                imagePath!, // nicht sicher ob hier ein ! kommt
                height: 24,
              ),
            if (imagePath != null || iconData != null)
              const SizedBox(width: 20),
            Expanded(
              child: iconData != null || imagePath != null
                  ? Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    )
                  : Align(
                      alignment: Alignment.center,
                      child: Text(
                        text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
            )
          ],
        ),
      ),
    );
  }
}
