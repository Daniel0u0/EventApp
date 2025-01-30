import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'admin_home_screen.dart'; // Import your AdminHomeScreen

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService authService = AuthService();
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                AuthResult result = await authService.signIn(
                  emailController.text,
                  passwordController.text,
                );
                if (result.user != null) {
                  // Check if the user is the admin
                  if (result.user!.email == 'admin@gmail.com') {
                    // Navigate to AdminHomeScreen
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminHomeScreen(email: result.user!.email!),
                      ),
                    );
                  } else {
                    // Navigate to HomeScreen for regular users
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                    );
                  }
                } else {
                  // Show error message
                  setState(() {
                    errorMessage = result.errorMessage;
                  });
                }
              },
              child: Text('Login'),
            ),
            if (errorMessage != null) ...[
              SizedBox(height: 20),
              Text(
                errorMessage!,
                style: TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
