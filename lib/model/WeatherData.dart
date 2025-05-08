class WeatherData {
  final String name;
  final double temp;
  final String currently;
  final String description;
  final int humidity;
  final double windSpeed;
  final int pressure;
  final DateTime dateTime;
  final DateTime sunrise;
  final DateTime sunset;

  WeatherData({
    required this.name,
    required this.temp,
    required this.currently,
    required this.description,
    required this.humidity,
    required this.windSpeed,
    required this.pressure,
    required this.dateTime,
    required this.sunrise,
    required this.sunset,
  });

  factory WeatherData.currentWeather(Map<String, dynamic> json, String name) {
    return WeatherData(
      name: name,
      temp: double.parse(json['main']['temp'].toString()),
      currently: json['weather'][0]['main'],
      description: json['weather'][0]['description'],
      humidity: json['main']['humidity'],
      windSpeed: double.parse(json['wind']['speed'].toString()),
      pressure: json['main']['pressure'],
      dateTime: DateTime.fromMillisecondsSinceEpoch((json['dt'] ?? 0) * 1000),
      sunrise: DateTime.fromMillisecondsSinceEpoch(json['sys']['sunrise'] * 1000),
      sunset: DateTime.fromMillisecondsSinceEpoch(json['sys']['sunset'] * 1000),
    );
  }

  factory WeatherData.fromHourlyJson(Map<String, dynamic> json, String name) {
    return WeatherData(
      name: name,
      temp: double.parse(json['main']['temp'].toString()),
      currently: json['weather'][0]['main'],
      description: json['weather'][0]['description'],
      humidity: json['main']['humidity'],
      windSpeed: double.parse(json['wind']['speed'].toString()),
      pressure: json['main']['pressure'],
      dateTime: DateTime.parse(json['dt_txt']),
      sunrise: DateTime.parse(json['dt_txt']),
      sunset: DateTime.parse(json['dt_txt']),
    );
  }
}
