import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/profile_image.png'), // Replace with your image path
            ),
            SizedBox(height: 20),
            Text(
              'John Doe', // Replace with user's name
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Software Developer', // Replace with user's occupation
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 20),
            // You can add more user profile details or options here
          ],
        ),
      ),
    );
  }
}
