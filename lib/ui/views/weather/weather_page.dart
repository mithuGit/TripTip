import 'package:flutter/material.dart';
import 'package:internet_praktikum/main.dart';
import 'package:internet_praktikum/ui/views/weather/weather.dart';
import 'package:internet_praktikum/ui/views/weather/weather_service.dart';

import 'package:lottie/lottie.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  // api key for openweathermap
  final _weatherService = WeatherService("5a9d3eda46bcddc1662d351abc13c798");
  Weather? actualWeather;

  // fetch weather
  fetchWeather() async {
    // get the current city
    String cityName = await _weatherService.getCurrentCity();

    // get the weather for the current city
    try {
      final weather = await _weatherService.getWeather(cityName);
      setState(() {
        actualWeather = weather;
      });
    } catch (e) {
      print(e);
    }
  }

  String getWeatherAnimation (String? mainCondition){

    if (mainCondition == null) return 'assets/weather_pic/sunny.json';

    switch (mainCondition.toLowerCase()){
      case 'clouds':
        return 'assets/weather_pic/cloudy.json';
      case 'rain':
        return 'assets/weather_pic/rainy.json';
      case 'snow':
        return 'assets/weather_pic/snowy.json';
      case 'clear':
        return 'assets/weather_pic/sunny.json'; // oder day_clear.json
      case 'mist':
        return 'assets/weather_pic/mist.json';
      case 'haze':
        return 'assets/weather_pic/mist.json';
      case 'fog':
        return 'assets/weather_pic/mist.json';
      case 'drizzle':
        return 'assets/weather_pic/rainy_day.json'; // oder day_storm_showers.json
      case 'thunderstorm':
        return 'assets/weather_pic/storm.json';
      default:
        return 'assets/weather_pic/sunny.json';
    }

  }

  // weather animation

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
      backgroundColor: Colors.grey[800],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // city name
            Text(actualWeather?.cityName ?? "Loading city...", style: const TextStyle(fontSize: 30, color: Colors.white)),

            Lottie.asset(
              getWeatherAnimation(actualWeather?.mainCondition),
              //width: 200,
              //height: 200,
              //fit: BoxFit.fill,
            ),

            // temperature
            Text('${actualWeather?.temperature.round()}°C', style: const TextStyle(fontSize: 30, color: Colors.white)),

            // weather condition
            Text(actualWeather?.mainCondition ?? "Loading weather...", style: const TextStyle(fontSize: 30, color: Colors.white)),
        
          ],
        ),
      ),
    );
  }
}
