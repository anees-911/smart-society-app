import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ListPropertyScreen extends StatefulWidget {
  const ListPropertyScreen({Key? key}) : super(key: key);

  @override
  State<ListPropertyScreen> createState() => _ListPropertyScreenState();
}

class _ListPropertyScreenState extends State<ListPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _priceController = TextEditingController();
  final _roomsController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isSubmitting = false;
  List<File> _selectedImages = [];

  final ImagePicker _picker = ImagePicker();

  // Pick an image from camera or gallery
  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 70);
    if (picked != null) {
      setState(() {
        _selectedImages.add(File(picked.path));
      });
    }
  }

  // Upload images to Firebase Storage and return their download URLs
  Future<List<String>> _uploadImages() async {
    List<String> downloadUrls = [];
    for (File image in _selectedImages) {
      final ref = FirebaseStorage.instance
          .ref('property_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putFile(image);
      String url = await ref.getDownloadURL();
      downloadUrls.add(url);
    }
    return downloadUrls;
  }

  // Submit the property data to Firestore
  Future<void> _submitProperty() async {
    if (!_formKey.currentState!.validate() || _selectedImages.isEmpty) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final imageUrls = await _uploadImages();

      await FirebaseFirestore.instance.collection('properties').add({
        'name': _nameController.text.trim(),
        'address': _addressController.text.trim(),
        'price': _priceController.text.trim(),
        'rooms': _roomsController.text.trim(),
        'description': _descriptionController.text.trim(),
        'images': imageUrls,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Property listed successfully')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to list property: $e')),
      );
    }

    setState(() {
      _isSubmitting = false;
    });
  }

  // Image picker widget
  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _selectedImages.map((img) {
            return Stack(
              children: [
                Image.file(img, width: 100, height: 100, fit: BoxFit.cover),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () {
                      setState(() => _selectedImages.remove(img));
                    },
                  ),
                ),
              ],
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.camera),
              icon: const Icon(Icons.camera_alt, color: Colors.white), // White icon color
              label: const Text('Camera', style: TextStyle(color: Colors.white)), // White text color
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700, // Green background
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),

            const SizedBox(width: 10),
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery),
              icon: const Icon(Icons.photo_library, color: Colors.white), // White icon color
              label: const Text('Gallery', style: TextStyle(color: Colors.white)), // White text color
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700, // Green background
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),

          ],
        ),
      ],
    );
  }

  // A reusable text field widget with validation
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15), // Rounded corners for input fields
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List Your Property'),
        backgroundColor: Colors.green.shade700, // Green to match the dashboard theme
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(controller: _nameController, label: 'Property Name'),
              _buildTextField(controller: _addressController, label: 'Address'),
              _buildTextField(controller: _priceController, label: 'Price', keyboardType: TextInputType.number),
              _buildTextField(controller: _roomsController, label: 'Number of Rooms', keyboardType: TextInputType.number),
              _buildTextField(controller: _descriptionController, label: 'Description', maxLines: 3),
              const SizedBox(height: 10),
              _buildImagePicker(),
              const SizedBox(height: 20),
              _isSubmitting
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _submitProperty,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700, // Green background for visibility
                  foregroundColor: Colors.white, // White text color for contrast
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('Submit Property', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
