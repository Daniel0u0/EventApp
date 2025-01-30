import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart'; // Import your LoginScreen
import 'screens/admin_home_screen.dart'; // Import your AdminHomeScreen
import 'package:firebase_core/firebase_core.dart';
import 'services/auth_service.dart'; // Import your AuthService
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Local Events',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasData) {
              String email = snapshot.data!.email ?? ''; // Get the user's email
              return FutureBuilder<String?>(
                future: AuthService().getUserRole(snapshot.data!.uid), // Fetch user role
                builder: (context, roleSnapshot) {
                  if (roleSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (roleSnapshot.hasData) {
                    if (roleSnapshot.data == 'admin') {
                      return AdminHomeScreen(email: email); // Pass email to AdminHomeScreen
                    } else {
                      return HomeScreen(); // Regular user screen
                    }
                  } else {
                    return HomeScreen(); // Default screen if no role found
                  }
                },
              );
            } else {
              return LoginScreen(); // User is not logged in
            }
          },
        )
    );
  }
}
