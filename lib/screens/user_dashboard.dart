import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Add this import
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
    _checkSession(); // Check if the user is logged in
  }

  // Check if the user is logged in from SharedPreferences
  Future<void> _checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      // If logged in, fetch user data from Firebase
      FirebaseAuth.instance.authStateChanges().listen((user) async {
        if (user != null) {
          await _fetchUserData(user);
        } else {
          setState(() {
            isLoading = false;
          });
        }
      });
    } else {
      // If not logged in, navigate to login screen
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  // Fetch user data from Firestore
  Future<void> _fetchUserData(User user) async {
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          userName = userDoc['name'] ?? 'User';
          userEmail = userDoc['email'] ?? user.email ?? 'No email provided';
          userImageUrl = userDoc['profile_picture'] ?? ''; // Assuming 'profileImageUrl' is stored
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        print('User document does not exist');
        _showMessage('User document does not exist.');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching user data: $e'); // Print error for debugging
      _showMessage('Failed to load user data: ${e.toString()}');
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

  // **_showMessage** Method to show error/success messages
  void _showMessage(String message, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  // Drawer UI with user data
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          isLoading
              ? const UserAccountsDrawerHeader(
            accountName: Text('Loading...'),
            accountEmail: Text('Loading...'),
            currentAccountPicture: CircleAvatar(backgroundColor: Colors.white),
            decoration: BoxDecoration(
              color: Colors.greenAccent,
            ),
          )
              : UserAccountsDrawerHeader(
            accountName: Text(userName),
            accountEmail: Text(userEmail),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: userImageUrl.isNotEmpty
                  ? NetworkImage(userImageUrl)
                  : const AssetImage('assets/default_profile_image.png') as ImageProvider,
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
          _logout(context); // Call the logout function
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

  // Logout function to clear session and navigate to login screen
  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', false); // Clear session
    prefs.remove('userEmail'); // Remove saved email

    await FirebaseAuth.instance.signOut(); // Sign out from Firebase

    Navigator.pushReplacementNamed(context, '/login'); // Navigate to login screen
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
          height: 130,
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
        width: MediaQuery.of(context).size.width * 0.44,
        height: 120,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontSize: 14,
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
            onPressed: () => _showNotificationPopup(context),
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading indicator
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
