import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/event_service.dart';

class CreateEventScreen extends StatefulWidget {
  @override
  _CreateEventScreenState createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final EventService _eventService = EventService();

  String? _title;
  String? _category;
  String? _date;
  String? _location;
  String? _description;

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      Event newEvent = Event(
        id: '', // ID will be generated in EventService
        title: _title!,
        category: _category!,
        date: _date!,
        location: _location!,
        description: _description!,
      );

      await _eventService.addEvent(newEvent);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Event created successfully!')),
      );

      // Optionally, navigate back or clear the form
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                onSaved: (value) => _title = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Category'),
                onSaved: (value) => _category = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a date';
                  }
                  return null;
                },
                onSaved: (value) => _date = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Location'),
                onSaved: (value) => _location = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                onSaved: (value) => _description = value,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Create Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
