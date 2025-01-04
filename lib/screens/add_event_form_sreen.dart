import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AddEventForm extends StatefulWidget {
  final Function(String title, String time, String location, LatLng coordinates)
      onAddEvent;

  AddEventForm({required this.onAddEvent});

  @override
  _AddEventFormState createState() => _AddEventFormState();
}

class _AddEventFormState extends State<AddEventForm> {
  final _titleController = TextEditingController();
  final _timeController = TextEditingController();
  final _locationController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: InputDecoration(labelText: 'Title'),
          ),
          TextField(
            controller: _timeController,
            decoration:
                InputDecoration(labelText: 'Time (e.g., 2025-01-01 14:00:00)'),
          ),
          TextField(
            controller: _locationController,
            decoration: InputDecoration(labelText: 'Location'),
          ),
          TextField(
            controller: _latitudeController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Latitude'),
          ),
          TextField(
            controller: _longitudeController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Longitude'),
          ),
          ElevatedButton(
            onPressed: () {
              final title = _titleController.text;
              final time = _timeController.text;
              final location = _locationController.text;
              final latitude = double.tryParse(_latitudeController.text) ?? 0.0;
              final longitude =
                  double.tryParse(_longitudeController.text) ?? 0.0;

              if (title.isNotEmpty && time.isNotEmpty && location.isNotEmpty) {
                final coordinates = LatLng(latitude, longitude);
                widget.onAddEvent(title, time, location, coordinates);
                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please fill in all fields')),
                );
              }
            },
            child: Text('Add Event'),
          ),
        ],
      ),
    );
  }
}
