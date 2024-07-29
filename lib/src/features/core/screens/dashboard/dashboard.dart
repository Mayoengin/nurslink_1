  import 'package:firebase_core/firebase_core.dart';
  import 'package:flutter/material.dart';
  import 'package:login_flutter_app/src/features/core/screens/pages/home_page.dart';
  import 'package:login_flutter_app/src/features/core/screens/pages/appointments_page.dart';
  import 'package:login_flutter_app/src/features/core/screens/pages/profile_page.dart';
  import 'package:login_flutter_app/src/features/core/screens/pages/location_page.dart';
  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:login_flutter_app/src/features/authentication/screens/login/login_screen.dart';
  import 'package:geolocator/geolocator.dart'; // Import Geolocator
  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'dart:async';

  import 'package:firebase_database/firebase_database.dart';

  class Dashboard extends StatefulWidget {
    final String userName;
    final String userLocation;

    const Dashboard({
      Key? key,
      required this.userName,   required this.userLocation,
    }) : super(key: key);

    @override
    _DashboardState createState() => _DashboardState();
  }


  class _DashboardState extends State<Dashboard> {
    late Timer _timer;
    late DatabaseReference _databaseReference;
    late String userEmail; // Define userEmail as a class variable

    @override
    void initState() {
      super.initState();
      // Other initialization code remains the same

      // Fetch the user's email and assign it to the class variable userEmail
      User? user = FirebaseAuth.instance.currentUser;
      userEmail = user?.email ?? 'user@example.com';

      // Set up a timer to update location every 10 seconds
      _timer = Timer.periodic(Duration(seconds: 30), (Timer t) {
        _sendUserLocationToFirebase(userEmail);
      });
    }


    @override
    void dispose() {
      _timer.cancel(); // Cancel the timer when the widget is disposed
      super.dispose();
    }

    @override
    Widget build(BuildContext context) {
      User? user = FirebaseAuth.instance.currentUser;

      String userName = user?.displayName ?? 'User';
      String userEmail = user?.email ?? 'user@example.com';

      bool shouldShowLocations = false;

      // Check if the user's email domain grants access to the location page
      if (user != null && user.email != null) {
        String email = user.email!;
        if (email.endsWith('agmajd3@gmail.com')) {
          shouldShowLocations = true;
        }
      }

      return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text('Dashboard'),
          ),
          drawer: Drawer(
            child: ListView(
              children: [
                UserAccountsDrawerHeader(
                  accountName: Text(
                    userName,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  accountEmail: Text(
                    userEmail,
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.home),
                  title: Text('Home'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.verified_user),
                  title: Text('Profile'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfilePage()),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.shopping_bag),
                  title: Text('Appointments'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AppointmentPage()),
                    );
                  },
                ),
                if (shouldShowLocations)
                  ListTile(
                    leading: Icon(Icons.location_on),
                    title: Text('Locations'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              LocationPage(
                              ),
                        ),
                      );
                    },
                  ),
                ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Logout'),
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                          (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }Future<void> _sendUserLocationToFirebase(String userEmail) async {
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
        );

        print('Fetched user position: $position');

        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .where('Email', isEqualTo: userEmail) // Change 'Email' to match the field name in your Firestore
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          DocumentSnapshot userDocument = querySnapshot.docs.first;

          // Print user document data for inspection
          print('User document found: ${userDocument.data()}');

          await userDocument.reference.set({
            'UserName': widget.userName,
            'Latitude': position.latitude,
            'Longitude': position.longitude,
            'timestamp': DateTime.now().toString(),
          }, SetOptions(merge: true));

          print('User location updated in Firestore');
        } else {
          print('User with email $userEmail not found');
        }
      } catch (e) {
        print('Error updating user location in Firestore: $e');
      }
    }


  }