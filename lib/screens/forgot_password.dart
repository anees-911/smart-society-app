import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isEmailValid = true;
  bool _isLoading = false;

  void _validateEmail(String value) {
    setState(() {
      _isEmailValid = value.trim().isNotEmpty && RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value.trim());
    });
  }

  Future<void> _resetPassword() async {
    String email = _emailController.text.trim();

    if (!_isEmailValid) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Password reset link sent! Please check your inbox.'),
        backgroundColor: Colors.green,
      ));
      Navigator.pop(context); // Go back to login screen after sending the reset email
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: ${e.toString()}'),
        backgroundColor: Colors.red,
      ));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Forgot Password"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Enter your email to reset password',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 30),

            // Email input field
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: _validateEmail,
            ),
            const SizedBox(height: 20),

            // Submit button
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _isEmailValid ? _resetPassword : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent, // Changed primary to backgroundColor
                foregroundColor: Colors.white, // Text color
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 60),
              ),
              child: const Text('Send Reset Link', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
