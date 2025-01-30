import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import '../models/event.dart'; // Ensure you have the Event model accessible
import '../services/event_service.dart'; // Ensure you have the EventService accessible
import '../services/firestore_service.dart'; // Import FirestoreService

class BookmarksScreen extends StatefulWidget {
  @override
  _BookmarksScreenState createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  final EventService _eventService = EventService();
  final FirestoreService _firestoreService = FirestoreService();
  List<Event> _bookmarkedEvents = [];
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser; // Get the currently logged-in user
    _loadBookmarks(); // Load bookmarks from Firestore
  }

  // Load bookmarks from Firestore and retrieve event details
  Future<void> _loadBookmarks() async {
    if (_currentUser != null) {
      // Get the bookmarked event IDs from Firestore
      List<String> bookmarks = await _firestoreService.getBookmarks(_currentUser!.uid);

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
  }

  // Function to remove a bookmark
  Future<void> _removeBookmark(Event event) async {
    if (_currentUser != null) {
      await _firestoreService.removeBookmark(_currentUser!.uid, event.id.toString()); // Remove from Firestore
      setState(() {
        _bookmarkedEvents.remove(event); // Remove from the local list
      });
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
