import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:internet_praktikum/ui/views/weather/weather.dart';
import 'package:http/http.dart' as http;

// This is the WeatherService class that is used to get the weather data from the openweathermap api

class WeatherService {
  // ignore: constant_identifier_names
  static const BASE_URL = 'https://api.openweathermap.org/data/2.5/weather';
  final String apiKey;
  WeatherService(this.apiKey);

  static String cityName = "";
  static Weather? actualWeather;

  Future<Weather?> fetchWeather() async {
    try {
      final weather = await getWeatherData();
      actualWeather = weather;
      return weather;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return Future.error('Failed to load weather data');
    }
  }

  Future<Weather> fetchWeatherForCurrentCity() async {
    try {
      String cityName = await getCurrentCity();
      final weather = await getWeather(cityName);
      actualWeather = weather;
      return weather;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return Future.error('Failed to load weather data');
    }
  }

  static String getWeatherIcon(String? mainCondition) {
    if (mainCondition == null) return 'assets/weather_button_pic/day-sunny.png';

    switch (mainCondition.toLowerCase()) {
      case 'clouds':
        return 'assets/weather_button_pic/cloud.png';
      case 'rain':
        return 'assets/weather_button_pic/rain.png';
      case 'drizzle':
        return 'assets/weather_button_pic/rain.png';
      case 'snow':
        return 'assets/weather_button_pic/snow.png';
      case 'clear':
        return 'assets/weather_button_pic/day-sunny.png';
      case 'mist':
        return 'assets/weather_button_pic/fog.png';
      case 'haze':
        return 'assets/weather_button_pic/fog.png';
      case 'fog':
        return 'assets/weather_button_pic/fog.png';
      case 'thunderstorm':
        return 'assets/weather_button_pic/flash.png';
      default:
        return 'assets/weather_button_pic/day-sunny.png';
    }
  }

  static String getWeatherAnimation(String? mainCondition) {
    if (mainCondition == null) return 'assets/weather_pic/sunny.json';

    switch (mainCondition.toLowerCase()) {
      case 'clouds':
        return 'assets/weather_pic/cloudy.json';
      case 'rain':
        return 'assets/weather_pic/rainy_day.json';
      case 'snow':
        return 'assets/weather_pic/snow.json';
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

  Future<Weather> getWeather(String cityName) async {
    final url = '$BASE_URL?q=$cityName&appid=$apiKey&units=metric';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return Weather.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Future<String> getCurrentCity() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    // fetch the current location
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // convert the location into a list of placemark objects
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    // extract the city name from the first placemark object
    String? cityName = placemarks[0].locality;

    return cityName ?? "";
  }

  Future<String> getCity(double latitude, double longitude) async {
    try {
      const apiKey = 'YOUR_NEW_WEATHER_API_KEY_HERE';
      final url =
          'http://api.openweathermap.org/geo/1.0/reverse?lat=$latitude&lon=$longitude&limit=1&appid=$apiKey';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final cityName = data[0]['name'];
        return cityName;
      } else {
        throw Exception('Failed to get city name from coordinates');
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return ""; 
    }
  }

  Future<Weather> getWeatherData() async {
    final auth = FirebaseAuth.instance.currentUser;

    if (auth == null) {
      // Handle the case where the user is not authenticated
      return Future.error('User not authenticated');
    }

    final DocumentSnapshot<Map<String, dynamic>> userDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(auth.uid)
            .get();

    final String tripId = userDoc.data()!['selectedtrip'].toString();

    final DocumentSnapshot<Map<String, dynamic>> selectedTripDoc =
        await FirebaseFirestore.instance.collection('trips').doc(tripId).get();

    if (selectedTripDoc.exists == false) {
      // Handle the case where no trip is found for the user
      return Future.error('No trip found for the user');
    }

    final String lat = selectedTripDoc
        .data()!['placedetails']["location"]["latitude"]
        .toString();
    final String long = selectedTripDoc
        .data()!['placedetails']["location"]["longitude"]
        .toString();
    final String cityName =
        await getCity(double.parse(lat), double.parse(long));
    final Weather weather = await getWeather(cityName);
    actualWeather = weather;
    return weather;
  }
}
