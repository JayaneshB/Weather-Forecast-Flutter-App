// lib/services/weather_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:weather_app/secrets.dart';

class WeatherService {
  Future<Map<String, dynamic>> getWeatherData(String cityName) async {
    try {
      final result = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$openWeatherApiKey',
        ),
      );

      final data = jsonDecode(result.body);
      if (data['cod'] != '200') throw 'An unexpected error occurred';

      return data;
    } catch (e) {
      throw Exception(e);
    }
  }
}
