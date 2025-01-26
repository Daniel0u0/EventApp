import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import '../models/event.dart';
import '../services/event_service.dart';

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

  // Loads event data from the service
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

  // Function to save bookmarks
  Future<void> _saveBookmark(Event event) async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? bookmarks = prefs.getStringList('bookmarks') ?? [];

    // Check if the event is already bookmarked
    if (!bookmarks.contains(event.id.toString())) {
      bookmarks.add(event.id.toString());
      await prefs.setStringList('bookmarks', bookmarks);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${event.title} bookmarked!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${event.title} is already bookmarked!')),
      );
    }
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
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.bookmark),
                  onPressed: () {
                    _saveBookmark(event); // Call the bookmark function
                  },
                ),
                Icon(Icons.arrow_forward_ios),
              ],
            ),
            onTap: () {
              // Navigate to event details (to be implemented)
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Tapped on ${event.title}')),
              );
            },
          );
        },
      ),
    );
  }
}
