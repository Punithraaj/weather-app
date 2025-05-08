import 'package:flutter/material.dart';
import 'package:weather_icons/weather_icons.dart';

IconData getWeatherIcon(String condition) {
  switch (condition.toLowerCase()) {
    case 'clear':
      return WeatherIcons.day_sunny;
    case 'clouds':
      return WeatherIcons.cloudy;
    case 'rain':
      return WeatherIcons.rain;
    case 'snow':
      return WeatherIcons.snow;
    case 'thunderstorm':
      return WeatherIcons.thunderstorm;
    case 'drizzle':
      return WeatherIcons.sprinkle;
    case 'mist':
    case 'fog':
    case 'haze':
      return WeatherIcons.fog;
    default:
      return WeatherIcons.na;
  }
}
