import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';

class MapButton extends StatelessWidget {
  final Function()? onTap;
  final Function()? makeSmaller;
  final Function()? makeBigger;
  final Function()? onClose;
  final String text;
  final Color? colors;
  final Color? borderColor;
  final bool? isExpandedButton;
  const MapButton(
      {super.key,
      this.onTap,
      required this.text,
      this.colors,
      this.borderColor,
      this.isExpandedButton,
      this.makeSmaller,
      this.onClose,
      this.makeBigger});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isExpandedButton != null && isExpandedButton == true) {
          onClose!();
        } else if (isExpandedButton != null && isExpandedButton == false) {
          makeBigger!();
        }
      },
      child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          width: (isExpandedButton != null && isExpandedButton == false)
              ? 80
              : 120,
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              backgroundColor: colors,
              foregroundColor: const Color.fromARGB(100, 255, 255, 255),
              padding: const EdgeInsets.all(8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11)),
              side: BorderSide(width: 1.5, color: borderColor ?? Colors.white),
            ),
            child: Row(
              mainAxisAlignment:
                  isExpandedButton != null && isExpandedButton == false
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  text,
                  style: Styles.smallButtonStyle,
                  overflow: TextOverflow.ellipsis,
                ),
                isExpandedButton != null && isExpandedButton == true
                    ? GestureDetector(
                        onTap: onTap,
                        child: const Icon(
                          Icons.location_city,
                          size: 18,
                          color: Colors.white,
                        ),
                      )
                    : const SizedBox(),
                isExpandedButton != null && isExpandedButton == true
                    ? GestureDetector(
                        onTap: onClose,
                        child: const Icon(
                          Icons.close,
                          size: 18,
                          color: Colors.red,
                        ),
                      )
                    : const SizedBox(),
                isExpandedButton != null && isExpandedButton == true
                    ? GestureDetector(
                        onTap: makeSmaller,
                        child: const Icon(
                          Icons.arrow_back_outlined,
                          size: 18,
                          color: Colors.white,
                        ),
                      )
                    : const SizedBox()
              ],
            ),
          )),
    );
  }
}
