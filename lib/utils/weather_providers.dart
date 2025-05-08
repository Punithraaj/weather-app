import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:weatherapp/utils/WeatherApiService.dart';
import '../model/WeatherReport.dart';

final weatherReportProvider = FutureProvider<WeatherReport>((ref) async {
  final permission = await Geolocator.requestPermission();
  if (permission == LocationPermission.denied) {
    throw Exception("Location permission denied");
  }

  final pos = await Geolocator.getCurrentPosition();
  final placemark = await placemarkFromCoordinates(pos.latitude, pos.longitude);
  final city = placemark.first.subLocality ?? "Unknown";

  final current = await WeatherApiService.getCurrentWeather(pos, city);
  final forecast = await WeatherApiService.getForecast(pos, city);
  final hourly = await WeatherApiService.getTodayHourlyForecast(pos, city);

  return WeatherReport(current, forecast, hourly);
});
