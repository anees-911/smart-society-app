import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class UserMyProfile extends StatefulWidget {
  const UserMyProfile({Key? key}) : super(key: key);

  @override
  _UserMyProfileState createState() => _UserMyProfileState();
}

class _UserMyProfileState extends State<UserMyProfile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  bool _isLoading = false;
  File? _imageFile;  // For storing selected image
  String? _profileImageUrl;  // For storing profile image URL from Firestore

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Fetch user data from Firestore and populate the controllers
  Future<void> _fetchUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          setState(() {
            _nameController.text = userDoc['name'] ?? '';
            _phoneController.text = userDoc['phone'] ?? '';
            _addressController.text = userDoc['address'] ?? '';
            _profileImageUrl = userDoc['profile_picture'] ?? '';  // Load profile picture URL
          });
        }
      } catch (e) {
        print("Error fetching user data: $e");
      }
    }
  }

  // Update the user's profile data
  Future<void> _updateProfile() async {
    setState(() {
      _isLoading = true;
    });

    final user = _auth.currentUser;
    if (user != null) {
      try {
        String imageUrl = '';
        // If a new image is selected, upload it to Firebase Storage
        if (_imageFile != null) {
          final ref = FirebaseStorage.instance.ref('profile_pics/${user.uid}.jpg');
          await ref.putFile(_imageFile!);
          imageUrl = await ref.getDownloadURL();
        } else {
          imageUrl = _profileImageUrl ?? '';  // Keep the old image if no new one is selected
        }

        // Update user profile data in Firestore
        await _firestore.collection('users').doc(user.uid).update({
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'address': _addressController.text.trim(),
          'profile_picture': imageUrl.isNotEmpty ? imageUrl : '', // Save image URL if available
        });

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to update profile: $e'),
          backgroundColor: Colors.red,
        ));
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Pick image from gallery or camera
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    // Show dialog to choose either camera or gallery
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Choose an option"),
          actions: [
            TextButton(
              onPressed: () async {
                final pickedFile = await picker.pickImage(source: ImageSource.camera);
                if (pickedFile != null) {
                  setState(() {
                    _imageFile = File(pickedFile.path);
                  });
                }
                Navigator.pop(context);
              },
              child: Text("Camera"),
            ),
            TextButton(
              onPressed: () async {
                final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  setState(() {
                    _imageFile = File(pickedFile.path);
                  });
                }
                Navigator.pop(context);
              },
              child: Text("Gallery"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.green.shade700, // Match with dashboard color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Profile Information',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Profile Image
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 80,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: _imageFile == null
                          ? (_profileImageUrl != null && _profileImageUrl!.isNotEmpty
                          ? NetworkImage(_profileImageUrl!) as ImageProvider
                          : const AssetImage('assets/default_image.png') // Default image if no profile picture
                      )
                          : FileImage(_imageFile!) as ImageProvider,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt),
                        onPressed: _pickImage,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Name Field
              _buildTextField(
                controller: _nameController,
                label: 'Name',
                icon: Icons.person,
              ),
              const SizedBox(height: 15),

              // Email Field (Non-editable, displayed as Text)
              _buildEmailTextField(),
              const SizedBox(height: 15),

              // Phone Field
              _buildTextField(
                controller: _phoneController,
                label: 'Phone Number',
                icon: Icons.phone,
              ),
              const SizedBox(height: 15),

              // Address Field
              _buildTextField(
                controller: _addressController,
                label: 'Address',
                icon: Icons.location_on,
              ),
              const SizedBox(height: 20),

              // Save Changes Button
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700, // Corrected color
                  foregroundColor: Colors.white, // Text color
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 60),
                ),
                child: const Text('Save Changes', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Reusable editable text field widget for the profile
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool readOnly = false,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  // Read-only text field widget for Email (Displayed as Text, not editable)
  Widget _buildEmailTextField() {
    final user = FirebaseAuth.instance.currentUser;
    return TextField(
      controller: TextEditingController(text: user?.email ?? 'No email found'), // Display email from Firebase Authentication
      readOnly: true, // Make email field read-only
      decoration: const InputDecoration(
        labelText: 'Email',
        prefixIcon: Icon(Icons.email),
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
