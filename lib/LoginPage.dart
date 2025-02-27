import 'package:flutter/material.dart';
import 'package:livebuzz/main.dart';

import 'global.dart';
// Import global variables

class LoginPage extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _login(BuildContext context) {
    String username = usernameController.text.trim();
    String password = passwordController.text.trim();

    if (username == 'admin' && password == 'admin') {
      isAdmin = true;
      isLoggedIn = true; // Mark user as logged in

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Admin Login Successful!')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LiveBuzzHomePage()),
      );
    } else if (username.isNotEmpty && password.isNotEmpty) {
      isAdmin = false;
      isLoggedIn = true; // Mark user as logged in

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User Login Successful!')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LiveBuzzHomePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid Credentials')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
        icon: Icon(Icons.sports_kabaddi, color: Colors.black),
    onPressed: () {},),
        title: Text('Login'),

      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            SizedBox(height: 20),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _login(context);
              },
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
