import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_event_approvals.dart';
import 'admin_maintenance_hub.dart';
import 'admin_property_approvals.dart';
import 'admin_myprofile.dart';
import 'admin_market_directory.dart';
import 'admin_resident_management.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String? adminName = "Loading...";
  String? adminEmail = "Loading...";
  String? adminProfilePic = ""; // Variable to store profile picture URL
  bool _isLoading = true; // Variable to show loading state

  @override
  void initState() {
    super.initState();
    _fetchAdminData();
  }

  // Fetch admin data from Firestore
  Future<void> _fetchAdminData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('uid', isEqualTo: user.uid)
            .where('role', isEqualTo: 'admin')
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          final adminDoc = querySnapshot.docs.first;
          setState(() {
            adminName = adminDoc['name'] ?? 'Admin';
            adminEmail = adminDoc['email'] ?? user.email;
            adminProfilePic = adminDoc['profile_picture'] ?? ''; // Fetch profile picture URL
            _isLoading = false; // Set loading to false after data is fetched
          });
        } else {
          setState(() {
            adminName = "Admin";
            adminEmail = user.email ?? "Unknown Email";
            adminProfilePic = ''; // No profile picture available
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          adminName = "No Admin Found";
          adminEmail = "No Email Found";
          adminProfilePic = ''; // No profile picture available
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        adminName = "Error Loading Admin";
        adminEmail = "Error Loading Email";
        adminProfilePic = ''; // No profile picture available
        _isLoading = false; // Set loading to false after error
      });
      print("Error fetching admin data: $error"); // Log the error for debugging
    }
  }

  // Show a feature not available message
  void _showFeatureNotAvailableMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('This feature is not available yet.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Show notifications in a dialog
  void _showNotificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Notifications'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Notification 1: New event request pending.'),
              SizedBox(height: 10),
              Text('Notification 2: Maintenance request approved.'),
              SizedBox(height: 10),
              Text('Notification 3: New property listing added.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // Build the quick action card for different actions
  Widget _buildQuickActionCard(
      String title, IconData icon, Color color, BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (title == 'Event Approvals') {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AdminEventApprovalsScreen()),
          );
        } else if (title == 'Resident Management') {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const AdminResidentManagement()),
          );
        } else if (title == 'Maintenance Hub') {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const AdminMaintenanceHub()),
          );
        }
        else {
          _showFeatureNotAvailableMessage(context);
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.9),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Icon(icon, size: 30, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => _showNotificationDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeSection(),
            const SizedBox(height: 20),
            _buildOverviewSection(),
            const SizedBox(height: 20),
            _buildQuickActionsSection(context),
          ],
        ),
      ),
      drawer: _buildDrawer(context),
    );
  }

  // Build the drawer containing admin's profile information and options
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          _isLoading
              ? const UserAccountsDrawerHeader(
            accountName: Text('Loading...'),
            accountEmail: Text('Loading...'),
            currentAccountPicture:
            CircleAvatar(backgroundColor: Colors.white),
            decoration: BoxDecoration(
              color: Colors.blueAccent,
            ),
          )
              : UserAccountsDrawerHeader(
            accountName: Text(adminName ?? 'Loading...'),
            accountEmail: Text(adminEmail ?? 'Loading...'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: adminProfilePic != null && adminProfilePic!.isNotEmpty
                  ? NetworkImage(adminProfilePic!) // Display profile picture if available
                  : const AssetImage('assets/default_profile_image.png') as ImageProvider, // Fallback to default icon
              radius: 40, // Ensure the image is round by setting the radius
            ),
            decoration: const BoxDecoration(
              color: Colors.blueAccent,
            ),
          ),
          _buildDrawerItem(Icons.lightbulb, 'Street Lighting', context),
          _buildDrawerItem(Icons.event, 'Event Approvals', context),
          _buildDrawerItem(Icons.people, 'Resident Management', context),
          _buildDrawerItem(Icons.build, 'Maintenance Hub', context),
          _buildDrawerItem(Icons.apartment, 'Property Approvals', context),
          _buildDrawerItem(Icons.store, 'Marketplace', context),
          _buildDrawerItem(Icons.person, 'My Profile', context),
          const Divider(),
          _buildDrawerItem(Icons.logout, 'Logout', context, isLogout: true),
        ],
      ),
    );
  }

  // Drawer item creation
  Widget _buildDrawerItem(IconData icon, String title, BuildContext context,
      {bool isLogout = false}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        if (isLogout) {
          Navigator.pushReplacementNamed(context, '/login');
        } else {
          if (title == 'Property Approvals') {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const AdminPropertyApprovalsScreen()),
            );
          } else if (title == 'Event Approvals') {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AdminEventApprovalsScreen()),
            );
          } else if (title == 'Resident Management') {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const AdminResidentManagement()),
            );
          } else if (title == 'Maintenance Hub') {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const AdminMaintenanceHub()),
            );
          } else if (title == 'My Profile') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AdminMyProfile()),
            );
          } else if (title == 'Marketplace') {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AdminMarketDirectoryScreen()),
            );
          } else {
            _showFeatureNotAvailableMessage(context);
          }
        }
      },
    );
  }

  // Welcome section UI
  Widget _buildWelcomeSection() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueAccent, Colors.lightBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            adminName != null ? 'Welcome, $adminName!' : 'Welcome!',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Manage your society efficiently with the tools below.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  // Overview section UI
  Widget _buildOverviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Overview',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildOverviewCard('Residents', '150', Colors.blueAccent),
            _buildOverviewCard('Pending Events', '5', Colors.orangeAccent),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildOverviewCard(
                'Maintenance Requests', '8', Colors.redAccent),
            _buildOverviewCard('Properties', '12', Colors.greenAccent),
          ],
        ),
      ],
    );
  }

  // Overview card creation
  Widget _buildOverviewCard(String title, String value, Color color) {
    return Expanded(
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Quick actions section UI
  Widget _buildQuickActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildQuickActionCard(
                'Event Approvals', Icons.event, Colors.orangeAccent, context),
            _buildQuickActionCard('Street Lighting', Icons.lightbulb,
                Colors.blueAccent, context),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildQuickActionCard('Resident Management', Icons.people,
                Colors.purpleAccent, context),
            _buildQuickActionCard(
                'Maintenance Hub', Icons.build, Colors.redAccent, context),
          ],
        ),
      ],
    );
  }
}
