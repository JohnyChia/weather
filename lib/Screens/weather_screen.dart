import 'package:flutter/material.dart';
import '../models/weather_data.dart';
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
  WeatherData? _weatherData;
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

      print('Latitude: ${position.latitude}');
      print('Longitude: ${position.longitude}');

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

  String _getBackgroundImage(String? weatherMain) {
    switch (weatherMain) {
      case 'Rain':
      case 'Drizzle':
        return 'assets/images/rain.jpg';
      case 'Thunderstorm':
        return 'assets/images/Thunderstorm.jpg';
      case 'Clouds':
        return 'assets/images/clouds.jpg';
      case 'Clear':
        return 'assets/images/sunny.jpg';
      case 'Snow':
        return 'assets/images/snow.jpeg';
      default:
        return 'assets/images/sunny.jpg';
    }
  }

  IconData _getWeatherIcon(String? weatherMain) {
    switch (weatherMain) {
      case 'Clouds':
        return Icons.wb_cloudy;
      case 'Rain':
      case 'Drizzle':
        return Icons.umbrella;
      case 'Thunderstorm':
        return Icons.flash_on;
      case 'Snow':
        return Icons.ac_unit;
      case 'Clear':
        return Icons.wb_sunny;
      default:
        return Icons.blur_on;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: Image.asset(
              _isLoading || _weatherData == null
                  ? 'assets/images/sunny.jpg'
                  : _getBackgroundImage(_weatherData!.weatherMain),
              key: ValueKey(_weatherData?.weatherMain),
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.35),
          ),
          SafeArea(
            child: Center(
              child: _buildContent(),
            ),
          ),
        ],
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
    final Time = _weatherData?.time;
    final cityName = _city ?? '';
    final temp = _weatherData!.temperature.round();
    final bodyTemp = _weatherData!.bodyTemperature.round();
    final windSpeed = _weatherData!.windSpeed.round();
    final humidity = _weatherData!.humidity;
    final uv = _weatherData!.uvIndex.round();
    final aqi = _weatherData!.aqi;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
            cityName,
            style: const TextStyle(
                fontSize: 32,
                fontWeight:
                FontWeight.bold,
                color: Colors.white
            ),
        ),
        const SizedBox(height: 20),

        Text(
            '${Time?.hour}:${Time?.minute}',
            style: const TextStyle(
                fontSize: 24,
                fontWeight:
                FontWeight.bold,
                color: Colors.white
            ),
        ),
        const SizedBox(height: 20),

        Icon(
          _getWeatherIcon(_weatherData!.weatherMain),
          color: Colors.white,
          size: 80,
        ),
        const SizedBox(height: 10),

        Text(
            '$temp°',
            style:
            const TextStyle(
                fontSize: 96,
                fontWeight:
                FontWeight.w300,
                color: Colors.white
            ),
        ),
        const SizedBox(height: 30),

        const Text('Weather Forecast', style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),

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



                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
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
                    _buildInfoColumn(Icons.lightbulb_outline, 'UV Index', '$uv'),
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
        Icon(
            icon,
            color: Colors.white,
            size: 30
        ),
        const SizedBox(height: 8),

        Text(
            title,
            style: const TextStyle(
                color: Colors.white70,
                fontSize: 14
            ),
        ),
        const SizedBox(height: 4),

        Text(
            value.toString(),
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold
            ),
        ),
      ],
    );
  }
}
