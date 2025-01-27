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
}
