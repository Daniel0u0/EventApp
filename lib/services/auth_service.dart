import 'package:firebase_auth/firebase_auth.dart';

// Custom response class for registration and sign-in
class AuthResult {
  final User? user;
  final String? errorMessage;

  AuthResult({this.user, this.errorMessage});
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Check if the user is logged in
  Future<bool> isUserLoggedIn() async {
    User? user = _auth.currentUser; // Get the current user
    return user != null; // Return true if a user is logged in, false otherwise
  }

  // Register a new user with email and password
  Future<AuthResult> register(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
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
      print('Sign-in error: $e'); // Log the error for debugging
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
}
