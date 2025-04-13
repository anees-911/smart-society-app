import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'rentals_screen.dart';
import 'list_property_screen.dart';
import 'user_myprofile.dart'; // Import the UserMyProfile screen
import 'user_request_maintenance.dart'; // Import the UserRequestMaintenance screen

class UserDashboard extends StatefulWidget {
  const UserDashboard({Key? key}) : super(key: key);

  @override
  _UserDashboardState createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  String userName = "Loading...";
  String userEmail = "Loading...";

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        setState(() {
          userName = userDoc['name'] ?? 'User';
          userEmail = userDoc['email'] ?? 'user@example.com';
        });
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Dashboard"),
        backgroundColor: Colors.green.shade700,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No new notifications.'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: RefreshIndicator(
        onRefresh: _fetchUserData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
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
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(userName),
            accountEmail: Text(userEmail),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 50, color: Colors.green),
            ),
            decoration: const BoxDecoration(
              color: Colors.greenAccent,
            ),
          ),
          _buildDrawerItem(Icons.event, 'Events & Announcements', context),
          _buildDrawerItem(Icons.home, 'Available Rentals', context),
          _buildDrawerItem(Icons.add_business, 'List Your Property', context),
          _buildDrawerItem(Icons.store, 'Local Market Directory', context),
          _buildDrawerItem(Icons.build, 'Request Maintenance', context), // Added "Request Maintenance"
          _buildDrawerItem(Icons.person, 'My Profile', context),
          const Divider(),
          _buildDrawerItem(Icons.logout, 'Logout', context, isLogout: true),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, BuildContext context, {bool isLogout = false}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        if (isLogout) {
          FirebaseAuth.instance.signOut();
          Navigator.pushReplacementNamed(context, '/login');
        } else if (title == 'Available Rentals') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RentalsScreen()),
          );
        } else if (title == 'List Your Property') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ListPropertyScreen()),
          );
        } else if (title == 'Request Maintenance') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UserRequestMaintenance()), // Navigate to Request Maintenance
          );
        } else if (title == 'My Profile') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UserMyProfile()), // Navigate to My Profile
          );
        } else {
          _showFeatureNotAvailableMessage(context);
        }
      },
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green, Colors.lightGreenAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome, $userName!',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Access your society services below.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

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
            _buildOverviewCard('Upcoming Events', '3', Colors.blueAccent),
            _buildOverviewCard('Rentals', '8', Colors.orangeAccent),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildOverviewCard('Maintenance Requests', '4', Colors.redAccent),
            _buildOverviewCard('Properties Listed', '10', Colors.greenAccent),
          ],
        ),
      ],
    );
  }

  Widget _buildOverviewCard(String title, String value, Color color) {
    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
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

  Widget _buildQuickActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.spaceBetween,
          children: [
            _buildQuickActionCard('Events & Announcements', Icons.event, Colors.blue, context),
            _buildQuickActionCard('Available Rentals', Icons.home, Colors.orange, context),
            _buildQuickActionCard('List Your Property', Icons.add_business, Colors.green, context),
            _buildQuickActionCard('Local Market Directory', Icons.store, Colors.purple, context),
            _buildQuickActionCard('Request Maintenance', Icons.build, Colors.red, context), // Added "Request Maintenance"
            _buildQuickActionCard('My Profile', Icons.person, Colors.indigo, context),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, Color color, BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (title == 'Request Maintenance') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UserRequestMaintenance()), // Navigate to Request Maintenance
          );
        } else if (title == 'Available Rentals') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RentalsScreen()),
          );
        } else if (title == 'List Your Property') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ListPropertyScreen()),
          );
        } else {
          _showFeatureNotAvailableMessage(context);
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.44,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
