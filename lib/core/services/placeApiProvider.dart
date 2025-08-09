import 'dart:convert';
import 'package:http/http.dart' as http;

class PlaceApiProvider {
  static const String _baseUrl = 'https://places.googleapis.com/v1';

  // WARNING: API Key must be inserted here
  static const String _apiKey = 'YOUR_GOOGLE_PLACES_API_KEY_HERE';

  final String sessionToken;

  PlaceApiProvider(this.sessionToken);

  Future<Iterable<Suggestion>> fetchSuggestions(String input) async {
    if (_apiKey == 'YOUR_GOOGLE_PLACES_API_KEY_HERE') {
      throw Exception(
          'Google Places API Key not configured. Please insert a valid API key.');
    }

    final request = {
      'input': input,
      'sessiontoken': sessionToken,
      'types': '(cities)',
      'components': 'country:de'
    };

    final response = await http.get(
      Uri.parse(
          '$_baseUrl/autocomplete/json?${_encodeParams(request)}&key=$_apiKey'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['predictions'] as List)
          .map((p) => Suggestion(p['place_id'], p['description']))
          .toList();
    } else {
      throw Exception('Error loading suggestions: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> fetchPlaceDetails(String placeId) async {
    if (_apiKey == 'YOUR_GOOGLE_PLACES_API_KEY_HERE') {
      throw Exception(
          'Google Places API Key not configured. Please insert a valid API key.');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/details/json?place_id=$placeId&key=$_apiKey'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['result'] as Map<String, dynamic>;
    } else {
      throw Exception('Error loading place details: ${response.statusCode}');
    }
  }

  String _encodeParams(Map<String, String> params) {
    return params.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }
}

class Suggestion {
  final String placeId;
  final String description;

  Suggestion(this.placeId, this.description);

  @override
  String toString() {
    return description;
  }
}

class PlaceDetails {
  final String id;
  final String name;
  final Map<String, dynamic> details;

  PlaceDetails(this.id, this.name, this.details);

  // Getters for compatibility with existing code
  String get cityName => name;
  Map<String, dynamic> get placeDetails => details;
}
