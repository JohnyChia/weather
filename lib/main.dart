import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/weather_screen.dart';
import 'Services/Notification_services.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notification
  await NotificationService().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return MaterialApp(
      title: 'Weather',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const WeatherScreen(),
    );
  }
}
