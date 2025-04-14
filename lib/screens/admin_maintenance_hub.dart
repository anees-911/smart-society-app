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
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('maintenance_requests').get();
    List<Map<String, dynamic>> requests = [];
    for (var doc in snapshot.docs) {
      requests.add(doc.data() as Map<String, dynamic>);
    }
    return requests;
  }

  // Updating the status of the maintenance request
  Future<void> _updateStatus(String requestId, String status) async {
    await FirebaseFirestore.instance.collection('maintenance_requests').doc(requestId).update({
      'status': status,
    });
  }

  // Assigning a professional to the maintenance request
  Future<void> _assignProfessional(String requestId, String professionalId) async {
    await FirebaseFirestore.instance.collection('maintenance_requests').doc(requestId).update({
      'assigned_professional': professionalId,
      'status': 'accepted', // Update status to accepted when a professional is assigned
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _fetchRequests(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
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
                          // Status update buttons
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (status == 'pending')
                                IconButton(
                                  icon: const Icon(Icons.check_circle, color: Colors.green),
                                  onPressed: () {
                                    _updateStatus(requestId, 'accepted');  // Accept the request
                                    // Optionally, you can assign a professional here
                                    // _assignProfessional(requestId, 'professional_id_1');
                                    _showMessage('Request Accepted');
                                  },
                                ),
                              if (status == 'pending')
                                IconButton(
                                  icon: const Icon(Icons.cancel, color: Colors.red),
                                  onPressed: () {
                                    _updateStatus(requestId, 'rejected');  // Reject the request
                                    _showMessage('Request Rejected');
                                  },
                                ),
                              if (status != 'pending' && assignedProfessional == null)
                                IconButton(
                                  icon: const Icon(Icons.assignment_ind, color: Colors.blue),
                                  onPressed: () {
                                    // Assign a professional for now (you can replace this logic with actual professional assignment)
                                    _assignProfessional(requestId, 'professional_id_1');
                                    _showMessage('Professional Assigned');
                                  },
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
