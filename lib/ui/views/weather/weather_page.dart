import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internet_praktikum/core/services/weather_service.dart';
import 'package:internet_praktikum/ui/views/weather/weather.dart';
import 'package:internet_praktikum/ui/widgets/my_button.dart';

import 'package:lottie/lottie.dart';

// ignore: must_be_immutable
class WeatherPage extends StatefulWidget {
  Weather actualWeather;
  final WeatherService _weatherHandler =
      WeatherService("5a9d3eda46bcddc1662d351abc13c798");

  WeatherPage({
    super.key,
    required this.actualWeather,
  });

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  //TODO Maybe getCity in WeatherService löschen

  bool isDarkMode = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back,
                color: isDarkMode ? Colors.white : Colors.black, size: 30),
            onPressed: () {
              context.goNamed('home');
            },
          ),
          backgroundColor: isDarkMode ? Colors.black : Colors.white,
          actions: [
            IconButton(
              icon: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: isDarkMode ? Colors.white : Colors.black, size: 30),
              onPressed: () {
                setState(() {
                  isDarkMode = !isDarkMode;
                });
              },
            ),
          ]),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // city name
            Text(widget.actualWeather.cityName,
                style: TextStyle(
                    fontSize: 30,
                    color: isDarkMode ? Colors.white : Colors.black)),

            Lottie.asset(
              WeatherService.getWeatherAnimation(
                  widget.actualWeather.mainCondition),
            ),

            // temperature
            Text('${widget.actualWeather.temperature.round()}°C',
                style: TextStyle(
                    fontSize: 30,
                    color: isDarkMode ? Colors.white : Colors.black)),

            // weather condition
            Text(widget.actualWeather.mainCondition,
                style: TextStyle(
                    fontSize: 30,
                    color: isDarkMode ? Colors.white : Colors.black)),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.only(left: 40.0, right: 40.0, top: 20),
              child: MyButton(
                  borderColor: isDarkMode ? Colors.white : Colors.black,
                  textStyle: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: 14,
                    fontFamily: 'Ubuntu',
                    fontWeight: FontWeight.w500,
                  ),
                  colors: isDarkMode ? Colors.black : Colors.white,
                  onTap: () async {
                    final weather = await widget._weatherHandler.fetchWeather();
                    setState(() {
                      widget.actualWeather = weather!;
                    });
                  },
                  text: "Get Weather for your Trip Location"),
            ),

            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 40.0, right: 40.0, top: 20),
              child: MyButton(
                  borderColor: isDarkMode ? Colors.white : Colors.black,
                  textStyle: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: 14,
                    fontFamily: 'Ubuntu',
                    fontWeight: FontWeight.w500,
                  ),
                  colors: isDarkMode ? Colors.black : Colors.white,
                  onTap: () async {
                    final weather = await widget._weatherHandler
                        .fetchWeatherForCurrentCity();
                    setState(() {
                      widget.actualWeather = weather;
                    });
                  },
                  text: "Get Weather for your Actual Location"),
            ),
          ],
        ),
      ),
    );
  }
}
