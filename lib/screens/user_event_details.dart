import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EventDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> event;

  const EventDetailsScreen({required this.event, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Convert Timestamp to DateTime
    DateTime eventDate = (event['date'] as Timestamp).toDate();

    // Manually format the date (YYYY-MM-DD)
    String formattedDate = '${eventDate.year}-${eventDate.month.toString().padLeft(2, '0')}-${eventDate.day.toString().padLeft(2, '0')}';

    // Manually format the time (HH:MM AM/PM)
    String formattedTime = '${eventDate.hour.toString().padLeft(2, '0')}:${eventDate.minute.toString().padLeft(2, '0')} ${eventDate.hour >= 12 ? 'PM' : 'AM'}';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          event['title'] ?? 'Event Details',
        ),
        backgroundColor: Colors.green, // Green background color
        centerTitle: true, // Center the title
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Title
            Text(
              event['title'] ?? 'No Title Available',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // Event Description
            Text(
              event['description'] ?? 'No Description Available',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            // Event Date (formatted)
            Text(
              'Event Date: $formattedDate',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            // Event Time (formatted)
            Text(
              'Event Time: $formattedTime',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
