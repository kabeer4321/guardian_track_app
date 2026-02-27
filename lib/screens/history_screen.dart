import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import '../models/location_model.dart';
import '../services/location_storage.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {

  List<LocationModel> locations = [];
  late StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    loadData();

    _subscription =
        FlutterBackgroundService().on("update").listen((event) {
          loadData();
        });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Future<void> loadData() async {
    final data = await LocationStorage.getAll();
    setState(() {
      locations = data.reversed.toList();
    });
  }

  String formatDate(DateTime dateTime) =>
      DateFormat('dd-MM-yyyy').format(dateTime);

  String formatTime(DateTime dateTime) =>
      DateFormat('hh:mm:ss a').format(dateTime);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Saved Locations History")),
      body: locations.isEmpty
          ? const Center(child: Text("No locations saved yet"))
          : ListView.builder(
        itemCount: locations.length,
        itemBuilder: (context, index) {
          final loc = locations[index];

          return Card(
            margin: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 6),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text("Latitude: ${loc.lat}"),
                  Text("Longitude: ${loc.lng}"),
                  const SizedBox(height: 6),
                  Text("Date: ${formatDate(loc.time)}"),
                  Text("Time: ${formatTime(loc.time)}"),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}