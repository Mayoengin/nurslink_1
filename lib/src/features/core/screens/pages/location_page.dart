import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'UserDetailsPage.dart';
import 'SeeAllLocationsPage.dart'; // Import the page to see all locations

class LocationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Location Page'),
        actions: [
          IconButton(
            icon: Icon(Icons.people),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SeeAllLocationsPage(), // Navigate to the page to see all locations
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              final data = document.data() as Map<String, dynamic>;
              final userId = document.id; // Extract userId from document
              final userName = data['UserName'];
              final userLocation = data['Latitude'].toString() + ',' + data['Longitude'].toString();

              return UserExpansionTile(
                userId: userId, // Pass userId to UserExpansionTile
                userName: userName,
                userLocation: userLocation,
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class UserExpansionTile extends StatelessWidget {
  final String userId;
  final String userName;
  final String userLocation;

  const UserExpansionTile({
    required this.userId,
    required this.userName,
    required this.userLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserDetailsPage(
                userId: userId,
                userName: userName,
                userLocation: userLocation,
              ),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                userName,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Icon(Icons.location_on), // Add location icon
                  SizedBox(width: 4), // Add some spacing between text and icon
                  Text(
                    'Location',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
