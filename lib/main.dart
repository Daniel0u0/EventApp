import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart'; // Import your LoginScreen
import 'package:firebase_core/firebase_core.dart';
import 'services/auth_service.dart'; // Import your AuthService

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
      home: FutureBuilder(
        future: _checkUserSession(),
        builder: (context, snapshot) {
          // Check the connection state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // Show loading indicator while checking
          }
          if (snapshot.hasData && snapshot.data == true) {
            return HomeScreen(); // User is logged in
          } else {
            return LoginScreen(); // User is not logged in
          }
        },
      ),
    );
  }

  Future<bool> _checkUserSession() async {
    AuthService authService = AuthService();
    return await authService.isUserLoggedIn(); // Check if the user is logged in
  }
}
