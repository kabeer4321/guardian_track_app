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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(" History",
          style: TextStyle(
              color: Colors.white,
              fontSize: 25
          ),),
        backgroundColor: Colors.blue,
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back,color: Colors.white,)),
      ),
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
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRow("Latitude", loc.lat.toString()),
                      const SizedBox(height: 6),
                      _buildRow("Longitude", loc.lng.toString()),
                      const SizedBox(height: 6),
                      _buildRow("Date", DateFormatter.formatDate(loc.time)),
                      const SizedBox(height: 6),
                      _buildRow("Time", DateFormatter.formatTime(loc.time)),
                    ],
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
  Widget _buildRow(String title, String value) {
    return Row(
      children: [
        Text(
          "$title: ",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}