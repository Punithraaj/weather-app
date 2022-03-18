import 'package:weatherapp/model/WeatherData.dart';

class WeatherReport {
  final WeatherData currentWeather;
  final List<WeatherData> weatherForecast;
  final List<WeatherData> hourlyWeatherForecast;

  WeatherReport(
      this.currentWeather, this.weatherForecast, this.hourlyWeatherForecast);
}
