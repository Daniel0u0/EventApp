import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import '../models/event.dart';
import '../services/event_service.dart';
import '../services/firestore_service.dart';
import 'bookmarks_screen.dart'; // Import the BookmarksScreen
import '../widgets/BookmarkWidget.dart'; // Import the EventBookmarkWidget
import 'setting_screen.dart';
import 'login_screen.dart'; // Import the LoginScreen

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final EventService _eventService = EventService();
  final FirestoreService _firestoreService = FirestoreService();
  List<Event> _events = [];
  List<String> _bookmarkedEventIds = [];
  String _selectedCategory = '';
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser; // Get the currently logged-in user
    _loadBookmarks(); // Load bookmarks first
    _loadEvents(); // Then load events
  }

  Future<void> _loadBookmarks() async {
    if (_currentUser != null) {
      // Get bookmarks for the current user from Firestore
      List<String> firestoreBookmarks = await _firestoreService.getBookmarks(_currentUser!.uid);
      setState(() {
        _bookmarkedEventIds = firestoreBookmarks;
      });
    }
  }

  Future<void> _loadEvents() async {
    final events = await _eventService.loadEvents();
    setState(() {
      _events = events.map((event) {
        event.isBookmarked = _bookmarkedEventIds.contains(event.id.toString());
        return event;
      }).toList();
    });
  }

  Future<void> _toggleBookmark(Event event) async {
    if (_currentUser != null) {
      if (!event.isBookmarked) {
        await _firestoreService.saveBookmark(_currentUser!.uid, event.id.toString()); // Save to Firestore
        setState(() {
          event.isBookmarked = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${event.title} bookmarked!')),
        );
      } else {
        await _firestoreService.removeBookmark(_currentUser!.uid, event.id.toString()); // Remove from Firestore
        setState(() {
          event.isBookmarked = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${event.title} removed from bookmarks!')),
        );
      }
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut(); // Sign out from Firebase
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()), // Navigate to LoginScreen
    );
  }

  List<Event> _getFilteredEvents() {
    // Implement your filtering logic based on _selectedCategory
    // For now, return all events
    return _events; // You can add filtering logic here if needed
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
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: _logout, // Call the logout function
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
