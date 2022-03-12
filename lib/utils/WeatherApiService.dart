import 'dart:convert';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:weatherapp/model/WeatherData.dart';

class WeatherApiService {
  static final String BASE_URL = 'http://api.openweathermap.org/data/2.5/';
  static final String APP_ID = 'd555540a6862ed4f7eb41e5198edd8b9';

  static Future<WeatherData> getWeather() async {
    await Geolocator.checkPermission();
    await Geolocator.requestPermission();
    Position? position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    var lattitude = await position.latitude;
    var longitude = await position.longitude;
    List<Placemark> placemarks =
        await placemarkFromCoordinates(lattitude, longitude);

    final url = Uri.parse(BASE_URL +
        'weather?q=${placemarks[0].locality}&lon=${longitude}&appid=${APP_ID}');
    print(url);
    var response = await http.get(url);
    print(response.body);
    WeatherData weatherData = WeatherData.fromJson(jsonDecode(response.body));
    print("Weather data" + weatherData.toString());
    return weatherData;
  }
}
