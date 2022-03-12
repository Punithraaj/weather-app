import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:weatherapp/model/WeatherData.dart';
import 'package:weatherapp/utils/WeatherApiService.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<WeatherData>(
        future: WeatherApiService.getWeather(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('cannot get weather');
          } else if (snapshot.hasData) {
            return getWeatherScreen(snapshot.data!);
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  getWeatherScreen(WeatherData data) {
    return Column(
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
                  "Currently in Ghana",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600),
                ),
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
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
              Radius.circular(200),
            )),
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: ListView(
                children: <Widget>[
                  ListTile(
                    leading: FaIcon(FontAwesomeIcons.thermometerHalf),
                    title: Text("Temperature"),
                    trailing: Text(data.temp != null
                        ? data.temp.toString() + "\u00B0"
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
                    leading: FaIcon(FontAwesomeIcons.cloud),
                    title: Text("Weather"),
                    trailing: Text(data.description != null
                        ? data.description.toString()
                        : "Loading..."),
                  ),
                  ListTile(
                    leading: FaIcon(FontAwesomeIcons.sun),
                    title: Text("Humidity"),
                    trailing: Text(data.humidity != null
                        ? data.humidity.toString()
                        : "Loading..."),
                  ),
                  ListTile(
                    leading: FaIcon(FontAwesomeIcons.wind),
                    title: Text("Wind Speed"),
                    trailing: Text(data.windSpeed != null
                        ? data.windSpeed.toString()
                        : "Loading..."),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
