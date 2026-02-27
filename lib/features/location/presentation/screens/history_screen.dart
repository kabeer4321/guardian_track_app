import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/date_formatter.dart';
import '../bloc/location_bloc.dart';
import '../bloc/location_event.dart';
import '../bloc/location_state.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {

    context.read<LocationBloc>().add(LoadLocations());

    return Scaffold(
      appBar: AppBar(title: const Text("History")),
      body: BlocBuilder<LocationBloc, LocationState>(
        builder: (context, state) {

          if (state is LocationLoaded) {

            if (state.locations.isEmpty) {
              return const Center(
                child: Text("No locations saved yet"),
              );
            }

            return ListView.builder(
              itemCount: state.locations.length,
              itemBuilder: (context, index) {

                final loc = state.locations[index];

                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(
                      "Lat: ${loc.lat}, Lng: ${loc.lng}",
                    ),
                    subtitle: Text(
                      "${DateFormatter.formatDate(loc.time)} "
                          "${DateFormatter.formatTime(loc.time)}",
                    ),
                  ),
                );
              },
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}