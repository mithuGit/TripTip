import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/views/weather/weather.dart';
import 'package:internet_praktikum/core/services/weather_service.dart';

import 'package:lottie/lottie.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  // api key for openweathermap
  final _weatherHandler = WeatherService("5a9d3eda46bcddc1662d351abc13c798");
  Weather? actualWeather;

  Future<void> fetchWeather() async {
    // is not the same as in weather_info.dart
    final weather = await _weatherHandler.fetchWeather();
    setState(() {
      actualWeather = weather;
    });
  }

  // init state
  @override
  void initState() {
    super.initState();
    // fetch the weather on startup
    fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          backgroundColor: Colors.black,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white, size: 30),
              onPressed: () {
                fetchWeather();
              },
            ),
          ]),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // city name
            Text(actualWeather?.cityName ?? "Loading city...",
                style: const TextStyle(fontSize: 30, color: Colors.white)),

            Lottie.asset(
              WeatherService.getWeatherAnimation(actualWeather?.mainCondition),
              //width: 200,
              //height: 200,
              //fit: BoxFit.fill,
            ),

            // temperature
            Text('${actualWeather?.temperature.round()}°C',
                style: const TextStyle(fontSize: 30, color: Colors.white)),

            // weather condition
            Text(actualWeather?.mainCondition ?? "Loading weather...",
                style: const TextStyle(fontSize: 30, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
