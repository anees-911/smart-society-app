
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminEventDetailScreen extends StatefulWidget {
  final String eventId;

  AdminEventDetailScreen({required this.eventId});

  @override
  _AdminEventDetailScreenState createState() => _AdminEventDetailScreenState();
}

class _AdminEventDetailScreenState extends State<AdminEventDetailScreen> {
  late DocumentSnapshot event;

  // Fetch event details using the eventId passed
  Future<void> _fetchEventDetails() async {
    try {
      final eventDoc = await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId) // Use the eventId passed from the previous screen
          .get();

      if (eventDoc.exists) {
        setState(() {
          event = eventDoc;
        });
      }
    } catch (e) {
      print("Error fetching event details: $e");
    }
  }

  // Update event status (approve, reject, leave pending)
  Future<void> _updateEventStatus(String status) async {
    try {
      await FirebaseFirestore.instance.collection('events').doc(widget.eventId).update({
        'status': status,
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Event $status successfully'),
        backgroundColor: Colors.green,
      ));

      // After updating the status, go back to the Event Approvals Screen
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to update event: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchEventDetails();
  }

  @override
  Widget build(BuildContext context) {
    if (event == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Event Details"),
          backgroundColor: Colors.green.shade700,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Event Details"),
        backgroundColor: Colors.green.shade700,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event['title'],
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              event['description'],
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Text(
              "Date: ${event['date'].toDate().toString().split(' ')[0]}", // Display date in YYYY-MM-DD format
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Text(
              "Status: ${event['status']}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Approve Button
                ElevatedButton(
                  onPressed: () => _updateEventStatus('approved'),
                  child: const Text('Approve'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
                // Reject Button
                ElevatedButton(
                  onPressed: () => _updateEventStatus('rejected'),
                  child: const Text('Reject'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
                // Leave Pending Button
                ElevatedButton(
                  onPressed: () => _updateEventStatus('pending'),
                  child: const Text('Leave Pending'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
