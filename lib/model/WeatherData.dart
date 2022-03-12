import 'dart:convert';

class WeatherData {
  final String temp;
  final String name;
  final String description;
  final String currently;
  final String humidity;
  final String windSpeed;

  WeatherData(this.temp, this.name, this.description, this.currently,
      this.humidity, this.windSpeed);

  WeatherData.fromJson(Map<String, dynamic> json)
      : temp = json['main']['temp'].toString(),
        name = json["name"].toString(),
        description = json['weather'][0]['description'] == null
            ? ""
            : json['weather'][0]['description'],
        currently = json['weather'][0]['main'],
        humidity = json['main']['humidity'] == null
            ? ""
            : json['main']['humidity'].toString(),
        windSpeed = json['wind']['speed'].toString();

  @override
  String toString() {
    return 'WeatherData(temp: $temp, name: $name, description: $description, currently: $currently, humidity: $humidity, windSpeed: $windSpeed)';
  }
}
