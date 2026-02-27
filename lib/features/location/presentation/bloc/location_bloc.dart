import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/permission_service.dart';
import '../../domain/usecases/get_locations.dart';
import '../../domain/usecases/save_location.dart';
import 'location_event.dart';
import 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final GetLocations getLocations;
  final SaveLocation saveLocation;
  final PermissionService permissionService;

  String? currentSessionId;

  LocationBloc(
      this.getLocations,
      this.saveLocation,
      this.permissionService,
      ) : super(LocationInitial()) {
    on<LoadLocations>(_load);
    on<StartTracking>(_start);
    on<StopTracking>(_stop);
    on<ServiceUpdated>(_load);
  }

  Future<void> _load(
      LocationEvent event, Emitter<LocationState> emit) async {

    final data = await getLocations();
    final running = await FlutterBackgroundService().isRunning();

    emit(LocationLoaded(
      locations: data,
      isTracking: running,
    ));
  }

  Future<void> _start(
      StartTracking event, Emitter<LocationState> emit) async {

    final running = await FlutterBackgroundService().isRunning();
    if (running) return;

    currentSessionId =
        DateTime.now().millisecondsSinceEpoch.toString();

    await FlutterBackgroundService().startService();

    FlutterBackgroundService().invoke(
      "setSession",
      {"sessionId": currentSessionId},
    );

    final data = await getLocations();

    emit(LocationLoaded(
      locations: data,
      isTracking: true,
    ));
  }

  Future<void> _stop(
      StopTracking event, Emitter<LocationState> emit) async {

    FlutterBackgroundService().invoke("stopService");

    final data = await getLocations();

    emit(LocationLoaded(
      locations: data,
      isTracking: false,
    ));
  }
}