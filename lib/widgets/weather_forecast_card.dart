// lib/widgets/weather_forecast_card.dart
import 'package:flutter/material.dart';

class WeatherForecastCard extends StatelessWidget {
  final String time;
  final String temperature;
  final IconData weatherIcon;

  const WeatherForecastCard({
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 100,
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(
                time,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Icon(weatherIcon, size: 32),
              const SizedBox(height: 10),
              Text("$temperature K", style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
