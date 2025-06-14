import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'rentals_screen.dart';
import 'user_events_and_announcements.dart';
import 'user_market_directory.dart';
import 'user_myprofile.dart';
import 'user_request_maintenance.dart';
import 'list_property_screen.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({Key? key}) : super(key: key);

  @override
  _UserDashboardState createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  String userName = "Loading...";
  String userEmail = "Loading...";
  String userImageUrl = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  // This method handles the FirebaseAuth state changes and fetches user data
  Future<void> _initializeApp() async {
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user != null) {
        // Fetch user data from Firestore when the user is authenticated
        await _fetchUserData(user);
      } else {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  // Fetch user data from Firestore
  Future<void> _fetchUserData(User user) async {
    try {
      // Fetch user data from Firestore
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          userName = userDoc['name'] ?? 'User';
          userEmail = userDoc['email'] ?? user.email ?? 'No email provided';
          userImageUrl = userDoc['profile_picture'] ?? ''; // Assuming 'profileImageUrl' is stored
          isLoading = false; // Stop loading once data is fetched
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching user data: $e');
    }
  }

  // Show notifications in a dialog
  void _showNotificationPopup(BuildContext context) {
    final notifications = [
      "New event available: 'Community Meeting' on 25th April.",
      "Maintenance request for 'Plumbing issue' is being processed.",
      "Reminder: Rent payment due on 30th April.",
      "New rental property listed: '2BHK Apartment' in Downtown.",
      "Local market directory has been updated with new vendors.",
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Notifications'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: notifications.map((notification) {
              return ListTile(
                leading: const Icon(Icons.notification_important),
                title: Text(notification),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // Drawer UI with user data
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(userName),
            accountEmail: Text(userEmail),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: userImageUrl.isNotEmpty
                  ? NetworkImage(userImageUrl) // Fetch from Firestore
                  : const AssetImage('assets/default_profile_image.png') as ImageProvider, // Default image if needed
              radius: 40,
            ),
            decoration: const BoxDecoration(
              color: Colors.greenAccent,
            ),
          ),

          _buildDrawerItem(Icons.event, 'Events & Announcements', context),
          _buildDrawerItem(Icons.home, 'Available Rentals', context),
          _buildDrawerItem(Icons.add_business, 'List Your Property', context),
          _buildDrawerItem(Icons.store, 'Local Market Directory', context),
          _buildDrawerItem(Icons.build, 'Request Maintenance', context),
          _buildDrawerItem(Icons.person, 'My Profile', context),
          const Divider(),
          _buildDrawerItem(Icons.logout, 'Logout', context, isLogout: true),
        ],
      ),
    );
  }

  // Create drawer item widget
  Widget _buildDrawerItem(IconData icon, String title, BuildContext context, {bool isLogout = false}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        if (isLogout) {
          FirebaseAuth.instance.signOut();
          Navigator.pushReplacementNamed(context, '/login');
        } else {
          _navigateToScreen(title, context);
        }
      },
    );
  }

  // Navigation based on selected drawer item
  void _navigateToScreen(String title, BuildContext context) {
    if (title == 'Events & Announcements') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => UserEventsAndAnnouncementsScreen()));
    } else if (title == 'Available Rentals') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const RentalsScreen()));
    } else if (title == 'List Your Property') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const ListPropertyScreen()));
    } else if (title == 'Request Maintenance') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const RequestMaintenanceScreen()));
    } else if (title == 'My Profile') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const UserMyProfile()));
    } else if (title == 'Local Market Directory') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => UserMarketDirectoryScreen()));
    } else {
      _showFeatureNotAvailableMessage(context);
    }
  }

  // Show feature not available message
  void _showFeatureNotAvailableMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('This feature is not available yet.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Welcome Section UI
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
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome, $userName!',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          const Text(
            'Access your society services below.',
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  // Overview Section UI
  Widget _buildOverviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Overview', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
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

  // Quick Actions Section UI
  Widget _buildQuickActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Actions', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildQuickActionCard('Events & Announcements', Icons.event, Colors.blue, context),
            _buildQuickActionCard('Available Rentals', Icons.home, Colors.orange, context),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildQuickActionCard('List Your Property', Icons.add_business, Colors.green, context),
            _buildQuickActionCard('Local Market Directory', Icons.store, Colors.purple, context),
          ],
        ),
      ],
    );
  }

  // Overview Card UI
  Widget _buildOverviewCard(String title, String value, Color color) {
    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          height: 130, // Slightly reduced height for consistency
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Quick Action Card UI
  Widget _buildQuickActionCard(String title, IconData icon, Color color, BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToScreen(title, context),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.44, // Adjusted width for consistent fit
        height: 120, // Reduced height for a more compact look
        padding: const EdgeInsets.all(12), // Adjusted padding for a more compact card
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: Colors.white), // Slightly smaller icon for compactness
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontSize: 14, // Adjusted font size to fit the new card size
              ),
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
        title: const Text("User Dashboard"),
        backgroundColor: Colors.green,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => _showNotificationPopup(context), // Show notifications on click
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading indicator while data is being fetched
          : SingleChildScrollView(
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
    );
  }
}
