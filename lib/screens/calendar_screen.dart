import 'package:exam_calendar_flutter/models/exam.dart';
import 'package:exam_calendar_flutter/screens/add_event_form_sreen.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'map_screen.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<ExamEvent>> _events = {};

  void _addEvent(DateTime date, ExamEvent event) {
    if (_events[date] != null) {
      _events[date]!.add(event);
    } else {
      _events[date] = [event];
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exam Schedule'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            eventLoader: (day) {
              return _events[day] ?? [];
            },
          ),
          Expanded(
            child: ListView(
              children: (_events[_selectedDay] ?? []).map((event) {
                return ListTile(
                  title: Text(event.title),
                  subtitle: Text(
                      'Time: ${event.dateTime}, Location: ${event.location}'),
                );
              }).toList(),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final location = await Location().getLocation();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => MapScreen(
                    events: _events,
                    currentLocation:
                        LatLng(location.latitude!, location.longitude!),
                  ),
                ),
              );
            },
            child: Text('View Events on Map'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Add Event'),
              content: AddEventForm(
                onAddEvent: (title, time, location, coordinates) {
                  final event = ExamEvent(
                    title: title,
                    dateTime: DateTime.parse(time),
                    location: location,
                    coordinates: coordinates,
                  );
                  _addEvent(_selectedDay ?? DateTime.now(), event);
                },
              ),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
