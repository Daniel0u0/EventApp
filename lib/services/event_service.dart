import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'events'; // Firestore collection name

  // Cache for events (optional, for performance improvement)
  List<Event> _eventsCache = [];

  // Fetch all events from Firestore
  Future<List<Event>> loadEvents() async {
    if (_eventsCache.isNotEmpty) {
      return _eventsCache; // Return cached events if already loaded
    }

    try {
      final querySnapshot = await _firestore.collection(collectionName).get();
      _eventsCache = querySnapshot.docs
          .map((doc) => Event.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      print('Error loading events from Firestore: $e');
      _eventsCache = [];
    }

    return _eventsCache;
  }

  // Add a new event to Firestore
  Future<void> addEvent(Event newEvent) async {
    try {
      // Add the event to Firestore
      await _firestore.collection(collectionName).add(newEvent.toJson());
      print('Event added successfully: ${newEvent.title}');
      _eventsCache.clear(); // Clear the cache to force reload
    } catch (e) {
      print('Error adding event to Firestore: $e');
    }
  }

  // Update an existing event in Firestore
  Future<void> updateEvent(String id, Event updatedEvent) async {
    try {
      // Update the event in Firestore
      await _firestore.collection(collectionName).doc(id).update(updatedEvent.toJson());
      print('Event updated successfully: ${updatedEvent.title}');
      _eventsCache.clear(); // Clear the cache to force reload
    } catch (e) {
      print('Error updating event in Firestore: $e');
    }
  }

  // Delete an event from Firestore
  Future<void> deleteEvent(String id) async {
    try {
      // Delete the event from Firestore
      await _firestore.collection(collectionName).doc(id).delete();
      print('Event deleted successfully: $id');
      _eventsCache.clear(); // Clear the cache to force reload
    } catch (e) {
      print('Error deleting event from Firestore: $e');
    }
  }

  // Get an event by its ID
  Future<Event?> getEventById(String id) async {
    try {
      final docSnapshot = await _firestore.collection(collectionName).doc(id).get();
      if (docSnapshot.exists) {
        return Event.fromJson({...docSnapshot.data()!, 'id': docSnapshot.id});
      }
      return null;
    } catch (e) {
      print('Error fetching event by ID from Firestore: $e');
      return null;
    }
  }

  // Get a real-time stream of events (for real-time updates)
  Stream<List<Event>> getEventsStream() {
    return _firestore.collection(collectionName).snapshots().map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        return Event.fromJson({...doc.data(), 'id': doc.id});
      }).toList();
    });
  }
}