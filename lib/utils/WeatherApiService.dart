import 'dart:convert';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:weatherapp/model/WeatherData.dart';
import 'package:weatherapp/model/WeatherReport.dart';

class WeatherApiService {
  static final String BASE_URL = 'http://api.openweathermap.org/data/2.5/';
  static final String APP_ID = '9ac188b5ac1171ffacbb782749e4bca2';

  static Future<List<WeatherData>> getWeather() async {
    await Geolocator.checkPermission();
    await Geolocator.requestPermission();
    Position? position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    List<WeatherData> weatherDataList = [];
    var lattitude = await position.latitude;
    var longitude = await position.longitude;
    List<Placemark> placemarks =
        await placemarkFromCoordinates(lattitude, longitude);

    final url = Uri.parse(
        BASE_URL + 'onecall?lat=${lattitude}&lon=${longitude}&appid=${APP_ID}');
    print(url);
    var response = await http.get(url);
    print("Weather Response" + response.body);

    WeatherData weatherData = WeatherData.currentWeather(
        jsonDecode(response.body)['current'], placemarks.first.locality);
    weatherDataList.add(weatherData);
    print(weatherData);

    print("Weather data" + weatherDataList.first.toString());
    return weatherDataList;
  }

  static Future<WeatherReport> getWeatherReport() async {
    try {
      await Geolocator.checkPermission();
      await Geolocator.requestPermission();
      Position? position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      List<WeatherData> weatherForecast = [];
      List<WeatherData> hourlyWeatherForecast = [];
      var lattitude = await position.latitude;
      var longitude = await position.longitude;
      List<Placemark> placemarks = await placemarkFromCoordinates(
          lattitude, longitude,
          localeIdentifier: "en");

      final url = Uri.parse(BASE_URL +
          'onecall?lat=${lattitude}&lon=${longitude}&units=metric&appid=${APP_ID}');
      print(url);
      var response = await http.get(url);
      print(response.body);

      //current Weather Data
      WeatherData currentWeatherData = WeatherData.currentWeather(
          jsonDecode(response.body)['current'], placemarks.first.locality);

      //Weather Forecast for Next 7 days
      var list = jsonDecode(response.body)['daily']
              .map((e) => e)
              ?.toList(growable: true) ??
          [];
      list.forEach((e) {
        WeatherData weatherData =
            WeatherData.forcast(e, placemarks.first.locality);
        weatherForecast.add(weatherData);
        print(weatherData);
      });

      //Weather Forecast for Next 7 days
      var hourlyList = jsonDecode(response.body)['hourly']
              .map((e) => e)
              ?.toList(growable: true) ??
          [];
      hourlyList.forEach((e) {
        WeatherData hourlyWeatherData =
            WeatherData.currentWeather(e, placemarks.first.locality);
        weatherForecast.add(hourlyWeatherData);
        print(hourlyWeatherData);
      });

      WeatherReport weatherReport = WeatherReport(
          currentWeatherData, weatherForecast, hourlyWeatherForecast);
      print("Weather forcast" + weatherForecast.toString());
      return weatherReport;
    } catch (e) {
      print("Exception " + e.toString());
      throw e;
    }
  }
}
