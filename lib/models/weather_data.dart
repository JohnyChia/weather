class WeatherData {
  final double temperature;
  final double bodyTemperature;
  final double windSpeed;
  final int humidity;
  final int aqi;
  final double uvIndex;
  final String weatherMain; // e.g., "Clouds", "Rain", "Clear"

  WeatherData({
    required this.temperature,
    required this.bodyTemperature,
    required this.windSpeed,
    required this.humidity,
    required this.aqi,
    required this.uvIndex,
    required this.weatherMain,
  });

  // 一个工厂构造函数，用于从JSON Map创建一个WeatherData对象
  // 这将所有解析逻辑都集中在了这一个地方
  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.0,
      bodyTemperature: (json['bodyTemperature'] as num?)?.toDouble() ?? 0.0,
      windSpeed: (json['windSpeed'] as num?)?.toDouble() ?? 0.0,
      humidity: (json['humidity'] as num?)?.round() ?? 0,
      aqi: (json['aqi'] as num?)?.round() ?? 0,
      uvIndex: (json['uvIndex'] as num?)?.toDouble() ?? 0.0,
      // 我们需要这个字段来决定显示哪种天气动画
      weatherMain: json['weatherMain'] as String? ?? 'Clear', // 默认设为晴天
    );
  }
}
