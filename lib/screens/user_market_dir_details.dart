import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserMarketDirectoryDetailsScreen extends StatefulWidget {
  final String marketId;

  UserMarketDirectoryDetailsScreen({required this.marketId});

  @override
  _UserMarketDirectoryDetailsScreenState createState() =>
      _UserMarketDirectoryDetailsScreenState();
}

class _UserMarketDirectoryDetailsScreenState
    extends State<UserMarketDirectoryDetailsScreen> {
  late GoogleMapController _mapController;
  late LatLng _marketLocation;
  String _shopName = '';
  String _contactNumber = '';
  String _shopDescription = '';

  @override
  void initState() {
    super.initState();
    _fetchMarketDetails();
  }

  Future<void> _fetchMarketDetails() async {
    try {
      setState(() {
        // Hardcoded test values for shop details
        _shopName = "Electrician Shop";
        _contactNumber = "+1 234 567 890";
        _shopDescription = "Abbottabad Pakistan";

        // Hardcoded location coordinates (San Francisco)
        double latitude = 37.7749; // San Francisco latitude
        double longitude = -122.4194; // San Francisco longitude

        _marketLocation = LatLng(latitude, longitude);
      });
    } catch (e) {
      print("Error fetching market details: $e");
    }
  }

  // Build the Google Map widget
  Widget _buildMap() {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: _marketLocation,
        zoom: 14.0,
      ),
      markers: {
        Marker(
          markerId: MarkerId(widget.marketId),
          position: _marketLocation,
          infoWindow: InfoWindow(title: _shopName),
        ),
      },
      onMapCreated: (GoogleMapController controller) {
        _mapController = controller;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_shopName),
        backgroundColor: Colors.green,
          centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Market info
            Text(
              'Shop Name: $_shopName',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Contact: $_contactNumber',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Description: $_shopDescription',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            // Map display
            Container(
              height: 300,
              child: _marketLocation.latitude == 0.0
                  ? Center(child: CircularProgressIndicator())
                  : _buildMap(),
            ),
          ],
        ),
      ),
    );
  }
}
