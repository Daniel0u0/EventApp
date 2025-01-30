import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import User class
import '../services/auth_service.dart'; // Ensure the path is correct
import 'home_screen.dart'; // Import HomeScreen

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _roleController = TextEditingController(); // Add a controller for role input

  void _register() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty || _roleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter email, password, and role')));
      return;
    }

    // Call the register method and get AuthResult
    AuthResult result = await _authService.register(
      _emailController.text,
      _passwordController.text,
      _roleController.text, // Pass the role to the register method
    );

    if (result.user != null) {
      // Registration successful, navigate to HomeScreen
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
    } else {
      // Handle registration error
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.errorMessage ?? 'Registration failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextField(
              controller: _roleController, // Add a text field for the user role
              decoration: InputDecoration(labelText: 'Role (e.g., admin or user)'),
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _register, child: Text('Register')),
          ],
        ),
      ),
    );
  }
}
