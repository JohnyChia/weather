
class WeatherData {
  final DateTime time;
  final double temperature;
  final double bodyTemperature;
  final double windSpeed;
  final int humidity;
  final int aqi;
  final double uvIndex;
  final String weatherMain;

  WeatherData({
    required this.time,
    required this.temperature,
    required this.bodyTemperature,
    required this.windSpeed,
    required this.humidity,
    required this.aqi,
    required this.uvIndex,
    required this.weatherMain,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      time: DateTime.fromMicrosecondsSinceEpoch((json['dt'] as int? ?? 0) * 1000),
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.0,
      bodyTemperature: (json['bodyTemperature'] as num?)?.toDouble() ?? 0.0,
      windSpeed: (json['windSpeed'] as num?)?.toDouble() ?? 0.0,
      humidity: (json['humidity'] as num?)?.round() ?? 0,
      aqi: (json['aqi'] as num?)?.round() ?? 0,
      uvIndex: (json['uvIndex'] as num?)?.toDouble() ?? 0.0,
      weatherMain: json['weatherMain'] as String? ?? 'Clear',
    );
  }
}
