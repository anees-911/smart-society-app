import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class RequestMaintenanceScreen extends StatefulWidget {
  const RequestMaintenanceScreen({Key? key}) : super(key: key);

  @override
  State<RequestMaintenanceScreen> createState() => _RequestMaintenanceScreenState();
}

class _RequestMaintenanceScreenState extends State<RequestMaintenanceScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  String _urgency = 'Low'; // Default urgency
  bool _isLoading = false;
  List<File> _selectedImages = [];

  final ImagePicker _picker = ImagePicker();

  // Function to pick images from the gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source, imageQuality: 70);
    if (pickedFile != null) {
      setState(() {
        _selectedImages.add(File(pickedFile.path));
      });
    }
  }

  // Function to upload images to Firebase Storage
  Future<List<String>> _uploadImages() async {
    List<String> imageUrls = [];
    for (File image in _selectedImages) {
      final ref = FirebaseStorage.instance
          .ref('maintenance_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putFile(image);
      String downloadUrl = await ref.getDownloadURL();
      imageUrls.add(downloadUrl);
    }
    return imageUrls;
  }

  // Function to submit the maintenance request
  Future<void> _submitRequest() async {
    if (_descriptionController.text.isEmpty) {
      _showMessage('Please provide a description.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      List<String> imageUrls = await _uploadImages();

      // Save the maintenance request data to Firestore
      await FirebaseFirestore.instance.collection('maintenance_requests').add({
        'description': _descriptionController.text.trim(),
        'urgency': _urgency,
        'images': imageUrls,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending', // Initially set to 'pending'
      });

      _showMessage('Maintenance request submitted successfully!', success: true);
      Navigator.pop(context); // Close the screen after submission
    } catch (e) {
      _showMessage('Failed to submit the request: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Show messages to the user
  void _showMessage(String message, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Maintenance'),
        backgroundColor: Colors.green.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Describe the issue:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Provide a detailed description of the issue',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Select Urgency:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              DropdownButton<String>(
                value: _urgency,
                onChanged: (String? newValue) {
                  setState(() {
                    _urgency = newValue!;
                  });
                },
                items: <String>['Low', 'Medium', 'High']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              const Text(
                'Attach Images (optional):',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700, // background color
                      foregroundColor: Colors.white, // text color
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700, // background color
                      foregroundColor: Colors.white, // text color
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Display selected images (if any)
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _selectedImages.map((image) {
                  return Stack(
                    children: [
                      Image.file(image, width: 100, height: 100, fit: BoxFit.cover),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _selectedImages.remove(image);
                            });
                          },
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _submitRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700, // background color
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: const Text('Submit Request', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
