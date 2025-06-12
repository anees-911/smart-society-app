import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // For Google Maps

class AdminMarketDirectoryDetailsScreen extends StatefulWidget {
  final String marketId;

  AdminMarketDirectoryDetailsScreen({required this.marketId});

  @override
  _AdminMarketDirectoryDetailsScreenState createState() => _AdminMarketDirectoryDetailsScreenState();
}

class _AdminMarketDirectoryDetailsScreenState extends State<AdminMarketDirectoryDetailsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late GoogleMapController _mapController;
  late LatLng _marketLocation;
  String _shopName = '';
  String _contactNumber = '';
  String _address = '';
  String _category = '';

  @override
  void initState() {
    super.initState();
    _fetchMarketDetails();
  }

  // Fetch market details from Firestore
  Future<void> _fetchMarketDetails() async {
    try {
      final marketDoc = await _firestore.collection('market_directory').doc(widget.marketId).get();

      if (marketDoc.exists) {
        setState(() {
          _shopName = marketDoc['name'];
          _contactNumber = marketDoc['contact'];
          _address = marketDoc['address'];
          _category = marketDoc['category'] ?? 'No category';

          // Convert latitude and longitude
          double latitude = double.tryParse(marketDoc['latitude'].toString()) ?? 0.0;
          double longitude = double.tryParse(marketDoc['longitude'].toString()) ?? 0.0;
          _marketLocation = LatLng(latitude, longitude);
        });
      }
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
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Shop Name: $_shopName', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Contact: $_contactNumber', style: TextStyle(fontSize: 16)),
            Text('Address: $_address', style: TextStyle(fontSize: 16)),
            Text('Category: $_category', style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            Container(
              height: 300,
              child: _marketLocation.latitude == 0.0
                  ? Center(child: CircularProgressIndicator())
                  : _buildMap(),
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.green),
                  onPressed: () {
                    // Navigate to edit screen (create this screen)
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _firestore.collection('market_directory').doc(widget.marketId).delete();
                    Navigator.pop(context); // Go back after deletion
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
