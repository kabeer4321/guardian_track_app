import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/location_model.dart';
import 'location_storage.dart';

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'tracking_channel',
    'Tracking Service',
    description: 'Location tracking service',
    importance: Importance.low,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
  InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize( settings: initializationSettings);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: false,
      isForegroundMode: true,
      notificationChannelId: 'tracking_channel',
      initialNotificationTitle: 'Live Tracking Active',
      initialNotificationContent: 'Tracking your location...',
      foregroundServiceNotificationId: 1,
    ),
    iosConfiguration: IosConfiguration(),
  );
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {

  if (service is AndroidServiceInstance) {
    service.setAsForegroundService();
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  Future<void> saveLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final now = DateTime.now();

      await LocationStorage.save(
        LocationModel(
          lat: position.latitude,
          lng: position.longitude,
          time: now,
        ),
      );

      if (service is AndroidServiceInstance) {
        service.setForegroundNotificationInfo(
          title: "Location Tracking",
          content: "Saved at ${now.hour}:${now.minute}:${now.second}",
        );
      }

      service.invoke("update");

    } catch (e) {
      print("Location error: $e");
    }
  }

  await saveLocation();

  Timer.periodic(const Duration(minutes: 1), (timer) async {
    await saveLocation();
  });
}