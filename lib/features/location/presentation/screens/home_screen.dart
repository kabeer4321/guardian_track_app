import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:guardian_tracking/features/location/presentation/screens/history_screen.dart';
import '../../../../core/services/permission_service.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(" Guardian Route App ",
          style: TextStyle(
            color: Colors.white,
            fontSize: 25
          ),),
      backgroundColor: Colors.blue,
      ),
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
                    myLocationEnabled: true,
                  ),
                  Padding(
                    padding: EdgeInsetsGeometry.only(right: 40, bottom: 100),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!state.isTracking)
                          InkWell(
                            onTap: () async {
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
                              context.read<LocationBloc>().add(StartTracking());
                            },
                            child: Container(
                              height: 40,
                              width: 150,
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(12)
                              ),
                                child:
                                Center(
                                  child: const Text("Start Tracking",style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 25
                                  ),),
                                ),
                            ),
                          ),
                          SizedBox(height: 5,),
                          if (state.isTracking)
                          InkWell(
                            onTap: () {
                              context
                                  .read<LocationBloc>()
                                  .add(StopTracking());
                            },
                            child: Container(
                              height: 40,
                              width: 150,
                              decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(12)
                              ),
                              child:
                              Center(
                                child: const Text("Stop Tracking",style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 25
                                ),),
                              ),
                            ),
                          ),
                          SizedBox(height: 5,),
                          InkWell(
                            onTap:(){
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const HistoryScreen(),
                                ),
                              );
                            },
                            child: Container(
                              height: 40,
                              width: 150,
                              decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(12)
                              ),
                              child:
                              Center(
                                child: const Text("History",style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 25
                                ),),
                              ),
                            ),
                          ),
                          SizedBox(height: 5,),
                        ],
                      ),
                    ),
                  )
                ],
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
    );
  }
}