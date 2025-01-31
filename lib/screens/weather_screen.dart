import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';

class WeatherScreen extends StatefulWidget {
  final double eventLat; // Latitude of the event location
  final double eventLon; // Longitude of the event location

  WeatherScreen({required this.eventLat, required this.eventLon});

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String? _weatherCondition; // To hold weather condition description
  String? _temperature; // To hold temperature
  String? _location; // To display location name

  final Map<String, Map<String, double>> _locationCoordinates = {
    "京士柏": {"lat": 22.307, "lon": 114.174},
    "香港天文台": {"lat": 22.302, "lon": 114.174},
    "黃竹坑": {"lat": 22.249, "lon": 114.167},
    "打鼓嶺": {"lat": 22.542, "lon": 114.146},
    "流浮山": {"lat": 22.457, "lon": 113.995},
    "大埔": {"lat": 22.449, "lon": 114.171},
    "沙田": {"lat": 22.382, "lon": 114.191},
    "屯門": {"lat": 22.391, "lon": 113.977},
    "將軍澳": {"lat": 22.308, "lon": 114.264},
    "西貢": {"lat": 22.383, "lon": 114.277},
    "長洲": {"lat": 22.204, "lon": 114.027},
    "赤鱲角": {"lat": 22.315, "lon": 113.936},
    "青衣": {"lat": 22.363, "lon": 114.104},
    "石崗": {"lat": 22.405, "lon": 114.051},
    "荃灣可觀": {"lat": 22.371, "lon": 114.109},
    "荃灣城門谷": {"lat": 22.370, "lon": 114.121},
    "香港公園": {"lat": 22.276, "lon": 114.163},
    "筲箕灣": {"lat": 22.278, "lon": 114.234},
    "九龍城": {"lat": 22.328, "lon": 114.190},
    "跑馬地": {"lat": 22.271, "lon": 114.184},
    "黃大仙": {"lat": 22.341, "lon": 114.202},
    "赤柱": {"lat": 22.218, "lon": 114.214},
    "觀塘": {"lat": 22.313, "lon": 114.225},
    "深水埗": {"lat": 22.329, "lon": 114.159},
    "啟德跑道公園": {"lat": 22.316, "lon": 114.214},
    "元朗公園": {"lat": 22.442, "lon": 114.032},
    "大美督": {"lat": 22.484, "lon": 114.235},
  };

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

      // Extract temperature data
      final temperatureData = data['temperature']['data'];

      // Find the nearest weather location
      final nearestLocation = _findNearestLocation(temperatureData);

      if (nearestLocation != null) {
        // Extract weather condition (based on icon)
        final weatherIcon = data['icon'][0]; // First icon from the list
        final weatherCondition = _mapWeatherIconToDescription(weatherIcon);

        setState(() {
          _temperature = nearestLocation['value'].toString();
          _location = nearestLocation['place'];
          _weatherCondition = weatherCondition;
        });
      } else {
        setState(() {
          _temperature = 'N/A';
          _location = 'Unknown Location';
          _weatherCondition = 'N/A';
        });
      }
    } else {
      setState(() {
        _weatherCondition = 'Error fetching weather data';
        _temperature = 'N/A';
        _location = 'Unknown Location';
      });
    }
  }

  Map<String, dynamic>? _findNearestLocation(List<dynamic> temperatureData) {
    double minDistance = double.infinity;
    Map<String, dynamic>? nearestLocation;

    for (var location in temperatureData) {
      final place = location['place'];
      final coords = _locationCoordinates[place];

      if (coords != null) {
        final distance = Geolocator.distanceBetween(
          widget.eventLat, // Event's latitude
          widget.eventLon, // Event's longitude
          coords['lat']!,
          coords['lon']!,
        );

        if (distance < minDistance) {
          minDistance = distance;
          nearestLocation = location;
        }
      }
    }
    return nearestLocation;
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
        title: Text('Event Weather'),
      ),
      body: Center(
        child: _temperature == null
            ? CircularProgressIndicator()
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Nearest Weather Station: $_location',
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