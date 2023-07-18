import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_app/services/weather.dart';

import '../services/location.dart';
import '../utilities/constants.dart';
import 'city_screen.dart';

class LocationScreen extends StatefulWidget {
  WeatherModel weatherData;
  LocationScreen({super.key, required this.weatherData});

  @override
  LocationScreenState createState() => LocationScreenState();
}

class LocationScreenState extends State<LocationScreen> {
  late int temp;
  late String cityName;
  late String icon;
  late String description;
  late WeatherModel model;

  Future<WeatherModel> getCurrentLocationWeather() async {
    WeatherModel weatherInfo = WeatherModel();
    await weatherInfo.getCurrentLocationWeather();
    return weatherInfo;
  }

  setData() {
    temp = widget.weatherData.temp.toInt();
    cityName = widget.weatherData.name;
    icon = widget.weatherData.getWeatherIcon();
    description = widget.weatherData.getMessage();
  }

  @override
  void initState() {
    getImage();
    setData();
    super.initState();
  }

  bool isLoaded = false;
  ImageProvider assetImage =
      AssetImage('assets/images/location_background.jpg');
  ImageProvider networkImage =
      NetworkImage('https://source.unsplash.com/random/?nature,day');

  void getImage() {
    networkImage
        .resolve(ImageConfiguration())
        .addListener(ImageStreamListener((image, synchronousCall) {
      setState(() {
        print("change Now");
        isLoaded = true;
      });
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: isLoaded ? networkImage : assetImage,
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                    Colors.white.withOpacity(0.8), BlendMode.dstATop),
              ),
            ),
            constraints: const BoxConstraints.expand(),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    Colors.white.withOpacity(0.0),
                    Colors.white.withOpacity(0.0)
                  ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                  // color: Colors.white.withOpacity(0.0),
                ),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    TextButton(
                      onPressed: () async {
                        widget.weatherData = await getCurrentLocationWeather();
                        print(widget.weatherData.name);
                        setState(() {
                          setData();
                        });
                      },
                      child: const Icon(
                        Icons.near_me,
                        size: 50.0,
                        color: kSecondaryColor,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CityScreen(),
                          ),
                        ).then((value) => () {
                              setState(() {
                                isLoaded = false;
                              });
                              networkImage = NetworkImage(
                                  'https://source.unsplash.com/random/?nature,day');
                              getImage();
                            });
                      },
                      child: const Icon(
                        Icons.location_city,
                        size: 50.0,
                        color: kSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('$icon'),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '$temp',
                          style: kTempTextStyle,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.white, width: 10),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Container(
                              height: 7,
                              width: 35,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10)
                                  // shape: BoxShape.circle,
                                  ),
                            ),
                            const Text(
                              'now',
                              style: TextStyle(
                                fontSize: 30.0,
                                fontFamily: 'Spartan MB',
                                letterSpacing: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 24.0),
                child: Text(
                  '$description',
                  textAlign: TextAlign.right,
                  style: kMessageTextStyle,
                ),
              ),
              ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    padding: EdgeInsets.all(34),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                    ),
                    child: Text(
                      widget.weatherData.name,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
