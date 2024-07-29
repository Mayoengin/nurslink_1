import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SeeAllLocationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All User Locations'),
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

          List<Marker> markers = [];

          snapshot.data!.docs.forEach((DocumentSnapshot document) {
            final data = document.data() as Map<String, dynamic>;
            final userName = data['UserName'];
            final latitude = data['Latitude'];
            final longitude = data['Longitude'];

            LatLng location = LatLng(latitude, longitude);

            Marker marker = Marker(
              markerId: MarkerId(userName),
              position: location,
              infoWindow: InfoWindow(title: userName),
            );

            markers.add(marker);
          });

          return GoogleMap(
            initialCameraPosition: CameraPosition(
              target: markers.isNotEmpty ? markers.first.position : LatLng(0, 0),
              zoom: 5.0,
            ),
            markers: Set<Marker>.from(markers),
            onMapCreated: (GoogleMapController controller) {
              // You can manipulate the map here if needed
            },
          );
        },
      ),
    );
  }
}
