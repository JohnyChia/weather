import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _URL = 'https://weather-api-nf24.onrender.com/api';

  Future<Map<String, dynamic>> fetchWeather(double lat, double lon) async {
    final String url = '$_URL/weather/daily/$lat/$lon';

    try{
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 30));

      if(response.statusCode == 200){
        final List<dynamic> forecast = jsonDecode(response.body);
        if(forecast.isNotEmpty){
          return forecast.first;
        }else{
          throw Exception('No weather data available.');
        }
      }else{
        throw Exception('Failed to fetch weather. Server responded with ${response.statusCode}');
      }
    }catch(e){
      throw Exception('An error occurred: ${e.toString()}');
    }
  }

}