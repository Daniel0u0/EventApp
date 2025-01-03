import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/event.dart';

class EventService {
  Future<List<Event>> loadEvents() async {
    final data = await rootBundle.loadString('lib/data/events.json');
    final List<dynamic> jsonResult = json.decode(data);
    return jsonResult.map((json) => Event.fromJson(json)).toList();
  }
}