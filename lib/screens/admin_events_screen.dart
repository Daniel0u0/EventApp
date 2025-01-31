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
  List<Event> _events = [];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      List<Event?> events = await _eventService.getEvents(); // Fetch events from the service
      setState(() {
        // Filter out null events
        _events = events.where((event) => event != null).cast<Event>().toList();
      });
    } catch (e) {
      print('Error loading events: $e');
      // Handle error (e.g., show a message)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load events: $e')),
      );
    }
  }

  Future<void> _deleteEvent(String id, int index) async {
    try {
      await _eventService.deleteEvent(id); // Call the delete method from EventService
      setState(() {
        _events.removeAt(index); // Remove the event from the UI
      });
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _events.isEmpty
            ? Center(child: Text('No events available.'))
            : ListView.builder(
          itemCount: _events.length,
          itemBuilder: (context, index) {
            return EventTile(
              event: _events[index],
              onEdit: () {
                // Navigate to EditEventScreen when the edit button is pressed
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditEventScreen(event: _events[index]),
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
                  await _deleteEvent(_events[index].id, index); // Delete the event if confirmed
                }
              },
            );
          },
        ),
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
