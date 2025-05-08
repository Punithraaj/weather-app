import 'package:weatherapp/model/WeatherData.dart';

class WeatherReport {
  final WeatherData currentWeather;
  final List<WeatherData> forecast;
  final List<WeatherData> hourly;

  WeatherReport(this.currentWeather, this.forecast, this.hourly);
}
