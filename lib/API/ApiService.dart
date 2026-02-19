import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_data.dart';

class ApiService {
  static const String _URL = 'https://weather-api-nf24.onrender.com/api';

  Future<WeatherData> fetchWeather(double lat, double lon) async {
    final String url = '$_URL/weather/daily/$lat/$lon';

    try{
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

      if(response.statusCode == 200){
        final Map<String, dynamic> data = jsonDecode(response.body);
        return WeatherData.fromJson(data);

      }else{
        throw Exception('Failed to fetch weather. Server responded with ${response.statusCode}');
      }
    }catch(e){
      throw Exception('An error occurred: ${e.toString()}');
    }
  }

}