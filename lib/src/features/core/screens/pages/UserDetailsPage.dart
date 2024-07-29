import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
class UserDetailsPage extends StatelessWidget {
  final String userId;
  final String userName;
  final String userLocation;

  const UserDetailsPage({
    required this.userId,
    required this.userName,
    required this.userLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Details'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('Users').doc(userId).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('User data not found'));
          }

          Map<String, dynamic>? userData = snapshot.data!.data() as Map<String, dynamic>?;

          if (userData == null || !userData.containsKey('Latitude') || !userData.containsKey('Longitude')) {
            return Center(child: Text('User location data not found'));
          }

          double latitude = userData['Latitude'];
          double longitude = userData['Longitude'];

          LatLng location = LatLng(latitude, longitude);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 2,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: location,
                    zoom: 15.0,
                  ),
                  markers: {
                    Marker(
                      markerId: MarkerId('userMarker'),
                      position: location,
                      infoWindow: InfoWindow(title: userName),
                    ),
                  },
                  onMapCreated: (GoogleMapController controller) {
                    // You can manipulate the map here if needed
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}