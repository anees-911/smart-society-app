import 'package:flutter/material.dart';

class UserRequestMaintenance extends StatelessWidget {
  const UserRequestMaintenance({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Maintenance'),
        backgroundColor: Colors.green.shade700, // Match the dashboard theme
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Please provide the details for your maintenance request:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Add form fields for the maintenance request here
            TextField(
              decoration: InputDecoration(
                labelText: 'Issue Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Implement the submit functionality for the maintenance request
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700, // Green button color
                foregroundColor: Colors.white, // White text
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Submit Request'),
            ),
          ],
        ),
      ),
    );
  }
}
