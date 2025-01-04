import 'package:google_maps_flutter/google_maps_flutter.dart';

class ExamEvent {
  final int? id;
  final String title;
  final DateTime dateTime;
  final String location;
  final LatLng coordinates;

  ExamEvent(
      {this.id,
      required this.title,
      required this.dateTime,
      required this.location,
      required this.coordinates});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date': dateTime.toIso8601String(),
      'latitude': coordinates.latitude,
      'longitude': coordinates.longitude,
      'location': location,
    };
  }

  factory ExamEvent.fromMap(Map<String, dynamic> map) {
    return ExamEvent(
      id: map['id'],
      title: map['title'],
      dateTime: DateTime.parse(map['date']),
      coordinates: LatLng(map['latitude'], map['longitude']),
      location: map['location'],
    );
  }
}
