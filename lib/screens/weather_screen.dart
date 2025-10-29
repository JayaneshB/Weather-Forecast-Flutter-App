// lib/screens/weather_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:weather_app/services/weather_service.dart';
import 'package:weather_app/widgets/additional_informartion_card.dart';
import 'package:weather_app/widgets/weather_forecast_card.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final _service = WeatherService();
  late Future<Map<String, dynamic>> _weatherDataFuture = _service
      .getWeatherData('Chennai');

  void _refreshWeather() {
    setState(() {
      _weatherDataFuture = _service.getWeatherData('Chennai');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weather App',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshWeather,
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _weatherDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final data = snapshot.data!;
          final current = data['list'][0];
          final currentTemp = current['main']['temp'];
          final currentSky = current['weather'][0]['main'];
          final humidity = current['main']['humidity'];
          final pressure = current['main']['pressure'];
          final wind = current['wind']['speed'];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMainWeatherCard(currentTemp, currentSky),
                const SizedBox(height: 20),
                const Text(
                  "Hourly Forecast",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _buildHourlyForecast(data),
                const SizedBox(height: 20),
                const Text(
                  "Additional Information",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _buildAdditionalInfo(humidity, wind, pressure),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainWeatherCard(num temp, String sky) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  Text(
                    "$temp K",
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Icon(
                    sky == 'Clouds' || sky == "Rain"
                        ? Icons.wb_cloudy_sharp
                        : Icons.wb_sunny,
                    size: 56,
                  ),
                  const SizedBox(height: 20),
                  Text(sky, style: const TextStyle(fontSize: 20)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHourlyForecast(Map<String, dynamic> data) {
    final forecastList = data['list'] as List<dynamic>;

    // skipping the first item if it's already shown as "current weather"
    final itemCount = forecastList.length > 1 ? forecastList.length - 1 : 0;

    return SizedBox(
      height: 130,
      child: ListView.builder(
        itemCount: itemCount,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final forecast = data['list'][index + 1];
          final time = DateTime.parse(
            forecast['dt_txt'],
          ).toLocal().toString().substring(11, 16);
          return WeatherForecastCard(
            time: time,
            temperature: forecast['main']['temp'].toString(),
            weatherIcon:
                forecast['weather'][0]['main'] == 'Clouds' ||
                    forecast['weather'][0]['main'] == 'Rain'
                ? Icons.wb_cloudy_sharp
                : Icons.wb_sunny,
          );
        },
      ),
    );
  }

  Widget _buildAdditionalInfo(num humidity, num wind, num pressure) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        AdditionalInfoCard(
          icon: Icons.water_drop,
          label: "Humidity",
          value: "$humidity%",
        ),
        AdditionalInfoCard(icon: Icons.air, label: "Wind", value: "$wind km/h"),
        AdditionalInfoCard(
          icon: Icons.thermostat,
          label: "Pressure",
          value: "$pressure hPa",
        ),
      ],
    );
  }
}
