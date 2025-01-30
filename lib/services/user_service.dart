import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> getUserRole() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot snapshot = await _firestore.collection('users').doc(user.email).get();
      if (snapshot.exists) {
        return snapshot['role'];
      }
    }
    return null; // User not found or role not set
  }
}

void editEvent(String eventId) async {
  String? role = await UserService().getUserRole();
  if (role == 'admin') {
    // Proceed to edit the event
  } else {
    // Show an error message that the user is not authorized
    print('You do not have permission to edit this event.');
  }
}
