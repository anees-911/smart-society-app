import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_dashboard.dart'; // User Dashboard Screen
import 'admin_dashboard.dart'; // Admin Dashboard Screen
import 'forgot_password.dart'; // Forgot Password Screen

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isEmailValid = true;
  bool _isPasswordValid = true;
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String _role = 'user'; // Default role is user

  void _validateEmail(String value) {
    setState(() {
      _isEmailValid = value.trim().isNotEmpty &&
          RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value.trim());
    });
  }

  void _validatePassword(String value) {
    setState(() {
      _isPasswordValid = value.trim().length >= 8;
    });
  }

  bool _validateFields() {
    _validateEmail(_emailController.text);
    _validatePassword(_passwordController.text);
    return _isEmailValid && _isPasswordValid;
  }

  Future<void> _login(BuildContext context) async {
    if (!_validateFields()) {
      _showMessage('Please fix the errors in the fields.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      DocumentSnapshot userDoc =
      await _firestore.collection('users').doc(userCredential.user!.uid).get();

      if (!userDoc.exists) {
        throw Exception("User role not found in Firestore.");
      }

      String role = userDoc['role'];

      if (_role == 'admin' && role != 'admin') {
        throw Exception("You are not authorized to log in as an admin.");
      } else if (_role == 'user' && role != 'user') {
        throw Exception("You are not authorized to log in as a user.");
      }

      final targetRoute = _role == 'admin' ? '/adminDashboard' : '/userDashboard';
      Navigator.pushReplacementNamed(context, targetRoute);
    } catch (e) {
      _showMessage('Error: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Show message function
  void _showMessage(String message, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: true, // Ensures the screen adjusts when the keyboard is visible
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          height: screenHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _role == 'admin'
                  ? [Colors.teal.shade800, Colors.teal.shade400]
                  : [Colors.blue.shade900, Colors.blue.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Icon
              CircleAvatar(
                radius: screenWidth * 0.15,
                backgroundColor: Colors.white,
                child: Icon(
                  _role == 'admin' ? Icons.admin_panel_settings : Icons.person,
                  size: screenWidth * 0.1,
                  color: _role == 'admin' ? Colors.teal.shade800 : Colors.blue.shade900,
                ),
              ),
              SizedBox(height: 20),

              // Login Title
              Text(
                _role == 'admin' ? 'Admin Login' : 'User Login',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 30),

              // Role Selection (For User or Admin)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChoiceChip(
                    label: const Text('User'),
                    selected: _role == 'user',
                    onSelected: (selected) {
                      setState(() {
                        _role = 'user';
                      });
                    },
                  ),
                  const SizedBox(width: 10),
                  ChoiceChip(
                    label: const Text('Admin'),
                    selected: _role == 'admin',
                    onSelected: (selected) {
                      setState(() {
                        _role = 'admin';
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 30),

              // Email Field
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                prefixIcon: Icons.email,
                isValid: _isEmailValid,
                errorMessage: 'Enter a valid email.',
                onChanged: _validateEmail,
                screenWidth: screenWidth,
              ),
              SizedBox(height: 20),

              // Password Field
              _buildTextField(
                controller: _passwordController,
                label: 'Password',
                prefixIcon: Icons.lock,
                isValid: _isPasswordValid,
                errorMessage: 'Password must be at least 8 characters.',
                obscureText: !_isPasswordVisible,
                onChanged: _validatePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.blue,
                  ),
                  onPressed: () {
                    setState(() => _isPasswordVisible = !_isPasswordVisible);
                  },
                ),
                screenWidth: screenWidth,
              ),
              SizedBox(height: 30),

              // Login Button
              _isLoading
                  ? Column(
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text(
                    'Logging in, please wait...',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              )
                  : ElevatedButton(
                onPressed: _isEmailValid && _isPasswordValid
                    ? () => _login(context)
                    : null, // Disable when invalid
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 20),

              // Forgot Password Navigation
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                ),
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),

              // Signup Navigation
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/signup'),
                child: const Text(
                  'Don\'t have an account? Sign Up',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Reusable Text Field widget
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData prefixIcon,
    required bool isValid,
    required String errorMessage,
    bool obscureText = false,
    void Function(String)? onChanged,
    Widget? suffixIcon,
    required double screenWidth,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: isValid ? Colors.green : Colors.red),
          ),
          errorText: !isValid ? errorMessage : null,
          prefixIcon: Icon(prefixIcon),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}
