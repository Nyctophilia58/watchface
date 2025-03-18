import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

Future<Map<String, dynamic>> getWeatherData(String timezone, String apiKey) async {
  try {
    final location = timezone.split('/')[1]; // Extract city from timezone
    final url = Uri.parse('http://api.openweathermap.org/data/2.5/weather?q=$location&appid=$apiKey&units=metric');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final temp = data['main']['temp'];
      IconData weatherIcon;

      if (temp < 10) {
        weatherIcon = Icons.ac_unit;
      } else if (temp >= 10 && temp < 25) {
        weatherIcon = Icons.wb_cloudy;
      } else if (temp >= 25 && temp < 35) {
        weatherIcon = Icons.wb_sunny;
      } else {
        weatherIcon = Icons.local_fire_department;
      }

      return {'temperature': '${temp.toStringAsFixed(0)}°C', 'weatherIcon': weatherIcon};
    } else {
      throw Exception('Failed to fetch weather data');
    }
  } catch (e) {
    print('Error fetching weather data: $e');
    return {'temperature': '...', 'weatherIcon': Icons.error};
  }
}
