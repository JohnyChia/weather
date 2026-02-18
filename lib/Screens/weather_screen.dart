import 'package:flutter/material.dart';
import '../Location/LocationService.dart';
import '../API/ApiService.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final LocationService _locationService = LocationService();
  final ApiService _apiService = ApiService();

  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _weatherData;
  String? _city;

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
  }

  Future<void> _fetchWeatherData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final position = await _locationService.determinePosition();
      final cityName = await _locationService.getCity(position);
      final weatherData = await _apiService.fetchWeather(position.latitude, position.longitude);

      setState(() {
        _city = cityName;
        _weatherData = weatherData;
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade800, Colors.blue.shade500],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: _buildContent(),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchWeatherData,
        tooltip: 'Refresh',
        backgroundColor: Colors.white,
        child: Icon(Icons.refresh, color: Colors.blue.shade700),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 20),
          Text('Loading ...', style: TextStyle(fontSize: 18, color: Colors.white70)),
        ],
      );
    }
    else if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.all(32.0),
        child: Text(
          _errorMessage!,
          style: const TextStyle(color: Colors.white, fontSize: 18),
          textAlign: TextAlign.center,
        ),
      );
    }
    else if (_weatherData != null) {
      return _buildWeatherInfo();
    }
    else {
      return const Text('Something went wrong.', style: TextStyle(color: Colors.white));
    }
  }

  Widget _buildWeatherInfo() {
    final cityName = _city ?? '';
    final temp = (_weatherData!['temperature']) ?? '';
    final bodyTemp = (_weatherData!['bodyTemperature']) ?? '';
    final windSpeed = (_weatherData!['WindSpeed']) ?? '';
    final humidity = (_weatherData!['humidity'] as num?)?.round() ?? '';
    final uv = (_weatherData!['uvIndex']) ?? '';
    final aqi = (_weatherData!['aqi'] as num?)?.round() ?? '';

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(cityName, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 10),
        Text('$temp°', style: const TextStyle(fontSize: 96, fontWeight: FontWeight.w300, color: Colors.white)),
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Card(
            color: Colors.white.withOpacity(0.2),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoColumn(Icons.thermostat, 'Feels Like', '$bodyTemp°'),
                      _buildInfoColumn(Icons.air, 'Wind', '$windSpeed m/s'),
                      _buildInfoColumn(Icons.water_drop, 'Humidity', '$humidity%'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoColumn(Icons.lightbulb_outline, 'UV Rays', '$uv'),
                      _buildInfoColumn(Icons.masks, 'AQI', '$aqi'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoColumn(IconData icon, String title, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 30),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
