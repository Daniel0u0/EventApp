import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/event_service.dart';

class EditEventScreen extends StatefulWidget {
  final Event event;

  const EditEventScreen({
    Key? key,
    required this.event,
  }) : super(key: key);

  @override
  _EditEventScreenState createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final EventService _eventService = EventService();

  late String _title;
  late String _category;
  late String _date;
  late String _location;
  late String _description;

  @override
  void initState() {
    super.initState();
    // Initialize form fields with the current event data
    _title = widget.event.title;
    _category = widget.event.category;
    _date = widget.event.date;
    _location = widget.event.location;
    _description = widget.event.description;
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      Event updatedEvent = Event(
        id: widget.event.id,
        title: _title,
        category: _category,
        date: _date,
        location: _location,
        description: _description,
        isBookmarked: widget.event.isBookmarked,
      );

      try {
        print('Updating event: $updatedEvent'); // Debugging output
        await _eventService.updateEvent(widget.event.id, updatedEvent);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Event updated successfully!')),
        );

        Navigator.pop(context, updatedEvent); // Return updated event
      } catch (e) {
        print('Error updating event: $e'); // Print error to console
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating event: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                initialValue: _title,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                onSaved: (value) => _title = value!,
              ),
              TextFormField(
                initialValue: _category,
                decoration: InputDecoration(labelText: 'Category'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a category';
                  }
                  return null;
                },
                onSaved: (value) => _category = value!,
              ),
              TextFormField(
                initialValue: _date,
                decoration: InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a date';
                  }
                  return null;
                },
                onSaved: (value) => _date = value!,
              ),
              TextFormField(
                initialValue: _location,
                decoration: InputDecoration(labelText: 'Location'),
                onSaved: (value) => _location = value!,
              ),
              TextFormField(
                initialValue: _description,
                decoration: InputDecoration(labelText: 'Description'),
                onSaved: (value) => _description = value!,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
