class Event {
  final String id; // Firestore document ID
  final String title;
  final String category;
  final String date;
  final String location;
  final String description;
  final double latitude; // Latitude of the event
  final double longitude; // Longitude of the event
  bool isBookmarked;

  Event({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.location,
    required this.description,
    required this.latitude, // Initialize latitude
    required this.longitude, // Initialize longitude
    this.isBookmarked = false,
  });

  // Deserialize from Firestore document
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      date: json['date'] as String,
      location: json['location'] as String,
      description: json['description'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      isBookmarked: json['isBookmarked'] as bool? ?? false,
    );
  }

  // Serialize to Firestore document
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'category': category,
      'date': date,
      'location': location,
      'description': description,
      'latitude': latitude, // Include latitude
      'longitude': longitude, // Include longitude
      'isBookmarked': isBookmarked,
    };
  }
}