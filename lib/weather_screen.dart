import 'dart:ffi';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/secrets.dart';
import 'dart:convert';

///  Snapshots is class that allows to handle states in app i.e ,loading,data and error

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String, dynamic>>? _weatherDataFuture;

  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      String cityName = 'Chennai';
      final result = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$openWeatherApiKey',
        ),
      );

      final data = jsonDecode(result.body);

      if (data['cod'] != '200') {
        throw 'An unexpected error occurred';
      }
      return data;
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  void initState() {
    super.initState();
    _weatherDataFuture = getCurrentWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Weather App',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _weatherDataFuture = getCurrentWeather();
              });
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: _weatherDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator.adaptive());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final data = snapshot.data!;

          final currentWeatherData = data['list'][0];

          final currentTemperature = currentWeatherData['main']['temp'];

          final currentSky = currentWeatherData['weather'][0]['main'];

          final currentPressure = currentWeatherData['main']['pressure'];

          final currentHumidity = currentWeatherData['main']['humidity'];

          final currentWindSpeed = currentWeatherData['wind']['speed'];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main card displaying weather information
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(24)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(24)),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Padding(
                          padding: EdgeInsets.all(15.0),
                          child: Column(
                            children: [
                              Text(
                                "$currentTemperature K",
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              SizedBox(height: 10),

                              Icon(
                                currentSky == 'Clouds' || currentSky == "Rain"
                                    ? Icons.wb_cloudy_sharp
                                    : Icons.wb_sunny,
                                size: 56,
                              ),

                              SizedBox(height: 20),

                              Text(
                                currentSky,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Weather forecast list
                const Text(
                  "Hourly Forecast",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.start,
                ),

                const SizedBox(height: 10),

                SizedBox(
                  height: 130,
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      final hourlyForecast = data['list'][index + 1];
                      final time = DateTime.parse(
                        hourlyForecast['dt_txt'],
                      ).toLocal().toString().substring(11, 16);
                      return WeatherForeCastCard(
                        time: time,
                        temperature: hourlyForecast['main']['temp'].toString(),
                        weatherIcon:
                            hourlyForecast['weather'][0]['main'] == 'Clouds' ||
                                hourlyForecast['weather'][0]['main'] == "Rain"
                            ? Icons.wb_cloudy_sharp
                            : Icons.wb_sunny,
                      );
                    },
                    itemCount: 15,
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                  ),
                ),

                // SingleChildScrollView(
                //   scrollDirection: Axis.horizontal,
                //   child: Row(
                //     children: [
                //       for (int i = 0; i < 15; i++)
                //         WeatherForeCastCard(
                //           time: data['list'][i + 1]['dt_txt'],
                //           temperature: data['list'][i + 1]['main']['temp']
                //               .toString(),
                //           weatherIcon:
                //               data['list'][i + 1]['weather'][0]['main'] ==
                //                       'Clouds' ||
                //                   data['list'][i + 1]['weather'][0]['main'] ==
                //                       "Rain"
                //               ? Icons.wb_cloudy_sharp
                //               : Icons.wb_sunny,
                //         ),
                //     ],
                //   ),
                // ),
                const SizedBox(height: 20),
                // Additional information section
                const Text(
                  "Additional Information",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.start,
                ),

                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    AdditionalInformationCard(
                      icon: Icons.water_drop,
                      label: "Humidity",
                      value: "$currentHumidity%",
                    ),
                    AdditionalInformationCard(
                      icon: Icons.air,
                      label: "Wind Speed",
                      value: "$currentWindSpeed km/h",
                    ),
                    AdditionalInformationCard(
                      icon: Icons.thermostat,
                      label: "Pressure",
                      value: "$currentPressure hPa",
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class WeatherForeCastCard extends StatelessWidget {
  final String time;
  final String temperature;
  final IconData weatherIcon;

  const WeatherForeCastCard({
    super.key,
    required this.time,
    required this.temperature,
    required this.weatherIcon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        child: Container(
          width: 100,
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(
                time,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Icon(weatherIcon, size: 32),
              const SizedBox(height: 10),
              Text(
                "$temperature K",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AdditionalInformationCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const AdditionalInformationCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 28, color: Colors.white70),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
