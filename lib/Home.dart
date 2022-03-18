import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:weather_icons/weather_icons.dart';
import 'package:weatherapp/model/WeatherData.dart';
import 'package:weatherapp/model/WeatherReport.dart';
import 'package:weatherapp/utils/WeatherApiService.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  late Future<WeatherReport> weatherReport;
  late int count = 0;
  @override
  void initState() {
    super.initState();
    weatherReport = WeatherApiService.getWeatherReport();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WeatherReport>(
      future: weatherReport,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return RefreshIndicator(
              onRefresh: _pullRefresh,
              child: Scaffold(
                  body: ListView(
                      children: [Center(child: Text('cannot get weather'))])));
        } else if (snapshot.hasData) {
          return RefreshIndicator(
              onRefresh: _pullRefresh,
              child: getWeatherScreen(snapshot.data!.currentWeather));
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  getWeatherScreen(WeatherData data) {
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 35, 77, 38),
        body: Column(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height / 2,
              width: MediaQuery.of(context).size.width,
              color: Color.fromARGB(255, 35, 77, 38),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(bottom: 10.0),
                    child: Text(
                      "Currently in " + data.name.toString(),
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Today",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    DateFormat.MMMEd().format(data.dateTime),
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    data.temp != null ? data.temp + "\u00B0" : "Loading...",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 40.0,
                        fontWeight: FontWeight.w600),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Text(
                      data.currently != null
                          ? data.currently.toString()
                          : "Loading...",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(left: 10, right: 10),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(35),
                        topRight: Radius.circular(35))),
                child: ListView(
                  children: <Widget>[
                    ListTile(
                      leading: FaIcon(FontAwesomeIcons.thermometerHalf),
                      title: Text("Temperature"),
                      trailing: Text(data.temp != null
                          ? data.temp.toString() + "\u00B0c"
                          : "Loading..."),
                    ),
                    ListTile(
                      leading: FaIcon(FontAwesomeIcons.mapPin),
                      title: Text("City Name"),
                      trailing: Text(data.name != null
                          ? data.name.toString()
                          : "Loading..."),
                    ),
                    ListTile(
                      leading: FaIcon(WeatherIcons.cloud),
                      title: Text("Weather"),
                      trailing: Text(data.description != null
                          ? data.description.toString()
                          : "Loading..."),
                    ),
                    ListTile(
                      leading: FaIcon(WeatherIcons.humidity),
                      title: Text("Humidity"),
                      trailing: Text(data.humidity != null
                          ? data.humidity.toString() + " %"
                          : "Loading..."),
                    ),
                    ListTile(
                      leading: FaIcon(FontAwesomeIcons.wind),
                      title: Text("Wind Speed"),
                      trailing: Text(data.windSpeed != null
                          ? data.windSpeed.toString() + " m/s"
                          : "Loading..."),
                    ),
                    ListTile(
                      leading: FaIcon(WeatherIcons.thermometer),
                      title: Text("Pressure"),
                      trailing: Text(data.windSpeed != null
                          ? data.pressure.toString() + " hPa"
                          : "Loading..."),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }

  Future<void> _pullRefresh() async {
    WeatherReport freshFutureWords = await WeatherApiService.getWeatherReport();
    setState(() {
      weatherReport = Future.value(freshFutureWords);
      count = count++;
    });
  }
}
