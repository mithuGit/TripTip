import 'package:flutter/material.dart';
import 'package:internet_praktikum/core/services/weather_service.dart';
import 'package:internet_praktikum/ui/views/weather/weather.dart';
import 'package:internet_praktikum/ui/views/weather/weather_page.dart';
import 'package:internet_praktikum/ui/widgets/header_button.dart';

class TopBar extends StatefulWidget implements PreferredSizeWidget {
  final bool? isDash;
  final IconData icon;
  final String? title;
  final Function()? onTapForIconWidget; 

  const TopBar({super.key, this.isDash, required this.icon, this.title, required this.onTapForIconWidget});

  @override
  State<TopBar> createState() => _TopBarState();

  @override
  Size get preferredSize => const Size.fromHeight(56); // hier kann man die Size der AppBar beeinflussen
}

class _TopBarState extends State<TopBar> {
  final WeatherService _weatherHandler =
      WeatherService("5a9d3eda46bcddc1662d351abc13c798");
  Weather? actualWeather;

  @override
  void initState() {
    super.initState();
    fetchWeather();
  }

  Future<void> fetchWeather() async {
    // is not the same as in weather_info.dart
    final weather = await _weatherHandler.fetchWeather();
    setState(() {
      actualWeather = weather;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: 
        widget.isDash! && widget.title == null 
        ? const Text(
          "Frankfurt am Main", // TODO: Hier muss der Name der Stadt stehen, die der User ausgewählt hat
          style: TextStyle(fontSize: 20),
        ) : Text(
          widget.title!,
          style: const TextStyle(fontSize: 20),
        ),
        leadingWidth: widget.isDash! ? 66 : 0, // defaul 56 + 10
        leading: widget.isDash! ? HeaderButton(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WeatherPage()),
            );
          },
          temperature: '${WeatherService.actualWeather?.temperature.round()}°C',
          weatherImage: WeatherService.getWeatherIcon(WeatherService.actualWeather?.mainCondition),
        ) : null,
        actions: [
          HeaderButton(
            onTap: widget.onTapForIconWidget,
            icon: widget.icon,
          ),
          const SizedBox(width: 10)
        ]);
  }
}
