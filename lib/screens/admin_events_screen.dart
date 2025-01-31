import 'package:flutter/material.dart';
import '../services/event_service.dart'; // Import the EventService
import '../models/event.dart'; // Import the Event model
import 'edit_event_screen.dart'; // Import the EditEventScreen

class AdminEventsScreen extends StatefulWidget {
  @override
  _AdminEventsScreenState createState() => _AdminEventsScreenState();
}

class _AdminEventsScreenState extends State<AdminEventsScreen> {
  final EventService _eventService = EventService();
  late Stream<List<Event>> _eventsStream; // Use a stream for real-time updates

  @override
  void initState() {
    super.initState();
    // Set the events stream to listen for real-time updates from Firestore
    _eventsStream = _eventService.getEventsStream();
  }

  Future<void> _deleteEvent(String id) async {
    try {
      await _eventService.deleteEvent(id); // Call the delete method from EventService
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Event deleted successfully.')),
      );
    } catch (e) {
      print('Error deleting event: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete event: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Current Events'),
      ),
      body: StreamBuilder<List<Event>>(
        stream: _eventsStream, // Listen to the real-time events stream
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to load events: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No events available.'));
          }

          final events = snapshot.data!; // Extract events from the stream
          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              return EventTile(
                event: events[index],
                onEdit: () {
                  // Navigate to EditEventScreen when the edit button is pressed
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditEventScreen(event: events[index]),
                    ),
                  );
                },
                onDelete: () async {
                  // Confirm deletion
                  bool confirm = await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Delete Event'),
                      content: Text('Are you sure you want to delete this event?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: Text('Delete'),
                        ),
                      ],
                    ),
                  );

                  if (confirm) {
                    await _deleteEvent(events[index].id); // Delete the event if confirmed
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}

// EventTile widget
class EventTile extends StatelessWidget {
  final Event event;
  final VoidCallback onEdit; // Callback for edit action
  final VoidCallback onDelete;

  const EventTile({
    Key? key,
    required this.event,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(event.title),
      subtitle: Text(event.date), // Assuming event.date is a String
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: onEdit, // Call the edit callback
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}