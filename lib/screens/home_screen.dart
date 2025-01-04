import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/event_service.dart';
import 'event_details_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final EventService _eventService = EventService();
  List<Event> _events = [];
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  // Loads events from the service
  Future<void> _loadEvents() async {
    final events = await _eventService.loadEvents();
    setState(() {
      _events = events;
    });
  }

  // Filters events based on the selected category
  List<Event> _getFilteredEvents() {
    if (_selectedCategory == 'All') {
      return _events;
    }
    return _events.where((event) => event.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredEvents = _getFilteredEvents();

    return Scaffold(
      appBar: AppBar(
        title: Text('Local Events'),
        actions: [
          // Dropdown for filtering by category
          DropdownButton<String>(
            value: _selectedCategory,
            items: ['All', 'Art', 'Health', 'Food'].map((String category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value!;
              });
            },
          ),
        ],
      ),
      body: filteredEvents.isEmpty
          ? Center(
        child: Text(
          'No events found for this category',
          style: TextStyle(fontSize: 16),
        ),
      )
          : ListView.builder(
        itemCount: filteredEvents.length,
        itemBuilder: (context, index) {
          final event = filteredEvents[index];
          return ListTile(
            title: Text(event.title),
            subtitle: Text(
              '${event.location} - ${event.date}',
              style: TextStyle(color: Colors.grey),
            ),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to the Event Details screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventDetailsScreen(event: event),
                ),
              );
            },
          );
        },
      ),
    );
  }
}