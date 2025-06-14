import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddEventAndAnnouncementScreen extends StatefulWidget {
  @override
  _AddEventAndAnnouncementScreenState createState() =>
      _AddEventAndAnnouncementScreenState();
}

class _AddEventAndAnnouncementScreenState
    extends State<AddEventAndAnnouncementScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  bool _isLoading = false;
  String _errorMessage = '';

  final List<String> eventTitles = [
    'Community Meeting',
    'Annual Gathering',
    'Sports Event',
    'Workshop',
    'Social Gathering',
    'Birthday Party'
  ];
  String? _selectedEventTitle;

  DateTime? _selectedDate;

  Future<void> _selectDateAndTime(BuildContext context) async {
    DateTime currentDateTime = DateTime.now();
    DateTime? pickedDateTime = await showDatePicker(
      context: context,
      initialDate: currentDateTime,
      firstDate: currentDateTime,
      lastDate: DateTime(2101),
    ).then((pickedDate) {
      if (pickedDate != null) {
        return showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(currentDateTime),
        ).then((pickedTime) {
          if (pickedTime != null) {
            return DateTime(
              pickedDate.year,
              pickedDate.month,
              pickedDate.day,
              pickedTime.hour,
              pickedTime.minute,
            );
          }
          return null;
        });
      }
      return null;
    });

    if (pickedDateTime != null) {
      setState(() {
        _selectedDate = pickedDateTime;
        _dateController.text =
        "${_selectedDate!.toLocal().toString().split(' ')[0]} ${_selectedDate!.hour}:${_selectedDate!.minute.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _addEvent() async {
    if (_descriptionController.text.trim().isEmpty ||
        _dateController.text.trim().isEmpty ||
        _selectedEventTitle == null) {
      setState(() {
        _errorMessage = 'Please fill out all fields before submitting.';
      });
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      try {
        DateTime eventDateTime = _selectedDate!;

        await FirebaseFirestore.instance.collection('events').add({
          'title': _selectedEventTitle,
          'description': _descriptionController.text.trim(),
          'date': Timestamp.fromDate(eventDateTime),
          'createdBy': user.uid,
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Event submitted for approval.'),
          backgroundColor: Colors.green,
        ));

        _descriptionController.clear();
        _dateController.clear();

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to add event: $e'),
          backgroundColor: Colors.red,
        ));
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Event/Announcement"),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Event Title',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              DropdownButtonFormField<String>(
                value: _selectedEventTitle,
                decoration: const InputDecoration(
                  hintText: 'Select event title',
                  border: OutlineInputBorder(),
                ),
                items: eventTitles.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedEventTitle = value;
                  });
                },
                validator: (value) =>
                value == null ? 'Please select an event title' : null,
              ),
              const SizedBox(height: 20),
              const Text(
                'Event Description',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: "Enter event description",
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Event Date & Time',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _dateController,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: "Pick event date and time",
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDateAndTime(context),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (_errorMessage.isNotEmpty)
                Text(
                  _errorMessage,
                  style: const TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold),
                ),
              const SizedBox(height: 10),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _addEvent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(
                      vertical: 15, horizontal: 40),
                ),
                child: const Text(
                  'Submit Event',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
