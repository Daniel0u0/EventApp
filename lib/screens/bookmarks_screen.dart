import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event.dart'; // Ensure you have the Event model accessible
import '../services/event_service.dart'; // Ensure you have the EventService accessible

class BookmarksScreen extends StatefulWidget {
  @override
  _BookmarksScreenState createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  final EventService _eventService = EventService();
  List<Event> _bookmarkedEvents = [];

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  // Load bookmarks from SharedPreferences and retrieve event details
  Future<void> _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> bookmarks = prefs.getStringList('bookmarks') ?? [];

    // Fetch the event details for each bookmarked ID
    List<Event> events = [];
    for (String id in bookmarks) {
      Event? event = await _eventService.getEventById(id);
      if (event != null) {
        events.add(event);
      }
    }

    setState(() {
      _bookmarkedEvents = events;
    });
  }

  // Function to remove a bookmark
  Future<void> _removeBookmark(Event event) async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? bookmarks = prefs.getStringList('bookmarks') ?? [];

    if (bookmarks.contains(event.id.toString())) {
      bookmarks.remove(event.id.toString());
      await prefs.setStringList('bookmarks', bookmarks);
      _loadBookmarks(); // Reload bookmarks after removal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${event.title} removed from bookmarks!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bookmarked Events'),
      ),
      body: _bookmarkedEvents.isEmpty
          ? Center(child: Text('No bookmarks found.'))
          : ListView.builder(
        itemCount: _bookmarkedEvents.length,
        itemBuilder: (context, index) {
          final event = _bookmarkedEvents[index];
          return ListTile(
            title: Text(event.title),
            subtitle: Text('${event.location} - ${event.date}'),
            trailing: IconButton(
              icon: Icon(Icons.remove_circle, color: Colors.red),
              onPressed: () {
                _removeBookmark(event);
              },
            ),
          );
        },
      ),
    );
  }
}
