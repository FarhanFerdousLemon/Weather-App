import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:jiffy/jiffy.dart';
import 'package:weatherapp/search.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    _determinePosition();
    super.initState();
  }

  Position? position;

  Map<String, dynamic>? weatherMap;
  Map<String, dynamic>? forecastMap;

  _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    position = await Geolocator.getCurrentPosition();

    fetchWeatherData();
  }

  fetchWeatherData() async {
    String weatherAPI =
        "https://api.openweathermap.org/data/2.5/weather?lat=${position!.latitude}&lon=${position!.longitude}&appid=c05bc98192aa48b04f9710b62b4777f3";

    String forecastAPI =
        "https://api.openweathermap.org/data/2.5/forecast?lat=${position!.latitude}&lon=${position!.longitude}&appid=c05bc98192aa48b04f9710b62b4777f3";

    var weatherResponse = await http.get(Uri.parse(weatherAPI));
    var forecastResponse = await http.get(Uri.parse(forecastAPI));

    setState(() {
      weatherMap = Map<String, dynamic>.from(jsonDecode(weatherResponse.body));
      forecastMap =
          Map<String, dynamic>.from(jsonDecode(forecastResponse.body));
    });

    ///print(weatherResponse.body.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Weather App"),
        leading: InkWell(child: Icon(Icons.search)),
        backgroundColor: Color.fromARGB(255, 71, 121, 147),
        actions: [Icon(Icons.my_location_outlined)],
      ),
      backgroundColor: Colors.blueGrey,
      body: weatherMap == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.start,
                  //crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SafeArea(
                      child: Container(
                        height: 600,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            color: Color.fromARGB(255, 148, 172, 185)
                                .withOpacity(0.5)),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.topRight,
                              child: Container(
                                padding: EdgeInsets.all(10),
                                height: 120,
                                width: 200,
                                decoration: BoxDecoration(
                                    color: Colors.blueGrey,
                                    borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(18),
//bottomRight: Radius.circular(18),
                                        topRight: Radius.circular(18))),
                                child: Column(
                                  children: [
                                    spacebox(20),
                                    Text(
                                      '${Jiffy(DateTime.now()).format('MMM do, yyyy  h:mm ')}',
                                      style: myfonts(17, FontWeight.bold),
                                    ),
                                    spacebox(10),
                                    Text(
                                      '${weatherMap!["name"]}',
                                      style: myfonts(26, FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 220),
                              child: Container(
                                height: 30,
                                width: 50,
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(10),
                              height: 210,
                              width: 350,
                              decoration: BoxDecoration(
                                  color: Colors.blueGrey,
                                  borderRadius: BorderRadius.circular(20)),
                              child: Column(
                                children: [
                                  Text(
                                    '${weatherMap!['weather'][0]['main'] == 'Rain' ? "🌧️" : weatherMap!['weather'][0]['main'] == 'Haze' ? "☁️" : weatherMap!['weather'][0]['main'] == 'Cloudy' ? "🌤️" : "🌥️"}',
                                    style: TextStyle(fontSize: 80),
                                  ),
                                  Text(
                                    '${((weatherMap!['main']['temp'] - 273.15).toStringAsFixed(2))}°C ',
                                    style: myfonts(50, FontWeight.bold),
                                  ),
                                  Text(
                                    '${weatherMap!['weather'][0]['main']}',
                                    style: myfonts(28, FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 220),
                              child: Container(
                                height: 25,
                                width: 50,
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey,
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomLeft,
                              child: Container(
                                padding: EdgeInsets.all(10),
                                height: 70,
                                width: 200,
                                decoration: BoxDecoration(
                                    color: Colors.blueGrey,
                                    borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(18),
                                        bottomRight: Radius.circular(18))),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Text(
                                        '🌥️ feels like : ${((weatherMap!['main']['feels_like'] - 273.15).toStringAsFixed(2))}°C',
                                        style: myfonts(17, FontWeight.bold),
                                      ),
                                    ),
                                    spacebox(10),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 190),
                              child: Container(
                                height: 25,
                                width: 50,
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(10),
                              height: 90,
                              width: 300,
                              decoration: BoxDecoration(
                                  color: Colors.blueGrey,
                                  borderRadius: BorderRadius.circular(20)),
                              child: Column(
                                children: [
                                  spacebox(10),
                                  Text(
                                    '🌦️ Humidity: ${weatherMap!['main']['humidity']}% , 🌪️ Pressure: ${weatherMap!['main']['pressure']}hPa',
                                    style: myfonts(15, FontWeight.bold),
                                  ),
                                  spacebox(15),
                                  Text(
                                    '🌄 Sunrise: ${Jiffy(DateTime.fromMillisecondsSinceEpoch(weatherMap!['sys']['sunrise'] * 1000)).format('h:mm a')} , 🌅 Sunset: ${Jiffy(DateTime.fromMillisecondsSinceEpoch(weatherMap!['sys']['sunset'] * 1000)).format('h:mm a')}',
                                    style: myfonts(15, FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 180),
                              child: Container(
                                height: 30,
                                width: 50,
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    spacebox(20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        height: 40,
                        child: Text('Forecast',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 22)),
                      ),
                    ),
                    SizedBox(
                      height: 160,
                      child: ListView.separated(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: forecastMap!.length,
                        itemBuilder: (context, index) {
                          return Container(
                            height: 130,
                            width: 100,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                color: Color.fromARGB(255, 148, 172, 185)),
                            child: Column(
                              children: [
                                spacebox(10),
                                Text(
                                    "${Jiffy('${forecastMap!["list"][index]["dt_txt"]}').format("EEE, h:mm a")}",
                                    style: myfonts(14)),
                                spacebox(10),
                                Text(
                                  '${forecastMap!['list'][index]['weather'][0]['main'] == 'Rain' ? "🌧️" : forecastMap!['list'][index]['weather'][0]['main'] == 'Sunny' ? "🌦️" : "☁️"}',
                                  style: TextStyle(fontSize: 55),
                                ),
                                spacebox(8),
                                Text(
                                  '${((forecastMap!['list'][index]['main']['temp'] - 273.15).toStringAsFixed(2))} °C',
                                  style: myfonts(18, FontWeight.bold),
                                ),
                                spacebox(8),
                              ],
                            ),
                          );
                        },
                        separatorBuilder: (context, index) => spacebox(0, 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  myfonts(double? fs, [FontWeight? fw]) {
    return TextStyle(
      fontSize: fs,
      fontWeight: fw,
      color: Colors.white,
    );
  }

  spacebox([double? h, double? w]) {
    return SizedBox(
      height: h,
      width: w,
    );
  }
}
