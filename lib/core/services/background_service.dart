import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';

import '../../features/location/data/datasource/location_local_datasource.dart';
import '../../features/location/data/models/location_model.dart';

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

  String? sessionId;
  Timer? timer;

  if (service is AndroidServiceInstance) {
    service.setAsForegroundService();
  }

  service.on("setSession").listen((event) {

    sessionId = event?["sessionId"];

    if (sessionId == null) return;

    Future<void> saveLocation() async {
      final now = DateTime.now();

      try {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

        if (!serviceEnabled) {
          await dataSource.save(
            LocationModel(
              lat: "Not Available",
              lng: "Not Available",
              time: now,
              sessionId: sessionId!,
              status: "Location Service Disabled",
            ),
          );

          service.invoke("update");
          return;
        }

        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        await dataSource.save(
          LocationModel(
            lat: position.latitude.toString(),
            lng: position.longitude.toString(),
            time: now,
            sessionId: sessionId!,
            status: "Location Captured",
          ),
        );

        service.invoke("update");

      } catch (e) {
        await dataSource.save(
          LocationModel(
            lat: "Not Available",
            lng: "Not Available",
            time: now,
            sessionId: sessionId!,
            status: "Location Error",
          ),
        );

        service.invoke("update");
      }
    }

    saveLocation();

    timer = Timer.periodic(
      const Duration(seconds: 10),
          (_) => saveLocation(),
    );
  });

  service.on('stopService').listen((event) {
    timer?.cancel();
    service.stopSelf();
  });
}