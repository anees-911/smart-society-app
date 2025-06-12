import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'admin_resident_detail_screen.dart';

class AdminResidentManagement extends StatelessWidget {
  const AdminResidentManagement({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final usersRef = FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'user');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resident Management'),
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: usersRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching users.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs;

          if (users.isEmpty) {
            return const Center(child: Text('No users found.'));
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];

              // Safely get values, using `data()` and `containsKey`
              final userData = user.data() as Map<String, dynamic>;
              final name = userData['name'] ?? 'No Name';
              final email = userData['email'] ?? 'No Email';
              final profilePic = userData.containsKey('profilePic') ? userData['profilePic'] : null;

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: (profilePic != null && profilePic.toString().isNotEmpty)
                      ? NetworkImage(profilePic)
                      : null,
                  child: (profilePic == null || profilePic.toString().isEmpty)
                      ? const Icon(Icons.person)
                      : null,
                ),
                title: Text(name),
                subtitle: Text(email),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ResidentDetailScreen(userData: user),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
