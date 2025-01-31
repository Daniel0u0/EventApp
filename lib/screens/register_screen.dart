import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_screen.dart'; // Regular user home screen
import 'admin_home_screen.dart'; // Admin home screen

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passcodeController = TextEditingController(); // Controller for admin passcode

  void _register() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter email and password')));
      return;
    }

    try {
      // Check if the provided passcode is valid for admin registration
      String role = _passcodeController.text.trim() == 'admin1' ? 'admin' : 'user';

      AuthResult result = await _authService.register(
        _emailController.text,
        _passwordController.text,
        role,
      );

      if (result.user != null) {
        if (role == 'admin') {
          // Navigate to AdminHomeScreen if the role is admin
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AdminHomeScreen(email: result.user!.email ?? 'Admin'),
            ),
          );
        } else {
          // Navigate to HomeScreen if the role is user
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        }
      } else {
        // Handle registration error
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.errorMessage ?? 'Registration failed')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registration failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
              controller: _passcodeController,
              decoration: InputDecoration(labelText: 'Admin Passcode (Leave blank for user)'),
              obscureText: true, // Hide the passcode for security
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _register,
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}