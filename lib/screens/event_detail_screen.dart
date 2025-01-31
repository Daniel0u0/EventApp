import 'package:flutter/material.dart';
import '../models/event.dart';
import '../widgets/BookmarkWidget.dart'; // Import the EventBookmarkWidget
import 'map_screen.dart'; // Import the MapScreen

class EventDetailScreen extends StatelessWidget {
  final Event event;
  final Function(bool) onBookmarkToggle;

  const EventDetailScreen({
    Key? key,
    required this.event,
    required this.onBookmarkToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(event.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.description,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'Location: ${event.location}',
              style: TextStyle(fontSize: 14),
            ),
            Text(
              'Date: ${event.date}',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 20),
            EventBookmarkWidget(
              isBookmarked: event.isBookmarked,
              onBookmarkToggle: onBookmarkToggle, // Call the callback to update the bookmark state
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapScreen(location: event.location),
                  ),
                );
              },
              child: Text('View on Map'),
            ),
          ],
        ),
      ),
    );
  }
}
