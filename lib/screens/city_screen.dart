import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:weather_app/screens/location_screen.dart';

import '../city.dart';
import '../services/weather.dart';
import '../utilities/constants.dart';

class CityScreen extends StatefulWidget {
  const CityScreen({super.key});

  @override
  CityScreenState createState() => CityScreenState();
}

class CityScreenState extends State<CityScreen> {
  late GlobalKey<FormState> _key;
  String? city;
  List<City> cities = [];
  List<City> result = [];

  @override
  void initState() {
    readJsonFile();
    _key = GlobalKey<FormState>();
    super.initState();
  }

  void search() {
    result.clear();
    if (city != null && city!.isNotEmpty) {
      for (int i = 0; i < cities.length; i++) {
        if (cities[i].name.contains(city!)) {
          setState(() {
            result.add(cities[i]);
          });
          if (result.length == 20) {
            break;
          }
        }
      }
    }
    print(result);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<WeatherModel> getCityWeather(String city) async {
    WeatherModel weatherInfo = WeatherModel();
    await weatherInfo.getCityWeather(city);
    return weatherInfo;
  }

  void readJsonFile() async {
    try {
      String jsonString = await rootBundle.loadString('assets/cities.json');
      Map<String, dynamic> jsonData = json.decode(jsonString);
      List list = jsonData['cities'];
      List<Map<String, dynamic>> mapList = List.generate(
          list.length,
          (index) => {
                'city': list[index]['city'],
                'lat': double.tryParse(list[index]['lat']),
                'lng': double.tryParse(list[index]['lng']),
              });
      cities = List.generate(
          mapList.length, (index) => City.fromJson(mapList[index]));

      print(cities.last);
    } catch (e) {
      print('Error reading or parsing JSON file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/city_background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        constraints: const BoxConstraints.expand(),
        child: SafeArea(
          child: Form(
            key: _key,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Align(
                    alignment: Alignment.topLeft,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.yellow,
                        size: 50.0,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding:
                        const EdgeInsetsDirectional.only(start: 20, top: 20),
                    child: Text(
                      "Discover\nWeather in ",
                      style: TextStyle(
                          color: Colors.yellow,
                          fontSize: 34,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    child: TextFormField(
                      textInputAction: TextInputAction.search,
                      onChanged: (input) {
                        setState(() {
                          city = input;
                        });
                        search();
                      },
                      validator: (data) {
                        if (data == null || data.isEmpty) {
                          return "Please Enter City Name";
                        }
                      },
                      decoration: InputDecoration(
                        errorStyle: TextStyle(color: Colors.yellow),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                  // Column(
                  //   children: result.map((e) => Text(e.name)).toList(),
                  // ),
                  ListView.separated(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) => Container(
                            margin: EdgeInsets.symmetric(horizontal: 18),
                            decoration: BoxDecoration(
                                color: Colors.yellow,
                                borderRadius: BorderRadius.circular(30)),
                            child: ListTile(
                              trailing: IconButton(
                                icon: Icon(Icons.search),
                                onPressed: () async {
                                  if (_key.currentState!.validate() &&
                                      city != null) {
                                    WeatherModel model = await getCityWeather(
                                        result[index].name);
                                    if (mounted) {
                                      Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => LocationScreen(
                                                  weatherData: model)),
                                          (route) => false);
                                    }
                                  }
                                },
                              ),
                              title: Text(result[index].name),
                            ),
                          ),
                      separatorBuilder: (context, index) => SizedBox(
                            height: 8,
                          ),
                      itemCount: result.length > 20 ? 20 : result.length),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
