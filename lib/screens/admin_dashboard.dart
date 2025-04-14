import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_event_approvals.dart'; // Import the Admin Event Approvals screen
import 'admin_add_events.dart';
import 'admin_maintenance_hub.dart'; // Import the Admin Add Event screen

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String? adminName = "Loading...";
  String? adminEmail = "Loading...";

  @override
  void initState() {
    super.initState();
    _fetchAdminData();
  }

  // Fetch admin data from Firestore based on current logged-in user
  Future<void> _fetchAdminData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        print("Fetching data for admin with UID: ${user.uid}");

        final querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('uid', isEqualTo: user.uid)
            .where('role', isEqualTo: 'admin') // Ensure only admin is fetched
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          final adminDoc = querySnapshot.docs.first;
          print("Admin data fetched: ${adminDoc.data()}");

          setState(() {
            adminName = adminDoc['name'] ?? 'Admin';
            adminEmail = adminDoc['email'] ?? user.email; // Fallback to Firebase email
          });
        } else {
          print("No admin document found for UID: ${user.uid}");
          setState(() {
            adminName = "Admin";
            adminEmail = user.email ?? "Unknown Email";
          });
        }
      } else {
        print("No logged-in admin user found.");
        setState(() {
          adminName = "No Admin Found";
          adminEmail = "No Email Found";
        });
      }
    } catch (error) {
      print("Error fetching admin data: $error");
      setState(() {
        adminName = "Error Loading Admin";
        adminEmail = "Error Loading Email";
      });
    }
  }

  void _showFeatureNotAvailableMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('This feature is not available yet.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showNotificationMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No new notifications.'),
        duration: Duration(seconds: 2),
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
            onPressed: () => _showNotificationMessage(context),
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
            _buildQuickActionsSection(context), // Updated section to include Maintenance Hub and Event Approvals
          ],
        ),
      ),
      drawer: _buildDrawer(context),
    );
  }

  // Drawer menu with links to different admin features
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(adminName ?? 'Loading...'),
            accountEmail: Text(adminEmail ?? 'Loading...'),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.admin_panel_settings,
                  size: 50, color: Colors.blueAccent),
            ),
            decoration: const BoxDecoration(
              color: Colors.blueAccent,
            ),
          ),
          _buildDrawerItem(Icons.lightbulb, 'Street Lighting', context),
          _buildDrawerItem(Icons.event, 'Event Approvals', context), // New link for Event Approvals
          _buildDrawerItem(Icons.people, 'Resident Management', context),
          _buildDrawerItem(Icons.build, 'Maintenance Hub', context), // Added "Maintenance Hub"
          _buildDrawerItem(Icons.apartment, 'Property Approvals', context),
          _buildDrawerItem(Icons.store, 'Marketplace', context),
          const Divider(),
          _buildDrawerItem(Icons.logout, 'Logout', context, isLogout: true),
        ],
      ),
    );
  }

  // Handle navigation from the Drawer
  Widget _buildDrawerItem(IconData icon, String title, BuildContext context, {bool isLogout = false}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        if (isLogout) {
          Navigator.pushReplacementNamed(context, '/login');
        } else {
          if (title == 'Event Approvals') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AdminEventApprovalsScreen()), // Navigate to Event Approvals
            );
          } else if (title == 'Maintenance Hub') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AdminMaintenanceHub()), // Navigate to Maintenance Hub
            );
          } else {
            _showFeatureNotAvailableMessage(context);
          }
        }
      },
    );
  }

  // Display the welcome message to the admin
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

  // Display overview of various metrics for the admin
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
            _buildOverviewCard('Maintenance Requests', '8', Colors.redAccent),
            _buildOverviewCard('Properties', '12', Colors.greenAccent),
          ],
        ),
      ],
    );
  }

  // Helper widget for the overview cards
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

  // Display quick actions like managing street lighting, events, etc.
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
                'Street Lighting', Icons.lightbulb, Colors.blueAccent, context),
            _buildQuickActionCard(
                'Event Approvals', Icons.event, Colors.orangeAccent, context),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildQuickActionCard(
                'Resident Management', Icons.people, Colors.purpleAccent, context),
            _buildQuickActionCard(
                'Maintenance Hub', Icons.build, Colors.redAccent, context), // Updated
          ],
        ),
      ],
    );
  }

  // Helper widget for quick action cards
  Widget _buildQuickActionCard(
      String title, IconData icon, Color color, BuildContext context) {
    return GestureDetector(
      onTap: () => _showFeatureNotAvailableMessage(context),
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
              style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
