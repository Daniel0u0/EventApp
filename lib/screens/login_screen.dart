import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import User class
import '../services/auth_service.dart'; // Ensure the path is correct
import 'home_screen.dart'; // Import HomeScreen
import 'register_screen.dart'; // Import RegisterScreen

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login() async {
    // Call signIn method and get AuthResult
    AuthResult result = await _authService.signIn(_emailController.text, _passwordController.text);

    if (result.user != null) {
      // Navigate to HomeScreen after successful login
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
    } else {
      // Handle login error
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.errorMessage ?? 'Login failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _emailController, decoration: InputDecoration(labelText: 'Email')),
            TextField(controller: _passwordController, decoration: InputDecoration(labelText: 'Password'), obscureText: true),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _login, child: Text('Login')),
            SizedBox(height: 10), // Add some space between buttons
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterScreen())); // Navigate to RegisterScreen
              },
              child: Text('Register'), // Register button
            ),
          ],
        ),
      ),
    );
  }
}
