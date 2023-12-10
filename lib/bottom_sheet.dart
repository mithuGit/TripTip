import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';

class CustomBottomSheet {
  static void show(BuildContext context) {
    showModalBottomSheet(
      useRootNavigator: true,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      builder: (BuildContext context) {
        return _buildBottomSheetContent(context);
      },
    );
  }

  static Widget _buildBottomSheetContent(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 5,
                    color: Colors.transparent, // Transparent statt Grau
                  ),
                ],
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 40.0, // Die Größe nach Bedarf anpassen
                    color: Colors.grey, // Die Farbe nach Bedarf anpassen
                  ),
                ],
              ),
              const Text(
                "TripTip TripTip TripTip TripTip",
                style: Styles.title, // Hier wird die title-Methode aus der Styles-Klasse verwendet
              ),
            ],
          ),
        ),
      ),
    );
  }
}
