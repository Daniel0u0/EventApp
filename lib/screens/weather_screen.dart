import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String? _weatherCondition; // To hold weather condition description
  String? _temperature; // To hold temperature
  String? _location; // To display location name

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
  }

  Future<void> _fetchWeatherData() async {
    final url =
        'https://data.weather.gov.hk/weatherAPI/opendata/weather.php?dataType=rhrread&lang=tc';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // Extract temperature for a specific location (e.g. "香港天文台" - Hong Kong Observatory)
      final temperatureData = data['temperature']['data'];
      final locationData = temperatureData.firstWhere(
              (location) => location['place'] == '香港天文台',
          orElse: () => null);

      // Extract weather condition (based on icon)
      final weatherIcon = data['icon'][0]; // First icon from the list
      final weatherCondition = _mapWeatherIconToDescription(weatherIcon);

      setState(() {
        _temperature = locationData != null
            ? locationData['value'].toString()
            : 'N/A';
        _location = locationData != null
            ? locationData['place']
            : 'Unknown Location';
        _weatherCondition = weatherCondition;
      });
    } else {
      setState(() {
        _weatherCondition = 'Error fetching weather data';
        _temperature = 'N/A';
        _location = 'Unknown Location';
      });
    }
  }

  // Map weather icon to description based on the documentation
  String _mapWeatherIconToDescription(int icon) {
    switch (icon) {
      case 50:
        return 'Sunny';
      case 51:
        return 'Cloudy';
      case 52:
        return 'Overcast';
      case 53:
      case 54:
      case 63:
        return 'Rainy';
      case 60:
        return 'Showers';
      case 61:
        return 'Thunderstorms';
      case 62:
        return 'Hazy';
      default:
        return 'Unknown Condition';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hong Kong Weather'),
      ),
      body: Center(
        child: _temperature == null
            ? CircularProgressIndicator()
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Location: $_location',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 10),
            Text(
              'Temperature: $_temperature °C',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 10),
            Text(
              'Condition: $_weatherCondition',
              style: TextStyle(fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }
}