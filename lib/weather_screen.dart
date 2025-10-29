import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/secrets.dart';
import 'dart:developer';
import 'dart:convert';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  double temperature = 0.0;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getCurrentWeather();
  }

  Future getCurrentWeather() async {
    String cityName = 'Chennai';

    try {
      setState(() {
        isLoading = true;
      });

      final result = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$openWeatherApiKey',
        ),
      );

      final data = jsonDecode(result.body);

      if (data['cod'] != '200') {
        throw 'An unexpected error occurred';
      }
      setState(() {
        // Update your state with the fetched weather data
        temperature = data['list'][0]['main']['temp'];
        isLoading = false;
      });
    } catch (e) {
      throw Exception(e);
    }
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
        actions: [IconButton(icon: Icon(Icons.refresh), onPressed: () {})],
      ),
      body: isLoading
          ? CircularProgressIndicator()
          : SingleChildScrollView(
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
                                  "$temperature K",
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                SizedBox(height: 10),

                                Icon(Icons.cloud, size: 56),

                                SizedBox(height: 20),

                                Text(
                                  "Rain",
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
                    "Weather Forecast",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.start,
                  ),

                  const SizedBox(height: 10),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        WeatherForeCastCard(),
                        WeatherForeCastCard(),
                        WeatherForeCastCard(),
                        WeatherForeCastCard(),
                        WeatherForeCastCard(),
                        WeatherForeCastCard(),
                      ],
                    ),
                  ),
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
                    children: const [
                      AdditionalInformationCard(
                        icon: Icons.water_drop,
                        label: "Humidity",
                        value: "78%",
                      ),
                      AdditionalInformationCard(
                        icon: Icons.air,
                        label: "Wind Speed",
                        value: "15 km/h",
                      ),
                      AdditionalInformationCard(
                        icon: Icons.thermostat,
                        label: "Pressure",
                        value: "1013 hPa",
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}

class WeatherForeCastCard extends StatelessWidget {
  const WeatherForeCastCard({super.key});

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
                "Mon",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Icon(Icons.cloud, size: 32),
              const SizedBox(height: 10),
              Text(
                "28 °C",
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
