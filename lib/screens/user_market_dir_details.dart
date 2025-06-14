import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserMarketDirectoryDetailsScreen extends StatefulWidget {
  final String marketId;

  const UserMarketDirectoryDetailsScreen({required this.marketId});

  @override
  _UserMarketDirectoryDetailsScreenState createState() =>
      _UserMarketDirectoryDetailsScreenState();
}

class _UserMarketDirectoryDetailsScreenState
    extends State<UserMarketDirectoryDetailsScreen> {
  GoogleMapController? _mapController;
  LatLng? _marketLocation;

  String _shopName = 'Loading...';
  String _contactNumber = 'N/A';
  String _shopCategory = 'Uncategorized';
  String _shopAddress = 'No address available';

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMarketDetails();
  }

  // Fetch market details from Firestore
  Future<void> _fetchMarketDetails() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('market_directory')
          .doc(widget.marketId)
          .get();

      if (doc.exists) {
        final data = doc.data() ?? {};

        setState(() {
          _shopName = data['name']?.toString() ?? 'Unknown Shop';
          _contactNumber = data['contact']?.toString() ?? 'N/A';
          _shopCategory = data['category']?.toString() ?? 'Uncategorized';
          _shopAddress = data['address']?.toString() ?? 'No address available';

          // Handle missing latitude and longitude by setting fallback values
          double latitude = (data['latitude'] != null)
              ? data['latitude'] as double
              : 0.0;
          double longitude = (data['longitude'] != null)
              ? data['longitude'] as double
              : 0.0;

          _marketLocation = LatLng(latitude, longitude);  // Set location
          _isLoading = false;  // Data fetched, stop loading
        });
      } else {
        setState(() {
          _shopName = 'Not Found';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _shopAddress = 'Failed to fetch market details.';
      });
      print("Error: $e");
    }
  }

  // Build the Google Map widget
  Widget _buildMap() {
    if (_marketLocation == null) {
      return const Center(child: Text("Market location not available"));
    }

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: _marketLocation!,
        zoom: 14.0,
      ),
      markers: {
        Marker(
          markerId: MarkerId(widget.marketId),
          position: _marketLocation!,
          infoWindow: InfoWindow(title: _shopName),
        ),
      },
      onMapCreated: (controller) {
        _mapController = controller;
      },
      zoomControlsEnabled: true,  // Enable zoom controls for better interaction
      compassEnabled: true,       // Enable compass for better map orientation
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Loading state
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shop Information
            Text(
              'Shop Name: $_shopName',
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Category: $_shopCategory',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Contact: $_contactNumber',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Address: $_shopAddress',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),

            // Map Display
            Container(
              height: 300,
              width: double.infinity,
              child: _buildMap(),
            ),
          ],
        ),
      ),
    );
  }
}
