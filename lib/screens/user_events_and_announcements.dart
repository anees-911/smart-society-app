import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_events_and_announcements.dart';
import 'user_event_details.dart';

class UserEventsAndAnnouncementsScreen extends StatefulWidget {
  @override
  _UserEventsAndAnnouncementsScreenState createState() =>
      _UserEventsAndAnnouncementsScreenState();
}

class _UserEventsAndAnnouncementsScreenState
    extends State<UserEventsAndAnnouncementsScreen> {
  // Fetch events from Firestore
  Future<List<DocumentSnapshot>> _fetchEvents() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('events')
        .where('status', isEqualTo: 'approved') // Only approved events
        .get();

    return snapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Events & Announcements"),
        backgroundColor: Colors.green, // Match the dashboard color
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Display list of approved events
            Expanded(
              child: FutureBuilder<List<DocumentSnapshot>>(
                future: _fetchEvents(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("No events found."));
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
                            event['title'] ?? 'No Title Available', // Default if null
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          subtitle: Text(
                            event['description'] ?? 'No Description Available', // Default if null
                            style: const TextStyle(fontSize: 16),
                          ),
                          onTap: () {
                            // Navigate to EventDetailsScreen when an event is tapped
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EventDetailsScreen(
                                  event: event.data() as Map<String, dynamic> ?? {},
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // Floating Action Button (FAB) with a simple plus (+) icon
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddEventAndAnnouncementScreen()), // Navigate to Add Event
          );
        },
        foregroundColor: Colors.white,
        backgroundColor: Colors.green,
        child: const Icon(Icons.add), // Simple + icon
      ),
    );
  }
}
