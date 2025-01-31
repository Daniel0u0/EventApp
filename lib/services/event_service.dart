import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import '../models/event.dart';

class EventService {
  List<Event> _eventsCache = []; // Cache to store events after loading

  // Load all events from the local JSON file
  Future<List<Event>> loadEvents() async {
    if (_eventsCache.isNotEmpty) {
      return _eventsCache; // Return cached events if already loaded
    }

    try {
      final file = await _localFile; // Get the local file
      if (await file.exists()) {
        final data = await file.readAsString(); // Read from the local file
        final List<dynamic> jsonResult = json.decode(data);
        _eventsCache = jsonResult.map((json) => Event.fromJson(json)).toList();
      } else {
        // If the file does not exist, load from the bundled JSON file
        final data = await rootBundle.loadString('lib/data/events.json');
        final List<dynamic> jsonResult = json.decode(data);
        _eventsCache = jsonResult.map((json) => Event.fromJson(json)).toList();
        await _saveEvents(); // Save the initial events to local storage
      }
    } catch (e) {
      print('Error loading events: $e');
      _eventsCache = []; // Initialize with an empty list if loading fails
    }

    return _eventsCache;
  }

  // Method to get the local file path for saving events
  Future<File> get _localFile async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/events.json';
    print('Local file path: $path'); // Debug print
    return File(path);
  }

  // Method to delete an event by its ID
  Future<void> deleteEvent(String id) async {
    await loadEvents(); // Load events to ensure the cache is up-to-date

    // Find the index of the event with the matching ID
    int index = _eventsCache.indexWhere((event) => event.id == id);

    // Check if the index is valid
    if (index != -1) {
      // Remove the event with the matching ID
      _eventsCache.removeAt(index);
      print('Removing event with ID: $id');

      // Save the updated list back to the JSON file
      await _saveEvents();
      print('Event with ID $id deleted successfully and saved to events.json.');
    } else {
      print('Event with ID $id not found.');
    }
  }

  // After saving, you can log the contents of the file
  Future<void> _saveEvents() async {
    try {
      final file = await _localFile; // Ensure this method returns the correct file path
      String jsonString = json.encode(_eventsCache.map((e) => e.toJson()).toList());
      await file.writeAsString(jsonString);
      print('Events saved successfully to events.json.');

      // Log the contents of the file
      String contents = await file.readAsString();
      print('Current contents of events.json: $contents');
    } catch (e) {
      print('Error saving events: $e');
    }
  }

  // New method to get all events
  Future<List<Event>> getEvents() async {
    return await loadEvents(); // Load and return events
  }

  // Retrieve an event by its ID
  Future<Event?> getEventById(String id) async {
    await loadEvents();

    try {
      return _eventsCache.firstWhere((event) => event.id == id); // Compare directly with the string ID
    } catch (e) {
      return null; // Return null if the event is not found
    }
  }

  // Validate event fields
  void _validateEvent(Event event) {
    if (event.title.isEmpty) {
      throw Exception('Event title cannot be empty');
    }
    // Add more validations as needed
  }

  // Add a new event
  Future<void> addEvent(Event newEvent) async {
    _validateEvent(newEvent); // Validate the new event
    await loadEvents(); // Load existing events to ensure we have the latest data

    // Check for unique ID
    if (_eventsCache.any((event) => event.id == newEvent.id)) {
      throw Exception('Event with ID ${newEvent.id} already exists.');
    }

    // Add the new event to the cache
    _eventsCache.add(newEvent);
    await _saveEvents(); // Save the updated list back to the JSON file
  }

  // Update an existing event
  Future<void> updateEvent(String id, Event updatedEvent) async {
    await loadEvents(); // Ensure events are loaded
    int index = _eventsCache.indexWhere((event) => event.id == id);

    // Check if the index is within bounds
    if (index != -1) {
      _validateEvent(updatedEvent);
      _eventsCache[index] = updatedEvent; // Update the event in the cache
      await _saveEvents(); // Save the updated list back to the JSON file
    } else {
      throw Exception('Event not found');
    }
  }
}
