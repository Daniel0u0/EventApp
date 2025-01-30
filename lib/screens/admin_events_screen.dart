import 'package:flutter/material.dart';
import '../services/event_service.dart'; // Import the EventService
import '../models/event.dart'; // Import the Event model

class AdminEventsScreen extends StatefulWidget {
  @override
  _AdminEventsScreenState createState() => _AdminEventsScreenState();
}

class _AdminEventsScreenState extends State<AdminEventsScreen> {
  final EventService _eventService = EventService();
  List<Event> _events = [];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    List<Event> events = await _eventService.getEvents(); // Fetch events from the service
    setState(() {
      _events = events;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Current Events'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _events.isEmpty
            ? Center(child: Text('No events available.'))
            : ListView.builder(
          itemCount: _events.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(_events[index].title),
              subtitle: Text(_events[index].date),
              onTap: () {
                // Handle event tap if needed (e.g., navigate to event detail)
              },
            );
          },
        ),
      ),
    );
  }
}
