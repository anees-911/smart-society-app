import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ResidentDetailScreen extends StatelessWidget {
  final QueryDocumentSnapshot userData;

  const ResidentDetailScreen({Key? key, required this.userData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final data = userData.data() as Map<String, dynamic>;

    final name = data['name'] ?? 'Not available';
    final email = data['email'] ?? 'Not available';
    final phone = data['phone'] ?? 'Not available';
    final address = data['address'] ?? 'Not available';

    // Correct key: 'profile_picture' not 'profilePic'
    final profilePic = data.containsKey('profile_picture') ? data['profile_picture'] : null;
    print('Profile Pic URL: $profilePic');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resident Details'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Account'),
                  content: Text('Are you sure you want to delete the account for "$name"?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                try {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(userData.id)
                      .delete();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User deleted successfully.')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error deleting user.')),
                  );
                }
              }
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: profilePic != null && profilePic.toString().isNotEmpty
                  ? NetworkImage(profilePic)
                  : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
              onBackgroundImageError: (_, __) {
                print('Failed to load profile image');
              },
            ),
            const SizedBox(height: 20),
            _buildDetailRow('Name', name),
            _buildDetailRow('Email', email),
            _buildDetailRow('Phone', phone),
            _buildDetailRow('Address', address),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
