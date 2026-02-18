import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Weather'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
    // Reset state before fetching
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // 1. Check if location services are enabled.
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _errorMessage = 'Location services are disabled.';
          _isLoading = false;
        });
        return;
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred while checking location services: ${e.toString()}';
        _isLoading = false;
      });
      return;
    }

    // 2. Check for location permissions.
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _errorMessage = 'Location permissions are denied.';
          _isLoading = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _errorMessage =
            'Location permissions are permanently denied, we cannot request permissions.';
        _isLoading = false;
      });
      return;
    }

    // 3. Get the current position and fetch weather data with timeouts.
    try {
      // Request high accuracy location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );
      final lat = position.latitude;
      final lon = position.longitude;

      // DEBUG: Print the coordinates to the console
      print('📍 Debug Location: Latitude: $lat, Longitude: $lon');

      // Fetch the city name using geocoding
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
      if (placemarks.isNotEmpty) {
        _city = placemarks.first.locality;
      }

      // This is the correct endpoint to fetch weather data for display
      final forecastUrl =
          Uri.parse('https://weather-api-nf24.onrender.com/api/weather/daily/$lat/$lon');

      // Added a 30-second timeout for the network request
      final response = await http.get(forecastUrl).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> forecast = jsonDecode(response.body);
        if (forecast.isNotEmpty) {
          setState(() {
            _weatherData = forecast.first;
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = 'No weather data available.';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage =
              'Failed to fetch weather. Server responded with ${response.statusCode}';
          _isLoading = false;
        });
      }
    } on TimeoutException {
      // Catching timeout from either geolocator or http
      setState(() {
        _errorMessage = 'The request timed out. Please try again.';
        _isLoading = false;
      });
    } catch (e) {
      // Catching any other errors
      setState(() {
        _errorMessage = 'An error occurred: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Widget _buildWeatherInfo() {
    if (_isLoading) {
      return const Column(
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 10),
          Text('Fetching weather...'),
        ],
      );
    }

    if (_errorMessage != null) {
      return Text(
        _errorMessage!,
        style: const TextStyle(color: Colors.red, fontSize: 16),
        textAlign: TextAlign.center,
      );
    }

    if (_weatherData != null) {
      final cityName = _city ?? 'Unknown Location';
      
      // Safely parse and round the numeric values
      final tempValue = _weatherData!['temperature'];
      final bodyTempValue = _weatherData!['bodyTemperature'];
      final windSpeedValue = _weatherData!['WindSpeed'];

      final temp = tempValue is num ? tempValue.round().toString() : 'N/A';
      final bodyTemp = bodyTempValue is num ? bodyTempValue.round().toString() : 'N/A';
      final windSpeed = windSpeedValue is num ? windSpeedValue.round().toString() : 'N/A';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            cityName,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Temperature: $temp°C',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Feels Like: $bodyTemp°C',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Wind Speed: $windSpeed m/s',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      );
    }

    return const Text('Something went wrong.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Current Weather Forecast:',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            _buildWeatherInfo(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchWeatherData,
        tooltip: 'Refresh',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
