import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:geocoding/geocoding.dart'; // Import geocoding package
import '../models/event.dart';
import '../services/event_service.dart';

class CreateEventScreen extends StatefulWidget {
  @override
  _CreateEventScreenState createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final EventService _eventService = EventService();
  final Uuid uuid = Uuid();

  String? _title;
  String? _category;
  String? _date;
  String? _location;
  String? _description;
  double? _latitude;
  double? _longitude;

  bool _isLoadingCoordinates = false;

  // Fetch latitude and longitude for the given location
  Future<void> _fetchCoordinates(String location) async {
    setState(() {
      _isLoadingCoordinates = true;
    });

    try {
      List<Location> locations = await locationFromAddress(location);
      if (locations.isNotEmpty) {
        setState(() {
          _latitude = locations.first.latitude;
          _longitude = locations.first.longitude;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching coordinates: $e')),
      );
    }

    setState(() {
      _isLoadingCoordinates = false;
    });
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Ensure latitude and longitude are filled
      if (_latitude == null || _longitude == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please provide a valid location')),
        );
        return;
      }

      Event newEvent = Event(
        id: uuid.v4(), // Generate a unique ID
        title: _title!,
        category: _category!,
        date: _date!,
        location: _location!,
        description: _description!,
        latitude: _latitude!,
        longitude: _longitude!,
      );

      try {
        await _eventService.addEvent(newEvent);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Event created successfully!')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating event: $e')),
        );
      }
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
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'Title'),
                  validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
                  onSaved: (value) => _title = value,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Category'),
                  onSaved: (value) => _category = value,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
                  validator: (value) => value!.isEmpty ? 'Please enter a date' : null,
                  onSaved: (value) => _date = value,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Location'),
                  validator: (value) => value!.isEmpty ? 'Please enter a location' : null,
                  onChanged: (value) {
                    _location = value;

                    // Fetch coordinates when the location changes
                    if (value.isNotEmpty) {
                      _fetchCoordinates(value);
                    }
                  },
                  onSaved: (value) => _location = value,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Description'),
                  onSaved: (value) => _description = value,
                ),
                SizedBox(height: 20),
                _isLoadingCoordinates
                    ? CircularProgressIndicator()
                    : Column(
                  children: [
                    Text(
                      'Latitude: ${_latitude?.toStringAsFixed(6) ?? 'N/A'}',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Longitude: ${_longitude?.toStringAsFixed(6) ?? 'N/A'}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
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
      ),
    );
  }
}