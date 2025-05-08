import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../model/WeatherData.dart';

class WeatherApiService {
  static const BASE_URL = 'https://api.openweathermap.org/data/2.5';
  static const APP_ID = '9ac188b5ac1171ffacbb782749e4bca2';

  static Future<WeatherData> getCurrentWeather(Position pos, String city) async {
    final url = Uri.parse('$BASE_URL/weather?lat=${pos.latitude}&lon=${pos.longitude}&units=metric&appid=$APP_ID');
    final response = await http.get(url);
    return WeatherData.currentWeather(jsonDecode(response.body), city);
  }

  static Future<List<WeatherData>> getForecast(Position pos, String city) async {
    final url = Uri.parse('$BASE_URL/forecast?lat=${pos.latitude}&lon=${pos.longitude}&units=metric&appid=$APP_ID');
    final response = await http.get(url);
    final data = jsonDecode(response.body);

    return (data['list'] as List)
        .map((e) => WeatherData.fromHourlyJson(e, city))
        .where((e) => e.dateTime.hour == 12) // Midday forecasts only
        .toList();
  }

  static Future<List<WeatherData>> getTodayHourlyForecast(Position pos, String city) async {
    final url = Uri.parse('$BASE_URL/forecast?lat=${pos.latitude}&lon=${pos.longitude}&units=metric&appid=$APP_ID');
    final response = await http.get(url);
    final data = jsonDecode(response.body);

    return (data['list'] as List)
        .map((e) => WeatherData.fromHourlyJson(e, city))
        .toList();
  }
}
