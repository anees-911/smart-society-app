import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminMaintenanceHub extends StatefulWidget {
  const AdminMaintenanceHub({Key? key}) : super(key: key);

  @override
  _AdminMaintenanceHubState createState() => _AdminMaintenanceHubState();
}

class _AdminMaintenanceHubState extends State<AdminMaintenanceHub> {
  // Fetching the maintenance requests from Firestore
  Future<List<Map<String, dynamic>>> _fetchRequests() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('maintenance_requests').get();
      List<Map<String, dynamic>> requests = [];
      print("Fetched requests: ${snapshot.docs.length}"); // Debug: Print the number of requests fetched

      for (var doc in snapshot.docs) {
        requests.add(doc.data() as Map<String, dynamic>);
      }
      return requests;
    } catch (e) {
      print("Error fetching requests: $e"); // Debug: Print error if something goes wrong
      return []; // Return empty list if error occurs
    }
  }

  // Updating the status of the maintenance request
  Future<void> _updateStatus(String requestId, String status) async {
    await FirebaseFirestore.instance.collection('maintenance_requests').doc(requestId).update({
      'status': status,
    });
  }

  // Show a message
  void _showMessage(String message, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Maintenance Hub'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView( // Ensures the entire content is scrollable
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<List<Map<String, dynamic>>>(
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

              return Column(
                children: requests.map((request) {
                  var requestId = request['id'];
                  var description = request['description'];
                  var urgency = request['urgency'];
                  var status = request['status'];
                  var assignedProfessional = request['assigned_professional'];

                  return Card(
                    margin: const EdgeInsets.all(10),
                    child: ListTile(
                      title: Text(description),
                      subtitle: Text('Urgency: $urgency\nAssigned to: $assignedProfessional'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Status: $status'),
                          const SizedBox(height: 8),
                          // Row with Flexible to prevent overflow in Row
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (status == 'pending')
                                Flexible(
                                  child: IconButton(
                                    icon: const Icon(Icons.check_circle, color: Colors.green),
                                    onPressed: () {
                                      _updateStatus(requestId, 'accepted');  // Accept the request
                                      _showMessage('Request Accepted');
                                    },
                                  ),
                                ),
                              if (status == 'pending')
                                Flexible(
                                  child: IconButton(
                                    icon: const Icon(Icons.cancel, color: Colors.red),
                                    onPressed: () {
                                      _updateStatus(requestId, 'rejected');  // Reject the request
                                      _showMessage('Request Rejected');
                                    },
                                  ),
                                ),
                              if (status != 'pending')
                                Flexible(
                                  child: IconButton(
                                    icon: const Icon(Icons.pending, color: Colors.orange),
                                    onPressed: () {
                                      _updateStatus(requestId, 'pending');  // Set as pending again
                                      _showMessage('Request Set to Pending');
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ),
    );
  }
}
