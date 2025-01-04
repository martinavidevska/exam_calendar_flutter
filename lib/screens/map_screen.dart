import 'package:exam_calendar_flutter/models/exam.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatelessWidget {
  final Map<DateTime, List<ExamEvent>> events;
  final LatLng currentLocation;

  MapScreen({required this.events, required this.currentLocation});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Locations'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: currentLocation,
          zoom: 12,
        ),
        markers: events.entries
            .expand((entry) => entry.value.map((event) => Marker(
                  markerId: MarkerId(event.title),
                  position: event.coordinates,
                  infoWindow: InfoWindow(
                    title: event.title,
                    snippet: '${event.dateTime} at ${event.location}',
                  ),
                )))
            .toSet(),
      ),
    );
  }
}
