import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Save a bookmark to Firestore
  Future<void> saveBookmark(String userId, String eventId) async {
    await _db.collection('users').doc(userId).collection('bookmarks').doc(eventId).set({
      'eventId': eventId,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Remove a bookmark from Firestore
  Future<void> removeBookmark(String userId, String eventId) async {
    await _db.collection('users').doc(userId).collection('bookmarks').doc(eventId).delete();
  }

  // Get bookmarks from Firestore
  Future<List<String>> getBookmarks(String userId) async {
    final snapshot = await _db.collection('users').doc(userId).collection('bookmarks').get();
    return snapshot.docs.map((doc) => doc['eventId'] as String).toList();
  }

  // Get bookmarks from Firestore as a stream
  Stream<List<String>> getBookmarksStream(String userId) {
    return _db.collection('users').doc(userId).collection('bookmarks').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc['eventId'] as String).toList();
    });
  }
}
