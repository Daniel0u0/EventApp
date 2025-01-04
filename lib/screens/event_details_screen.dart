import 'package:flutter/material.dart';
import '../models/event.dart'; // Import your Event model
import 'ar_navigation_screen.dart'; // Import the AR navigation screen

class EventDetailsScreen extends StatelessWidget {
  final Event event; // Event object passed from the previous screen

  const EventDetailsScreen({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(event.title), // Event title displayed in the app bar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Add consistent padding to the screen
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align items to the start
          children: [
            // Event title
            Text(
              event.title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8), // Add spacing between widgets

            // Event date
            Text(
              "Date: ${event.date}",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),

            // Event location
            Text(
              "Location: ${event.location}",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),

            // Event description
            Text(
              "Description: ${event.description}",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16), // Add larger spacing before buttons

            // Add buttons for AR Navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Space the buttons evenly
              children: [
                // AR Navigation Button
                ElevatedButton(
                  onPressed: () {
                    // Navigate to the AR Navigation screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ARNavigationScreen(
                          location: event.location, // Pass the event location
                        ),
                      ),
                    );
                  },
                  child: Text("AR Navigation"),
                ),

                // Add more buttons here if needed (e.g., Weather Updates)
                ElevatedButton(
                  onPressed: () {
                    // Placeholder for another feature, e.g., Weather Updates
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Weather updates coming soon!")),
                    );
                  },
                  child: Text("Weather Updates"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}