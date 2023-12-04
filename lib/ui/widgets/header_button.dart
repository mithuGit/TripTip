import 'package:flutter/material.dart';

class HeaderButton extends StatelessWidget {
  final Function()? onTap;
  final String? temperature;
  final String? weatherImage;

  const HeaderButton(
      {super.key, required this.onTap, this.temperature, this.weatherImage});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox.fromSize(
          size: const Size(50, 50), // button width and height
          child: ClipRRect(
            child: Material(
              color: Colors.transparent, // button color
              child: InkWell(
                // splash color
                onTap: onTap, // button pressed
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    if (temperature != null && weatherImage != null) ...[
                      Image.asset(
                        weatherImage!,
                        width: 30,
                        height: 30,
                      ),
                      Text(temperature!, style: const TextStyle(fontSize: 13)),
                    ] else ...[
                      const Icon(
                        Icons.add,
                        size: 45,
                        )
                    ],
                  ],
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
