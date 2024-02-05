import 'package:flutter/material.dart';

/*
  This class is the widget for the header buttons
  it is used in the header of the dashboard
  it is used to display the weather and the temperature
  and to navigate to the settings page
*/

class HeaderButton extends StatelessWidget {
  final Function()? onTap;
  final String? temperature;
  final String? weatherImage;
  final IconData? icon;

  const HeaderButton(
      {super.key, required this.onTap, this.temperature, this.weatherImage, this.icon});

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
                onTap: onTap,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    if (temperature != null && weatherImage != null) ...[
                      Image.asset(
                        weatherImage!,
                        width: 35,
                        height: 30,
                      ),
                      Text(temperature!, style: const TextStyle(fontSize: 14)),
                    ] else ...[
                      Icon(icon, size: 40)
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
