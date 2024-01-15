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

  //TODO: oben rechts soll nicht die gleichen Buttons sein wie die unten sondern, lieber ein Dark-White Mode Button
  //TODO Maybe getCity in WeatherService löschen
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
              onPressed: () async {
                final weather = await widget._weatherHandler.fetchWeather();
                setState(() {
                  widget.actualWeather = weather!;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.directions, color: Colors.white, size: 30),
              onPressed: () async {
                final weather =
                    await widget._weatherHandler.fetchWeatherForCurrentCity();
                setState(() {
                  widget.actualWeather = weather;
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

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.only(left: 40.0, right: 40.0, top: 20),
              child: MyButton(
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
