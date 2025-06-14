import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_maintenance_details.dart';  // Import details screen

class AdminMaintenanceHub extends StatefulWidget {
  const AdminMaintenanceHub({Key? key}) : super(key: key);

  @override
  _AdminMaintenanceHubState createState() => _AdminMaintenanceHubState();
}

class _AdminMaintenanceHubState extends State<AdminMaintenanceHub> {
  // Fetching all maintenance requests from Firestore
  Future<List<Map<String, dynamic>>> _fetchRequests() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('maintenance_requests').get();
      List<Map<String, dynamic>> requests = [];

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Include document ID
        requests.add(data);
      }
      return requests;
    } catch (e) {
      print("Error fetching requests: $e");
      return [];
    }
  }

  // Building the UI for maintenance requests
  Widget _buildRequestCard(Map<String, dynamic> request) {
    var requestId = request['id'];
    var description = request['description'] ?? 'No description';
    var urgency = request['urgency'] ?? 'Not specified';
    var status = request['status'] ?? 'unknown';

    // Fetch the image URL safely
    var imageUrl = request['images'] != null && request['images'].isNotEmpty
        ? request['images'][0]
        : null;

    return GestureDetector(
      onTap: () {
        // Navigate to the details screen when clicked
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdminMaintenanceDetails(requestId: requestId),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Display the image if valid, else show a placeholder
              if (imageUrl != null && Uri.tryParse(imageUrl)?.isAbsolute == true)
                Image.network(
                  imageUrl,
                  height: 50,  // Set a fixed height for the small image
                  width: 50,  // Set a fixed width for the small image
                  fit: BoxFit.cover,  // Make sure the image fits well
                )
              else
                Container(
                  height: 50,
                  width: 50,
                  color: Colors.grey[300],  // Placeholder color if no image
                  child: Icon(Icons.image, color: Colors.white),  // Icon for placeholder
                ),
              const SizedBox(width: 10),  // Add some space between the image and text
              // Text part of the card
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(description, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Urgency: $urgency'),
                  const SizedBox(height: 8),
                  Text('Status: $status', style: TextStyle(color: status == 'pending' ? Colors.orange : Colors.green)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maintenance Hub'),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(  // Fetch requests data
          future: _fetchRequests(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No maintenance requests.'));
            }

            List<Map<String, dynamic>> requests = snapshot.data!;

            return ListView.builder(
              itemCount: requests.length,
              itemBuilder: (context, index) => _buildRequestCard(requests[index]),  // Display each request card
            );
          },
        ),
      ),
    );
  }
}
