import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class PropertyDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> property;

  const PropertyDetailsScreen({required this.property, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<dynamic> images = property['images'] ?? [];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(property['name']),
        centerTitle: true,

      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Carousel Slider for Images with Tap Gesture for Full-Screen View
              if (images.isNotEmpty)
                CarouselSlider(
                  options: CarouselOptions(
                    height: 250.0,
                    enlargeCenterPage: true,
                    autoPlay: true,
                    aspectRatio: 16 / 9,
                    viewportFraction: 0.8,
                  ),
                  items: images.map((imageUrl) {
                    return GestureDetector(
                      onTap: () => _viewImageFullScreen(context, imageUrl),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          image: DecorationImage(
                            image: NetworkImage(imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 20),
              // Property Details
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Property Name
                      Text(
                        property['name'],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Price
                      Row(
                        children: [
                          const Icon(Icons.money_rounded, color: Colors.green),
                          Text(
                            'Rs ${property['price']} / month',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Address
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.blue),
                          Expanded(
                            child: Text(
                              property['address'],
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Rooms
                      Row(
                        children: [
                          const Icon(Icons.bed, color: Colors.orange),
                          Text(
                            'Rooms: ${property['rooms']}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Description
              Text(
                property['description'],
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),
              // Rent Now Button with Gradient
              Center(
                  child: ElevatedButton(
                    onPressed: () {
                      _rentProperty(context, property);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      backgroundColor: Colors.green, // Changed 'primary' to 'backgroundColor'
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 5,
                      shadowColor: Colors.blue.withOpacity(0.5),
                    ),
                    child: const Text(
                      'Rent Now',
                      style: TextStyle(fontSize: 18),

                    ),
                  )

              ),
            ],
          ),
        ),
      ),
    );
  }

  // Method to Show Full-Screen Image
  void _viewImageFullScreen(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => GestureDetector(
        onTap: () => Navigator.pop(context), // Close dialog on tap
        child: Dialog(
          backgroundColor: Colors.black,
          insetPadding: EdgeInsets.zero,
          child: InteractiveViewer(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _rentProperty(BuildContext context, Map<String, dynamic> property) {
    // Placeholder functionality for "Rent Now" action
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rent Property'),
        content: Text(
          'Are you sure you want to rent "${property['name']}" for Rs ${property['price']} per month?',
        ),
        actions: [
          TextButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.green), // Green background
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white), // White text color
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Property "${property['name']}" has been reserved for rent!'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green, // Green button
            ),
            child: const Text(
              'Confirm',
              style: TextStyle(color: Colors.white), // White text color
            ),
          ),
        ],
      ),

    );
  }
}