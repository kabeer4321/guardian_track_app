import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';

import '../../features/location/data/datasource/location_local_datasource.dart';
import '../../features/location/data/models/location_model.dart';
import '../utils/date_formatter.dart';

Future<void> initializeBackgroundService() async {
  final service = FlutterBackgroundService();

  const AndroidNotificationChannel channel =
  AndroidNotificationChannel(
    'tracking_channel',
    'Tracking Service',
    description: 'Location tracking service',
    importance: Importance.high,
  );

  final FlutterLocalNotificationsPlugin notifications =
  FlutterLocalNotificationsPlugin();

  await notifications.initialize(
    settings: const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
  );

  await notifications
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

  final dataSource = LocationLocalDataSource();

  if (service is AndroidServiceInstance) {
    service.setAsForegroundService();

    service.setForegroundNotificationInfo(
      title: "Location Tracking",
      content: "Starting tracking...",
    );
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

      await dataSource.save(
        LocationModel(
          lat: position.latitude,
          lng: position.longitude,
          time: now,
        ),
      );

      if (service is AndroidServiceInstance) {
        service.setForegroundNotificationInfo(
          title: "Location Tracking",
          content:
          "Updated on ${DateFormatter.formatDate(now)} "
              "at ${DateFormatter.formatTime(now)}",
        );
      }

      service.invoke("update");

    } catch (e) {
      print("Location error: $e");
    }
  }

  saveLocation();

  Timer.periodic(
    const Duration(minutes: 1),
        (_) => saveLocation(),
  );
}