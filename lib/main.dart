import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/services/background_service.dart';
import 'core/services/permission_service.dart';
import 'features/location/data/datasource/location_local_datasource.dart';
import 'features/location/data/repository/location_repository_impl.dart';
import 'features/location/domain/usecases/get_locations.dart';
import 'features/location/domain/usecases/save_location.dart';
import 'features/location/presentation/bloc/location_bloc.dart';
import 'features/location/presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeBackgroundService();

  final dataSource = LocationLocalDataSource();
  final repository = LocationRepositoryImpl(dataSource);
  final permissionService = PermissionService();

  runApp(MyApp(repository, permissionService));
}

class MyApp extends StatelessWidget {
  final LocationRepositoryImpl repository;
  final PermissionService permissionService;

  const MyApp(
      this.repository,
      this.permissionService, {
        super.key,
      });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LocationBloc(
        GetLocations(repository),
        SaveLocation(repository),
        permissionService,
      ),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: HomeScreen(),
      ),
    );
  }
}