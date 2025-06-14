import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminMaintenanceDetails extends StatefulWidget {
  final String requestId;

  const AdminMaintenanceDetails({Key? key, required this.requestId}) : super(key: key);

  @override
  _AdminMaintenanceDetailsState createState() => _AdminMaintenanceDetailsState();
}

class _AdminMaintenanceDetailsState extends State<AdminMaintenanceDetails> {
  late Map<String, dynamic> requestDetails;
  bool isLoading = true;
  String assignedProfessional = 'Unassigned';
  bool isProfessionalAssigned = false;
  List<dynamic>? images;  // List to hold image URLs

  // Fetching specific maintenance request details
  Future<void> _fetchRequestDetails() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('maintenance_requests')
          .doc(widget.requestId)
          .get();
      setState(() {
        requestDetails = snapshot.data() as Map<String, dynamic>;
        assignedProfessional = requestDetails['assigned_professional'] ?? 'Unassigned';
        images = requestDetails['images'];  // Fetch image URLs (could be multiple)
        isProfessionalAssigned = assignedProfessional != 'Unassigned';
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching request details: $e");
    }
  }

  // Assign a professional to the request and set status to "accepted"
  Future<void> _assignProfessional() async {
    if (assignedProfessional == 'Unassigned') {
      // Restrict saving if the professional is not assigned
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please assign a professional before accepting the request')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('maintenance_requests')
          .doc(widget.requestId)
          .update({
        'assigned_professional': assignedProfessional,
        'status': 'accepted',  // Automatically set status to accepted when a professional is assigned
      });

      setState(() {
        isProfessionalAssigned = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Assigned $assignedProfessional')),
      );
    } catch (e) {
      print("Error assigning professional: $e");
    }
  }

  // Reject the request and set status to "rejected"
  Future<void> _rejectRequest() async {
    try {
      await FirebaseFirestore.instance
          .collection('maintenance_requests')
          .doc(widget.requestId)
          .update({
        'status': 'rejected', // Reject the request
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request Rejected')),
      );
    } catch (e) {
      print("Error rejecting request: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchRequestDetails();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Maintenance Request Details'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Maintenance Request Details'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(  // Allows scrolling for large content
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display image(s) if available
              if (images != null && images!.isNotEmpty) ...[
                const SizedBox(height: 10),
                // Display images in a horizontal PageView (one at a time)
                SizedBox(
                  height: 300,  // Set the height of the image to take 40% of the screen
                  width: double.infinity,  // Full width of the screen
                  child: PageView.builder(
                    itemCount: images!.length,
                    itemBuilder: (context, index) {
                      return Image.network(
                        images![index],
                        fit: BoxFit.cover,  // Ensure image covers the space without distortion
                        height: 300,  // Set height
                        width: double.infinity,  // Set width to full
                      );
                    },
                  ),
                ),
              ] else ...[
                // Show a placeholder if no image is available
                const SizedBox(height: 10),
                Container(
                  height: 300,  // Placeholder height
                  width: double.infinity,
                  color: Colors.grey[300],  // Placeholder color if no image
                  child: const Icon(Icons.image, color: Colors.white),  // Icon for placeholder
                ),
              ],
              const SizedBox(height: 10),
              Text('Description: ${requestDetails['description']}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              Text('Urgency: ${requestDetails['urgency']}', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              Text('Status: ${requestDetails['status']}', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              // Only allow professional assignment if the request is pending
              if (requestDetails['status'] == 'pending') ...[
                DropdownButton<String>(
                  value: assignedProfessional,
                  onChanged: (String? newValue) {
                    setState(() {
                      assignedProfessional = newValue!;
                    });
                  },
                  items: <String>['Unassigned', 'Plumber', 'Electrician', 'Carpenter', 'Technician']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _assignProfessional,
                  child: const Text('Accept and Assign Professional'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent), // Primary button style
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _rejectRequest,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Reject Request'),
                ),
              ],
              // Show message if accepted and assigned
              if (isProfessionalAssigned) ...[
                const SizedBox(height: 20),
                Text(
                  'This request has been accepted and assigned to $assignedProfessional.',
                  style: const TextStyle(fontSize: 16, color: Colors.green),
                ),
              ],
              // Show message if rejected
              if (requestDetails['status'] == 'rejected') ...[
                const SizedBox(height: 20),
                Text(
                  'This request has been rejected.',
                  style: const TextStyle(fontSize: 16, color: Colors.red),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
