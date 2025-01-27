import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event.dart';
import '../services/event_service.dart';
import 'bookmarks_screen.dart'; // Import the BookmarksScreen
import '../widgets/BookmarkWidget.dart'; // Import the EventBookmarkWidget
import 'setting_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final EventService _eventService = EventService();
  List<Event> _events = [];
  List<String> _bookmarkedEventIds = []; // To store bookmarked event IDs
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _loadBookmarks(); // Load bookmarks first
    _loadEvents(); // Then load events
  }

  Future<void> _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    _bookmarkedEventIds = prefs.getStringList('bookmarks') ?? [];
  }

  Future<void> _loadEvents() async {
    final events = await _eventService.loadEvents();
    setState(() {
      _events = events.map((event) {
        // Set the isBookmarked property based on saved bookmarks
        event.isBookmarked = _bookmarkedEventIds.contains(event.id.toString());
        return event;
      }).toList();
    });
  }

  List<Event> _getFilteredEvents() {
    if (_selectedCategory == 'All') {
      return _events;
    }
    return _events.where((event) => event.category == _selectedCategory).toList();
  }

  Future<void> _toggleBookmark(Event event) async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? bookmarks = prefs.getStringList('bookmarks') ?? [];

    if (!bookmarks.contains(event.id.toString())) {
      bookmarks.add(event.id.toString());
      await prefs.setStringList('bookmarks', bookmarks);
      setState(() {
        event.isBookmarked = true; // Update the event's bookmark state
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${event.title} bookmarked!')),
      );
    } else {
      bookmarks.remove(event.id.toString());
      await prefs.setStringList('bookmarks', bookmarks);
      setState(() {
        event.isBookmarked = false; // Update the event's bookmark state
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${event.title} removed from bookmarks!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredEvents = _getFilteredEvents();

    return Scaffold(
      appBar: AppBar(
        title: Text('Local Events'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text(
                'Navigation',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              leading: Icon(Icons.bookmark),
              title: Text('Bookmarks'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BookmarksScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsScreen()),
                );
              },
            ),
            // Add more ListTile entries for other screens as needed
          ],
        ),
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
            trailing: EventBookmarkWidget(
              isBookmarked: event.isBookmarked,
              onBookmarkToggle: (isBookmarked) {
                _toggleBookmark(event); // Call toggle bookmark
              },
            ),
            onTap: () {
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
