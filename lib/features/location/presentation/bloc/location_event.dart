abstract class LocationEvent {}

class LoadLocations extends LocationEvent {}

class StartTracking extends LocationEvent {}

class StopTracking extends LocationEvent {}

class ServiceUpdated extends LocationEvent {}

class CheckPermissions extends LocationEvent {}