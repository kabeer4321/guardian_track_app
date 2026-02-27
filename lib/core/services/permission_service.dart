import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> checkPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission =
    await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      return false;
    }

    var notification = await Permission.notification.status;

    if (notification.isDenied) {
      notification = await Permission.notification.request();
    }

    if (notification.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }

    return (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) &&
        notification.isGranted;
  }
}