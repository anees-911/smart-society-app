import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_event_detail.dart'; // Import the Admin Event Detail screen
import 'admin_add_events.dart'; // Import the Admin Add Event screen

class AdminEventApprovalsScreen extends StatefulWidget {
  @override
  _AdminEventApprovalsScreenState createState() =>
      _AdminEventApprovalsScreenState();
}

class _AdminEventApprovalsScreenState extends State<AdminEventApprovalsScreen> {
  // Fetch events from Firestore that are pending approval
  Future<List<DocumentSnapshot>> _fetchPendingEvents() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('events')
        .where('status', isEqualTo: 'pending') // Fetch only pending events
        .get();

    return snapshot.docs;
  }

  // Update event status (approve, reject)
  Future<void> _updateEventStatus(String eventId, String status) async {
    try {
      await FirebaseFirestore.instance.collection('events').doc(eventId).update({
        'status': status,
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Event $status successfully'),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to update event: $e'),
        backgroundColor: Colors.red,
      ));
    }
    setState(() {}); // Refresh the screen after status change
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Event Approvals"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: _fetchPendingEvents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No pending events."));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final event = snapshot.data![index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  title: Text(
                    event['title'],
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Text(
                    event['description'],
                    style: const TextStyle(fontSize: 16),
                  ),
                  onTap: () {
                    // Navigate to event detail screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminEventDetailScreen(
                          eventId: event.id, // Pass the event ID
                        ),
                      ),
                    );
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Approve Button
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () => _updateEventStatus(event.id, 'approved'),
                      ),
                      // Reject Button
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => _updateEventStatus(event.id, 'rejected'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the Add Event screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AdminAddEventScreen()), // Navigate to Add Event
          );
        },
        backgroundColor: Colors.blueAccent,

        child: const Icon(Icons.add),
      ),
    );
  }
}
