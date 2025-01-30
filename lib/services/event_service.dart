import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/event.dart';

class EventService {
  List<Event>? _eventsCache; // Cache to store events after loading

  // Load all events from JSON file
  Future<List<Event>> loadEvents() async {
    if (_eventsCache != null) {
      return _eventsCache!; // Return cached events if already loaded
    }

    final data = await rootBundle.loadString('lib/data/events.json');
    final List<dynamic> jsonResult = json.decode(data);
    _eventsCache = jsonResult.map((json) => Event.fromJson(json)).toList();
    return _eventsCache!;
  }

  // New method to get all events
  Future<List<Event>> getEvents() async {
    return await loadEvents(); // Load and return events
  }

  // Retrieve an event by its ID
  Future<Event?> getEventById(String id) async {
    // Load events if they are not already cached
    await loadEvents();

    // Use firstWhere and provide a default value or handle the absence of the event
    try {
      return _eventsCache!.firstWhere((event) => event.id.toString() == id);
    } catch (e) {
      return null; // Return null if the event is not found
    }
  }

  // Add a new event
  Future<void> addEvent(Event newEvent) async {
    await loadEvents(); // Ensure events are loaded

    // Add the new event to the cache
    _eventsCache?.add(newEvent);

    // Here you would normally also save the updated list back to the JSON file or database
    // For example, if using a database, you would call a method to save the new event.
    // If using a JSON file, you would need to write back to the file
  }

  // Update an existing event
  Future<void> updateEvent(String id, Event updatedEvent) async {
    await loadEvents(); // Ensure events are loaded

    // Find the index of the event to update
    int index = _eventsCache!.indexWhere((event) => event.id.toString() == id);
    if (index != -1) {
      // Update the event in the cache
      _eventsCache![index] = updatedEvent;

      // Here you would normally also save the updated list back to the JSON file or database
      // For example, if using a database, you would call a method to save the updated event.
      // If using a JSON file, you would need to write back to the file
    } else {
      throw Exception('Event not found'); // Handle the case where the event is not found
    }
  }
}
