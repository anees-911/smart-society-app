import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_market_dir_details.dart'; // Import the details screen

class UserMarketDirectoryScreen extends StatefulWidget {
  @override
  _UserMarketDirectoryScreenState createState() =>
      _UserMarketDirectoryScreenState();
}

class _UserMarketDirectoryScreenState extends State<UserMarketDirectoryScreen> {
  // Fetch market directory data from Firestore
  Future<List<DocumentSnapshot>> _fetchMarketDirectory() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('market_directory') // Collection for market directory
        .get();

    return snapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Market Directory"),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: _fetchMarketDirectory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No market data found."));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final market = snapshot.data![index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  title: Text(
                    market['name'], // Display market/shop name
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Text(
                    market['category'], // Display shop category (e.g., Electrician, General Store)
                    style: const TextStyle(fontSize: 16),
                  ),
                  onTap: () {
                    // Navigate to market details page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserMarketDirectoryDetailsScreen(
                          marketId: market.id, // Pass market ID for details screen
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
