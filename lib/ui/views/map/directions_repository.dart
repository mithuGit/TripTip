import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'directions.dart';

// IMPORTANT: Enter your Google Directions API Key here
const String googleDirectionsApiKey = 'YOUR_GOOGLE_DIRECTIONS_API_KEY_HERE';

class DirectionsRepository {
  static const String _baseUrl =
      'https://maps.googleapis.com/maps/api/directions/json';
  final Dio _dio = Dio();

  Future<Directions?> getDirections({
    required LatLng origin,
    required LatLng destination,
  }) async {
    if (googleDirectionsApiKey == 'YOUR_GOOGLE_DIRECTIONS_API_KEY_HERE') {
      throw Exception(
          'Google Directions API Key not configured. Please insert a valid API key.');
    }

    final response = await _dio.get(_baseUrl, queryParameters: {
      'origin': '${origin.latitude},${origin.longitude}',
      'destination': '${destination.latitude},${destination.longitude}',
      'key': googleDirectionsApiKey,
    });

    if (response.statusCode == 200) {
      final data = response.data;

      if ((data['routes'] as List).isEmpty) {
        return null;
      }

      return Directions.fromMap(data);
    }
    return null;
  }
}
