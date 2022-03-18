import 'dart:convert';

class WeatherData {
  final DateTime dateTime;
  final String temp;
  final String? name;
  final String description;
  final String currently;
  final String humidity;
  final String windSpeed;
  final String pressure;
  final String iconData;

  WeatherData(
      this.temp,
      this.name,
      this.description,
      this.currently,
      this.humidity,
      this.windSpeed,
      this.pressure,
      this.dateTime,
      this.iconData);

  WeatherData.forcast(Map<String, dynamic> json, String? locality)
      : dateTime =
            DateTime.fromMicrosecondsSinceEpoch(json['dt'] * 1000).toLocal(),
        temp = json['temp']["day"].toString(),
        name = locality,
        description = json['weather'][0]['description'] == null
            ? ""
            : json['weather'][0]['description'],
        currently = json['weather'][0]['main'],
        humidity = json['humidity'] == null ? "0" : json['humidity'].toString(),
        windSpeed = json['wind_speed'].toString(),
        pressure = json['pressure'] == null ? "0" : json['pressure'].toString(),
        iconData = json['weather'][0]['icon'];

  WeatherData.currentWeather(Map<String, dynamic> json, String? locality)
      : dateTime =
            DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000).toLocal(),
        temp = json['temp'].toString(),
        name = locality,
        description = json['weather'][0]['description'] == null
            ? ""
            : json['weather'][0]['description'],
        currently = json['weather'][0]['main'],
        humidity = json['humidity'] == null ? "" : json['humidity'].toString(),
        windSpeed = json['wind_speed'].toString(),
        pressure = json['pressure'].toString(),
        iconData = json['weather'][0]['icon'];

  @override
  String toString() {
    print("Now:" + DateTime.now().toUtc().millisecondsSinceEpoch.toString());
    return 'WeatherData(temp: $temp, name: $name, description: $description, currently: $currently, humidity: $humidity, windSpeed: $windSpeed)';
  }
}
