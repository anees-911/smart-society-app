import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_property_details.dart'; // Import the new screen

class AdminPropertyApprovalsScreen extends StatefulWidget {
  const AdminPropertyApprovalsScreen({Key? key}) : super(key: key);

  @override
  _AdminPropertyApprovalsScreenState createState() =>
      _AdminPropertyApprovalsScreenState();
}

class _AdminPropertyApprovalsScreenState
    extends State<AdminPropertyApprovalsScreen> {
  late Stream<QuerySnapshot> _propertiesStream;

  @override
  void initState() {
    super.initState();
    _propertiesStream = FirebaseFirestore.instance
        .collection('properties')
        .where(
        'isApproved', isEqualTo: false) // Only show unapproved properties
        .snapshots();
  }

  // Function to approve, reject, or set as pending
  Future<void> _updateApprovalStatus(String propertyId, String status) async {
    bool isApproved = status == 'approve' ? true : false;

    try {
      await FirebaseFirestore.instance.collection('properties')
          .doc(propertyId)
          .update({
        'isApproved': isApproved,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Property $status')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: $e')),
      );
    }
  }

  // Build the list of properties
  Widget _buildPropertyList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _propertiesStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(
              child: Text('Something went wrong. Please try again later.'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No unapproved properties found.'));
        }

        var properties = snapshot.data!.docs;

        return ListView.builder(
          itemCount: properties.length,
          itemBuilder: (context, index) {
            var property = properties[index];
            var propertyId = property.id;
            var propertyName = property['name'];
            var propertyAddress = property['address'];
            var propertyPrice = property['price'];

            return Card(
              margin: const EdgeInsets.symmetric(
                  vertical: 8.0, horizontal: 16.0),
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16.0),
                title: Text(
                  propertyName,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Address: $propertyAddress'),
                    Text('Price: Rs ${propertyPrice}'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check_circle, color: Colors.green),
                      onPressed: () =>
                          _updateApprovalStatus(propertyId, 'approve'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      onPressed: () =>
                          _updateApprovalStatus(propertyId, 'reject'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.pending, color: Colors.orange),
                      onPressed: () =>
                          _updateApprovalStatus(propertyId, 'pending'),
                    ),
                    // Navigate to the detailed view when clicking on the property
                    IconButton(
                      icon: const Icon(Icons.info, color: Colors.blue),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AdminPropertyDetailScreen(
                                propertyId: propertyId),
                          ),
                        );
                      }, // Navigate to the detail screen
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Property Approvals"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: _buildPropertyList(),
    );
  }
}