import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth for logout
import 'create_event_screen.dart'; // Import the CreateEventScreen
import 'admin_events_screen.dart'; // Import the AdminEventsScreen
import 'admin_settings_screen.dart'; // Import the AdminSettingsScreen
import 'login_screen.dart'; // Import the LoginScreen for logout

class AdminHomeScreen extends StatefulWidget {
  final String email;

  AdminHomeScreen({required this.email});

  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  void _logout() async {
    try {
      await FirebaseAuth.instance.signOut(); // Sign out from Firebase Auth
      // Navigate to the login screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } catch (e) {
      // Handle any errors that occur during logout
      print("Error logging out: $e");
      // Optionally show an error message to the user
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Home'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: Text(
                'Admin Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: Text('Events'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminEventsScreen()), // Navigate to AdminEventsScreen
                );
              },
            ),
            ListTile(
              title: Text('Settings'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminSettingsScreen()), // Navigate to AdminSettingsScreen
                );
              },
            ),
            ListTile(
              title: Text('Logout'),
              onTap: () {
                _logout(); // Call logout method
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView( // Allow scrolling if content exceeds screen height
        child: Center( // Center the content
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Welcome, Admin!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Text(
                  'Logged in as: ${widget.email}',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CreateEventScreen()),
                    );
                  },
                  child: Text('Create New Event'),
                ),
                SizedBox(height: 20), // Add space between buttons
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AdminEventsScreen()), // Navigate to AdminEventsScreen
                    );
                  },
                  child: Text('View Current Events'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
