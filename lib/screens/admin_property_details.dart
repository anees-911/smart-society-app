import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPropertyDetailScreen extends StatefulWidget {
  final String propertyId;
  const AdminPropertyDetailScreen({Key? key, required this.propertyId}) : super(key: key);

  @override
  _AdminPropertyDetailScreenState createState() =>
      _AdminPropertyDetailScreenState();
}

class _AdminPropertyDetailScreenState
    extends State<AdminPropertyDetailScreen> {
  DocumentSnapshot? property;

  @override
  void initState() {
    super.initState();
    _getPropertyDetails();
  }

  Future<void> _getPropertyDetails() async {
    try {
      var docSnapshot = await FirebaseFirestore.instance
          .collection('properties')
          .doc(widget.propertyId)
          .get();

      setState(() {
        property = docSnapshot;  // Assign the property once data is fetched
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch property details: $e')),
      );
    }
  }

  Future<void> _updateApprovalStatus(String status) async {
    bool isApproved = status == 'approve' ? true : false;

    try {
      await FirebaseFirestore.instance.collection('properties').doc(widget.propertyId).update({
        'isApproved': isApproved,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Property $status')),
      );
      Navigator.pop(context); // Go back to the approval list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (property == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),  // Show a loader while data is being fetched
      );
    }

    // Once data is fetched, display the property details
    var propertyName = property!['name'];
    var propertyDescription = property!['description'];
    var propertyImages = property!['images'] ?? [];
    var propertyPrice = property!['price'];
    var propertyAddress = property!['address'];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Property Approvals"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(propertyName, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(propertyAddress, style: TextStyle(fontSize: 16, color: Colors.grey)),
            SizedBox(height: 8),
            Text('Price: Rs ${propertyPrice}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Description: $propertyDescription'),
            SizedBox(height: 20),
            propertyImages.isNotEmpty
                ? Container(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: propertyImages.length,
                itemBuilder: (context, index) {
                  return Image.network(propertyImages[index], fit: BoxFit.cover);
                },
              ),
            )
                : Text('No images available.'),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () => _updateApprovalStatus('approve'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: Text('Approve'),
                ),
                ElevatedButton(
                  onPressed: () => _updateApprovalStatus('reject'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: Text('Reject'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
