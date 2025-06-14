import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_market_dir_details.dart'; // Import the details screen

class UserMarketDirectoryScreen extends StatefulWidget {
  @override
  _UserMarketDirectoryScreenState createState() =>
      _UserMarketDirectoryScreenState();
}

class _UserMarketDirectoryScreenState extends State<UserMarketDirectoryScreen> {
  TextEditingController _searchController = TextEditingController();
  List<DocumentSnapshot> _allMarkets = [];
  List<DocumentSnapshot> _filteredMarkets = [];
  bool _isLoading = true; // Loading state
  String _errorMessage = ''; // Error message if any

  @override
  void initState() {
    super.initState();
    _fetchMarketDirectory();
  }

  // Fetch market directory data from Firestore
  Future<void> _fetchMarketDirectory() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('market_directory') // Collection for market directory
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          _errorMessage = 'No market data found.';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _allMarkets = snapshot.docs;
        _filteredMarkets = _allMarkets; // Initially, display all markets
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred while fetching data.';
        _isLoading = false;
      });
      print("Error fetching data: $e");
    }
  }

  // Filter markets based on search query
  void _filterMarkets(String query) {
    setState(() {
      _filteredMarkets = _allMarkets.where((market) {
        return market['name'].toLowerCase().contains(query.toLowerCase()) ||
            market['category'].toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Market Directory"),
        backgroundColor: Colors.green,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterMarkets,
              decoration: InputDecoration(
                hintText: 'Search markets...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(child: Text(_errorMessage))
          : _filteredMarkets.isEmpty
          ? const Center(child: Text("No matching markets found."))
          : ListView.builder(
        itemCount: _filteredMarkets.length,
        itemBuilder: (context, index) {
          final market = _filteredMarkets[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              title: Text(
                market['name'],
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 18),
              ),
              subtitle: Text(
                market['category'],
                style: const TextStyle(fontSize: 16),
              ),
              onTap: () {
                // Navigate to market details page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        UserMarketDirectoryDetailsScreen(
                          marketId: market.id, // Pass market ID for details screen
                        ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
