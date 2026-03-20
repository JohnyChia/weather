import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/weather_data.dart';
import '../models/hourly_data.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'dart:io';


class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  /// Initialize notification system
  Future<void> init() async {
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
    InitializationSettings(android: androidSettings);

    tz.initializeTimeZones();

    await _notificationsPlugin.initialize(settings);

    // Request permission for Android 13+
    if (Platform.isAndroid) {
      _notificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
    }
  }

  /// Show notification in phone tray
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'weather_alerts_channel', // Changed channel ID to be safe
      'Weather Alerts',
      channelDescription: 'Weather notification channel',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      playSound: true,
    );

    const NotificationDetails details =
    NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(id, title, body, details);
  }

  /// Check rain and notify user
  void checkRainAndNotify(List<HourlyData> hourlyList) {
    final rainList = hourlyList.where(
          (h) => h.condition.toLowerCase().contains('rain'),
    ).toList();

    if (rainList.isNotEmpty) {
      final rain = rainList.first;

      showNotification(
        id: 1,
        title: '☔ Rain Alert',
        body: 'Rain at ${rain.weatherTime}. Bring umbrella!',

      );
    } else {
      showNotification(
        id: 2,
        title: '🌤 Weather Update',
        body: 'No rain today. Enjoy!',
      );
    }
  }

  /// Show current weather notification
  Future<void> showCurrentWeatherNotification({
    required String cityName,
    required String condition,
    required double temperature,
  }) async {
    await showNotification(
      id: 0,
      title: "Current Weather in $cityName",
      body: "$condition | ${temperature.round()}°C",
    );
  }

}
