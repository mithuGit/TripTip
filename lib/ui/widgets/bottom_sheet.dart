import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';

class CustomBottomSheet {
  static Future<void> show(BuildContext context,
      {required String title, required List<Widget> content}) {
    return showModalBottomSheet(
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
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.7,
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
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Image.asset(
                              'assets/moveModalDown.png',
                              width: 80,
                              height: 10,),
                          )
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        title,
                        style: Styles
                            .title, // Hier wird die title-Methode aus der Styles-Klasse verwendet
                      ),
                      const SizedBox(height: 8.0),
                      ...content,
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
