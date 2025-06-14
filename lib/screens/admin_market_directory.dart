import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_market_directory_details.dart'; // For navigating to the details screen
import 'admin_add_market_directory.dart';

class AdminMarketDirectoryScreen extends StatefulWidget {
  @override
  _AdminMarketDirectoryScreenState createState() => _AdminMarketDirectoryScreenState();
}

class _AdminMarketDirectoryScreenState extends State<AdminMarketDirectoryScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Market Directory'),
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder(
        stream: _firestore.collection('market_directory').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No market directories available."));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var market = snapshot.data!.docs[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  title: Text(market['name']),
                  subtitle: Text(market['contact']),
                  onTap: () {
                    // Navigate to market details screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminMarketDirectoryDetailsScreen(marketId: market.id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add market directory screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AdminAddMarketDirectoryScreen()),
          );
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
      ),
    );
  }
}