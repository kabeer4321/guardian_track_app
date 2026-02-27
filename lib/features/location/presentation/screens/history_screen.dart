import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:expandable/expandable.dart';

import '../../../../core/utils/date_formatter.dart';
import '../bloc/location_bloc.dart';
import '../bloc/location_event.dart';
import '../bloc/location_state.dart';
import '../../domain/entities/location_entity.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {

  @override
  void initState() {
    super.initState();
    context.read<LocationBloc>().add(LoadLocations());
  }


  Future<void> _openSingleLocation(String lat, String lng) async {
    final uri = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=$lat,$lng",
    );

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }

  Future<void> _openSessionRoute(
      List<LocationEntity> sessionLocations) async {

    if (sessionLocations.length < 2) return;

    final start = sessionLocations.first;
    final end = sessionLocations.last;

    // Middle points as waypoints
    final waypoints = sessionLocations
        .sublist(1, sessionLocations.length - 1)
        .map((e) => "${e.lat},${e.lng}")
        .join("|");

    final uri = Uri.parse(
      "https://www.google.com/maps/dir/?api=1"
          "&origin=${start.lat},${start.lng}"
          "&destination=${end.lat},${end.lng}"
          "&waypoints=$waypoints"
          "&travelmode=driving",
    );

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "History",
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
        backgroundColor: Colors.blue,
      ),
      body: BlocBuilder<LocationBloc, LocationState>(
        builder: (context, state) {

          if (state is LocationLoaded) {

            final isCurrentlyTracking = state.isTracking;

            if (state.locations.isEmpty) {
              return const Center(
                child: Text("No locations saved yet"),
              );
            }

            final grouped = <String, List<LocationEntity>>{};
            for (var loc in state.locations) {
              grouped.putIfAbsent(loc.sessionId, () => []);
              grouped[loc.sessionId]!.add(loc);
            }

            final sessions =
            grouped.entries.toList().reversed.toList();

            return ListView.builder(
              itemCount: sessions.length,
              itemBuilder: (context, index) {

                final sessionLocations =
                    sessions[index].value;

                if (sessionLocations.isEmpty) {
                  return const SizedBox();
                }

                final isLiveSession =
                    isCurrentlyTracking && index == 0;

                return Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  child: ExpandableNotifier(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                        BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                            color: Colors.black.withValues(alpha: 0.1),
                          ),
                        ],
                      ),
                      child: ScrollOnExpand(
                        child: ExpandablePanel(
                          theme: const ExpandableThemeData(
                            hasIcon: true,
                            iconColor: Colors.black,
                          ),

                          header: Padding(
                            padding:
                            const EdgeInsets.all(16),
                            child: _buildSessionHeader(
                              sessionLocations,
                              isLiveSession,
                            ),
                          ),

                          collapsed: const SizedBox(),

                          expanded: Padding(
                            padding:
                            const EdgeInsets.all(16),
                            child: ListView.builder(
                              itemCount:
                              sessionLocations.length,
                              shrinkWrap: true,
                              physics:
                              const NeverScrollableScrollPhysics(),
                              itemBuilder:
                                  (context, i) {

                                final loc =
                                sessionLocations[i];

                                return Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              _buildRow(
                                                  "Latitude",
                                                  loc.lat),
                                              const SizedBox(
                                                  height: 4),
                                              _buildRow(
                                                  "Longitude",
                                                  loc.lng),
                                              const SizedBox(
                                                  height: 4),
                                              _buildRow(
                                                "Time",
                                                DateFormatter
                                                    .formatTime(
                                                    loc.time),
                                              ),
                                              _buildRow(
                                                  "Status",
                                                  loc.status),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.my_location,
                                            color: Colors.red,
                                          ),
                                          onPressed: () {
                                            _openSingleLocation(
                                                loc.lat,
                                                loc.lng);
                                          },
                                        ),
                                      ],
                                    ),
                                    const Divider(
                                        height: 24),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ),
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

  Widget _buildRow(String title, String value) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          "$title: ",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
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

  Widget _buildSessionHeader(
      List<LocationEntity> sessionLocations,
      bool isLiveSession) {

    final start = sessionLocations.first.time;
    final end = sessionLocations.last.time;

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [

        Row(
          children: [
            Expanded(
              child: _buildRow(
                "Session Date",
                DateFormatter.formatDate(start),
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.location_on,
                color: Colors.blue,
              ),
              onPressed: () {
                _openSessionRoute(
                    sessionLocations);
              },
            ),
          ],
        ),

        const SizedBox(height: 6),
        _buildRow(
            "Started",
            DateFormatter.formatTime(start)),
        const SizedBox(height: 6),

        if (!isLiveSession)
          _buildRow(
              "Stopped",
              DateFormatter.formatTime(end))
        else
          const Row(
            children: [
              Icon(Icons.circle,
                  color: Colors.green,
                  size: 10),
              SizedBox(width: 6),
              Text(
                "Continuing live now...",
                style: TextStyle(
                  color: Colors.green,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),
            ],
          ),
      ],
    );
  }
}