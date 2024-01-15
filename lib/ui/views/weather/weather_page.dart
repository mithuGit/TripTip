import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internet_praktikum/core/services/weather_service.dart';
import 'package:internet_praktikum/ui/views/weather/weather.dart';

import 'package:lottie/lottie.dart';

class WeatherPage extends StatefulWidget {
  final Weather actualWeather;

  const WeatherPage({
    super.key,
    required this.actualWeather,
  });

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
            onPressed: () {
              context.goNamed('home');
            },
          ),
          backgroundColor: Colors.black,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white, size: 30),
              onPressed: () {
                //fetchWeather();
              },
            ),
          ]),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // city name
            Text(widget.actualWeather.cityName,
                style: const TextStyle(fontSize: 30, color: Colors.white)),

            Lottie.asset(
              WeatherService.getWeatherAnimation(
                  widget.actualWeather.mainCondition),
            ),

            // temperature
            Text('${widget.actualWeather.temperature.round()}°C',
                style: const TextStyle(fontSize: 30, color: Colors.white)),

            // weather condition
            Text(widget.actualWeather.mainCondition,
                style: const TextStyle(fontSize: 30, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
