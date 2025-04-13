import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserMyProfile extends StatefulWidget {
  const UserMyProfile({Key? key}) : super(key: key);

  @override
  _UserMyProfileState createState() => _UserMyProfileState();
}

class _UserMyProfileState extends State<UserMyProfile> {
  String userName = "Loading...";
  String userEmail = "Loading...";
  final TextEditingController _nameController = TextEditingController();
  bool _isUpdating = false; // To show a loading indicator while updating

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Fetch the user data from Firestore
  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc =
      await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        setState(() {
          userName = userDoc['name'] ?? 'User';
          userEmail = userDoc['email'] ?? 'user@example.com';
          _nameController.text = userName; // Set the name controller text
        });
      }
    }
  }

  // Save the updated user name to Firestore
  Future<void> _updateName() async {
    setState(() {
      _isUpdating = true; // Show loading indicator
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'name': _nameController.text.trim(),
        });

        setState(() {
          userName = _nameController.text.trim();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }

    setState(() {
      _isUpdating = false; // Hide loading indicator
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: Colors.green.shade700, // Match the UserDashboard theme
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Profile Picture Section (Centered)
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 80,
                    backgroundColor: Colors.grey.shade300,
                    child: Icon(
                      Icons.person,
                      size: 100,
                      color: Colors.white,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        // Implement image picker for profile photo
                      },
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.blueAccent,
                        child: Icon(
                          Icons.camera_alt,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Name Section (Editable)
            _buildProfileItem("Name", _nameController, true),

            // Email Section (Non-editable)
            _buildProfileItem("Email", userEmail, false),

            const SizedBox(height: 30),

            // Save Button to update profile
            _buildActionButton("Save Changes", _isUpdating ? null : _updateName), // Disable button while updating

            const SizedBox(height: 20),

            // Logout Button (Green matching the dashboard theme)
            _buildActionButton("Logout", () {
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            }),
          ],
        ),
      ),
    );
  }

  // A reusable widget for displaying profile items (matching UserDashboard card design)
  Widget _buildProfileItem(String title, dynamic value, bool isEditable) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              isEditable
                  ? SizedBox(
                width: 180,
                child: TextField(
                  controller: value,
                  decoration: InputDecoration(
                    hintText: title,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              )
                  : Text(
                value,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // A reusable button widget for actions like saving changes, logout, etc.
  Widget _buildActionButton(String title, VoidCallback? onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          backgroundColor: Colors.green.shade700, // Green for consistency with the dashboard
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          minimumSize: Size(double.infinity, 50), // Full-width button for consistency
        ),
        child: _isUpdating
            ? const CircularProgressIndicator(
          color: Colors.white,
        ) // Show loading indicator while updating
            : Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
