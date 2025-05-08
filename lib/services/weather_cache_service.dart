import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class WeatherCacheService {
  static const String _weatherKey = 'cachedWeatherData';

  // Caching the weather data
  Future<void> cacheWeatherData(Map<String, dynamic> weatherData) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_weatherKey, json.encode(weatherData));
  }

  // Fetching the cached weather data
  Future<Map<String, dynamic>?> getCachedWeatherData() async {
    final prefs = await SharedPreferences.getInstance();
    final weatherData = prefs.getString(_weatherKey);
    if (weatherData != null) {
      return json.decode(weatherData);
    }
    return null;
  }
}
