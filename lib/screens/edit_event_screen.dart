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
  late double _latitude;
  late double _longitude;

  @override
  void initState() {
    super.initState();
    // Initialize form fields with the current event data
    _title = widget.event.title;
    _category = widget.event.category;
    _date = widget.event.date;
    _location = widget.event.location;
    _description = widget.event.description;
    _latitude = widget.event.latitude;
    _longitude = widget.event.longitude;
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
        latitude: _latitude,
        longitude: _longitude,
        isBookmarked: widget.event.isBookmarked,
      );

      try {
        await _eventService.updateEvent(widget.event.id, updatedEvent);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Event updated successfully!')),
        );

        Navigator.pop(context, updatedEvent); // Return updated event
      } catch (e) {
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
          child: SingleChildScrollView(
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
                TextFormField(
                  initialValue: _latitude.toString(),
                  decoration: InputDecoration(labelText: 'Latitude'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a latitude';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Latitude must be a number';
                    }
                    return null;
                  },
                  onSaved: (value) => _latitude = double.parse(value!),
                ),
                TextFormField(
                  initialValue: _longitude.toString(),
                  decoration: InputDecoration(labelText: 'Longitude'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a longitude';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Longitude must be a number';
                    }
                    return null;
                  },
                  onSaved: (value) => _longitude = double.parse(value!),
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
      ),
    );
  }
}