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
  String _selectedCategory = "Select Category";  // Default value
  double _latitude = 0.0;
  double _longitude = 0.0;

  bool _isLoading = false;
  bool _isLocationSelected = false;

  // Available categories for the dropdown
  final List<String> _categories = [
    "Select Category",
    "Grocery",
    "Clothing",
    "Electronics",
    "Restaurants",
    "Others"
  ];

  // Function to validate user inputs
  bool _validateInputs() {
    if (_nameController.text.trim().isEmpty || _nameController.text.trim().length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please enter a valid shop name (at least 3 characters)'),
        backgroundColor: Colors.red,
      ));
      return false;
    }
    if (_contactController.text.trim().isEmpty ||
        _contactController.text.trim().length != 11 ||
        !_contactController.text.trim().startsWith("03")) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please enter a valid 11-digit phone number (Pakistan)'),
        backgroundColor: Colors.red,
      ));
      return false;
    }
    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please enter the address'),
        backgroundColor: Colors.red,
      ));
      return false;
    }
    if (_selectedCategory == "Select Category") {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please select a category'),
        backgroundColor: Colors.red,
      ));
      return false;
    }
    if (!_isLocationSelected) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please select a location'),
        backgroundColor: Colors.red,
      ));
      return false;
    }
    return true;
  }

  // Function to save market directory to Firestore
  Future<void> _saveMarketDirectory() async {
    if (!_validateInputs()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _firestore.collection('market_directory').add({
        'name': _nameController.text.trim(),
        'contact': _contactController.text.trim(),
        'address': _addressController.text.trim(),
        'category': _selectedCategory,
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
      setState(() {
        _selectedCategory = "Select Category";  // Reset the category to the default
        _latitude = 0.0;
        _longitude = 0.0;
        _isLocationSelected = false;
      });
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
          height: 600, // Increased height for larger map
          width: double.maxFinite, // Full width of the container
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(34.1688, 73.2215), // Corrected coordinates for Abbottabad
              zoom: 14,
            ),
            onTap: (LatLng location) {
              setState(() {
                _latitude = location.latitude;
                _longitude = location.longitude;
                _isLocationSelected = true;
              });
              Navigator.pop(context, location);
            },
            markers: {
              Marker(
                markerId: MarkerId('selected-location'),
                position: LatLng(_latitude, _longitude),  // Display the pin at the updated location
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
        _isLocationSelected = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Market Directory'),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
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
                keyboardType: TextInputType.phone,
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
              // Category Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
                items: _categories.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
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
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blueAccent,
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
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blueAccent,
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
