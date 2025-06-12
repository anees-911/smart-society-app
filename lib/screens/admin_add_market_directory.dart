import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AdminAddMarketDirectoryScreen extends StatefulWidget {
  @override
  _AdminAddMarketDirectoryScreenState createState() =>
      _AdminAddMarketDirectoryScreenState();
}

class _AdminAddMarketDirectoryScreenState
    extends State<AdminAddMarketDirectoryScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  double _latitude = 0.0;
  double _longitude = 0.0;

  bool _isLoading = false;

  // Function to save market directory to Firestore
  Future<void> _saveMarketDirectory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _firestore.collection('market_directory').add({
        'name': _nameController.text.trim(),
        'contact': _contactController.text.trim(),
        'address': _addressController.text.trim(),
        'category': _categoryController.text.trim(),
        'latitude': _latitude,
        'longitude': _longitude,
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Market directory added successfully!'),
        backgroundColor: Colors.green,
      ));

      // Clear text fields
      _nameController.clear();
      _contactController.clear();
      _addressController.clear();
      _categoryController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to add market directory: $e'),
        backgroundColor: Colors.red,
      ));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function to pick location for the market
  Future<void> _pickLocation() async {
    LatLng? pickedLocation = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a Location'),
        content: SizedBox(
          height: 400,
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(37.7749, -122.4194), // Default San Francisco
              zoom: 14,
            ),
            onTap: (LatLng location) {
              setState(() {
                _latitude = location.latitude;
                _longitude = location.longitude;
              });
              Navigator.pop(context, location);
            },
            markers: {
              Marker(
                markerId: MarkerId('selected-location'),
                position: LatLng(_latitude, _longitude),
              ),
            },
          ),
        ),
      ),
    );

    if (pickedLocation != null) {
      setState(() {
        _latitude = pickedLocation.latitude;
        _longitude = pickedLocation.longitude;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Market Directory'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Shop Name',
                  prefixIcon: Icon(Icons.store),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _contactController,
                decoration: const InputDecoration(
                  labelText: 'Contact Number',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickLocation,
                child: Text(
                  _latitude == 0.0 && _longitude == 0.0
                      ? 'Pick Location'
                      : 'Location Selected',
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                ),
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _saveMarketDirectory,
                child: const Text('Save'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
