import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/location_model.dart';
import '../services/location_storage.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<LocationModel> locations = [];
  GoogleMapController? mapController;
  bool isRunning = false;


  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await checkPermissions(requestIfDenied: true);
      await checkServiceStatus();
      await loadLocations();
    });

    FlutterBackgroundService().on("update").listen((event) {
      loadLocations();
    });
  }

  void showAlreadyRunningMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Tracking is already started"),
        duration: Duration(seconds: 2),
      ),
    );
  }


  bool hasLocationPermission = false;
  bool hasNotificationPermission = false;

  void showPermissionDialog() {

    String message;

    if (!hasLocationPermission && !hasNotificationPermission) {
      message =
      "Location and Notification permissions are required.\nPlease enable them in App Settings.";
    } else if (!hasLocationPermission) {
      message =
      "Location permission is required.\nPlease enable it in App Settings.";
    } else {
      message =
      "Notification permission is required.\nPlease enable it in App Settings.";
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Permission Required"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await openAppSettings();
            },
            child: const Text("Open Settings"),
          ),
        ],
      ),
    );
  }

  Future<void> checkPermissions({bool requestIfDenied = false}) async {

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      hasLocationPermission = false;
      setState(() {});
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied && requestIfDenied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      hasLocationPermission = false;
      setState(() {});
      return;
    }

    hasLocationPermission =
        permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse;

    PermissionStatus notificationStatus =
    await Permission.notification.status;

    if (notificationStatus.isDenied && requestIfDenied) {
      notificationStatus = await Permission.notification.request();
    }

    if (notificationStatus.isPermanentlyDenied) {
      hasNotificationPermission = false;
    } else {
      hasNotificationPermission = notificationStatus.isGranted;
    }

    setState(() {});
  }
  Future<void> checkServiceStatus() async {
    final service = FlutterBackgroundService();
    bool running = await service.isRunning();
    setState(() {
      isRunning = running;
    });
  }

  LatLng? currentPosition;

  Future<void> loadLocations() async {
    final data = await LocationStorage.getAll();

    locations = data;

    if (locations.isNotEmpty) {
      final last = locations.last;
      currentPosition = LatLng(last.lat, last.lng);

      if (mapController != null) {
        mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(currentPosition!, 17),
        );
      }
    }

    setState(() {});
  }
  Set<Marker> getMarkers() {
    if (locations.isEmpty) return {};

    final last10 = locations.length > 10
        ? locations.sublist(locations.length - 10)
        : locations;

    return last10.asMap().entries.map((entry) {
      int index = entry.key;
      LocationModel loc = entry.value;

      return Marker(
        markerId: MarkerId("loc_$index"),
        position: LatLng(loc.lat, loc.lng),
        infoWindow: InfoWindow(
          title: "Point ${index + 1}",
          snippet: loc.time.toString(),
        ),
      );
    }).toSet();
  }

  Future<void> requestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Live Tracking")),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: currentPosition ?? const LatLng(20.5937, 78.9629),
              zoom: currentPosition == null ? 5 : 17,
            ),
            markers: getMarkers(),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onMapCreated: (controller) {
              mapController = controller;

              if (currentPosition != null) {
                mapController!.animateCamera(
                  CameraUpdate.newLatLngZoom(currentPosition!, 17),
                );
              }
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {

                    await checkPermissions(requestIfDenied: true);

                    if (!hasLocationPermission || !hasNotificationPermission) {
                      showPermissionDialog();
                      return;
                    }

                    if (isRunning) {
                      showAlreadyRunningMessage();
                      return;
                    }

                    await FlutterBackgroundService().startService();
                    await checkServiceStatus();
                  },
                  child: const Text("Start"),
                ),
                ElevatedButton(
                  onPressed: !isRunning
                      ? null
                      : () async {
                    FlutterBackgroundService().invoke("stopService");
                    await Future.delayed(const Duration(seconds: 1));
                    await checkServiceStatus();
                  },
                  child: const Text("Stop"),
                ),

              ],
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.history),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const HistoryScreen(),
            ),
          );
        },
      ),
    );
  }
}