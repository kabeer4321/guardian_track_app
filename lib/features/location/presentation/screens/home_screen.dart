import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:guardian_tracking/features/location/presentation/screens/history_screen.dart';
import '../../../../core/services/permission_service.dart';
import '../../domain/entities/location_entity.dart';
import '../bloc/location_bloc.dart';
import '../bloc/location_event.dart';
import '../bloc/location_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleMapController? controller;


  final PermissionService _permissionService = PermissionService();
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      bool granted = await _permissionService.checkPermissions();

      if (!granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Location & Notification permission required"),
          ),
        );
      }

      context.read<LocationBloc>().add(LoadLocations());
    });

    FlutterBackgroundService().on("update").listen((event) {
      context.read<LocationBloc>().add(ServiceUpdated());
    });
  }

  Set<Marker> buildMarkers(List<LocationEntity> locations) {
    return locations.map((loc) {
      return Marker(
        markerId: MarkerId(loc.time.toString()),
        position: LatLng(loc.lat, loc.lng),
        infoWindow: InfoWindow(
          title: "Tracked Location",
          snippet: loc.time.toString(),
        ),
      );
    }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Live Tracking")),
        body: BlocConsumer<LocationBloc, LocationState>(
          listener: (context, state) {
            if (state is LocationLoaded && state.message != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message!)),
              );
            }
          },
          builder: (context, state) {
            if (state is LocationLoaded) {

              final locations = state.locations;

              LatLng center = locations.isNotEmpty
                  ? LatLng(locations.last.lat, locations.last.lng)
                  : const LatLng(20.5937, 78.9629);

              return Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition:
                    CameraPosition(target: center, zoom: 15),
                    markers: buildMarkers(locations),
                    myLocationEnabled: true,
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: state.isTracking
                              ? null
                              : () async {

                            bool granted =
                            await _permissionService.checkPermissions();

                            if (!granted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Permission required"),
                                ),
                              );
                              return;
                            }

                            context
                                .read<LocationBloc>()
                                .add(StartTracking());
                          },
                          child: const Text("Start"),
                        ),
                        ElevatedButton(
                          onPressed: !state.isTracking
                              ? null
                              : () {
                            context
                                .read<LocationBloc>()
                                .add(StopTracking());
                          },
                          child: const Text("Stop"),
                        ),
                      ],
                    ),
                  )
                ],
              );
            }

            return const Center(child: CircularProgressIndicator());
          },
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