import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Custom response class for registration and sign-in
class AuthResult {
  final User? user;
  final String? errorMessage;

  AuthResult({this.user, this.errorMessage});
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Check if the user is logged in
  Future<bool> isUserLoggedIn() async {
    User? user = _auth.currentUser; // Get the current user
    return user != null; // Return true if a user is logged in, false otherwise
  }

  // Get current user ID
  String? getCurrentUserId() {
    return _auth.currentUser?.uid; // Use uid instead of email for better practice
  }

  // Register a new user with email and password
  Future<AuthResult> register(String email, String password, String role) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      // Store the user role in Firestore
      await _firestore.collection('users').doc(result.user!.uid).set({'role': role});
      return AuthResult(user: result.user); // Return the newly created user
    } catch (e) {
      return AuthResult(errorMessage: _handleAuthError(e)); // Return error message if registration fails
    }
  }

  // Sign in with email and password
  Future<AuthResult> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return AuthResult(user: result.user); // Return the user if sign-in is successful
    } catch (e) {
      return AuthResult(errorMessage: _handleAuthError(e)); // Return error message if sign-in fails
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Handle different authentication errors
  String _handleAuthError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No user found for that email.';
        case 'wrong-password':
          return 'Wrong password provided for that user.';
        case 'invalid-email':
          return 'The email address is not valid.';
        case 'user-disabled':
          return 'User has been disabled.';
        default:
          return error.message ?? 'An unknown error occurred';
      }
    }
    return 'An unknown error occurred';
  }

  // Fetch user role
  Future<String?> getUserRole(String uid) async {
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();

    // Cast the data to Map<String, dynamic>
    Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;

    // Check if data is not null before accessing it
    return data?['role'] as String?; // Safely access the 'role'
  }

}
