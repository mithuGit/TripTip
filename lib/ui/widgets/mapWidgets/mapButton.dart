// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';

// This class is used to display origin, destination and current location on the map

class MapButton extends StatelessWidget {
  final Function()? onTap;
  final Function()? makeSmaller;
  final Function()? makeBigger;
  final Function()? onClose;
  final IconData? icon;
  final String text;
  final Color colors;
  final bool isExpandedButton;
  const MapButton(
      {super.key,
      this.onTap,
      required this.text,
      required this.colors,
      required this.isExpandedButton,
      this.makeSmaller,
      this.onClose,
      this.makeBigger,
      this.icon});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        height: 50,
        width: (isExpandedButton == false) ? 80 : 140,
        decoration: BoxDecoration(
          gradient: colors == Colors.green
              ? const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 68, 218, 68),
                    Color.fromARGB(255, 14, 120, 12)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : colors == Colors.red
                  ? const LinearGradient(
                      colors: [
                        Color.fromRGBO(222, 96, 96, 1),
                        Color.fromRGBO(230, 33, 12, 1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : colors == Colors.blue
                      ? const LinearGradient(
                          colors: [
                            Color.fromRGBO(95, 209, 249, 1.0),
                            Color.fromRGBO(85, 125, 218, 1),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        )
                      : null,
          borderRadius: const BorderRadius.only(
              topRight: Radius.circular(34.5),
              bottomRight: Radius.circular(34.5)),
        ),
        child: Center(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipRect(
            child: Wrap(
              children: [
                if (isExpandedButton == false) ...[
                  GestureDetector(
                    onTap: makeBigger,
                    child: Icon(
                      icon ?? Icons.arrow_forward_outlined,
                      size: 25,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  )
                ] else ...[
                  SizedBox(
                    width: 80,
                    child: GestureDetector(
                      onTap: onTap,
                      child: Text(
                        text,
                        textAlign: TextAlign.left,
                        style: Styles.mapButtonStyle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: onClose,
                    child: Icon(
                      Icons.close,
                      size: 20,
                      color: colors == Colors.red ? Colors.white : Colors.red,
                    ),
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  GestureDetector(
                    onTap: makeSmaller,
                    child: const Icon(
                      Icons.arrow_back_outlined,
                      size: 20,
                      color: Colors.white,
                    ),
                  )
                ],
              ],
            ),
          ),
        )));
  }
}
