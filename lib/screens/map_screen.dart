import 'package:exam_calendar_flutter/models/exam.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapScreen extends StatefulWidget {
  final Map<DateTime, List<ExamEvent>> event;

  MapScreen({required this.event});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  List<Marker> _markers = [];
  Polyline? _routePolyline;

  @override
  void initState() {
    super.initState();
    _initializeMarkers();
  }

  void _initializeMarkers() {
    final events = widget.event.values.expand((e) => e).toList();
    print("Events data: $events");

    events.forEach((event) {
      print("Event Coordinates: ${event.coordinates}");
    });

    setState(() {
      _markers = events
          .map(
            (event) => Marker(
              markerId: MarkerId(event.id.toString()),
              position: event.coordinates,
              infoWindow: InfoWindow(
                title: event.title,
                snippet: event.location,
                onTap: () => _getRouteToEvent(event.coordinates),
              ),
            ),
          )
          .toList();
    });

    if (events.isNotEmpty) {
      final firstEventCoordinates = events.first.coordinates;
      _mapController.animateCamera(
        CameraUpdate.newLatLngZoom(firstEventCoordinates, 14),
      );
    }

    print("Markers: ${_markers.length}");
  }

  Future<void> _getRouteToEvent(LatLng destination) async {
    final location = await Location().getLocation();
    final start = '${location.latitude},${location.longitude}';
    final end = '${destination.latitude},${destination.longitude}';
    final apiKey = 'YOUR_GOOGLE_MAPS_API_KEY';
    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=$start&destination=$end&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final points = data['routes'][0]['overview_polyline']['points'];
      final polylineCoordinates = _decodePolyline(points);

      setState(() {
        _routePolyline = Polyline(
          polylineId: PolylineId('route'),
          color: Colors.blue,
          width: 5,
          points: polylineCoordinates,
        );
      });
    }
  }

  List<LatLng> _decodePolyline(String polyline) {
    List<LatLng> coordinates = [];
    int index = 0;
    int len = polyline.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int shift = 0, result = 0;
      int b;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      coordinates.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return coordinates;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Map'),
      ),
      body: GoogleMap(
        onMapCreated: (controller) {
          _mapController = controller;
        },
        initialCameraPosition: CameraPosition(
          target: LatLng(41.9981, 21.4254),
          zoom: 13,
        ),
        markers: Set.from(_markers),
        polylines: _routePolyline != null ? {_routePolyline!} : {},
      ),
    );
  }
}
