import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  String _role = 'user'; // Default role

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

      // Fetch the user role from Firestore
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

    final primaryColor = _role == 'admin' ? Colors.teal.shade800 : Colors.blue.shade900;
    final secondaryColor = _role == 'admin' ? Colors.teal.shade400 : Colors.blue.shade400;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor, secondaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: screenHeight),
            child: IntrinsicHeight(
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
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Login Title
                  Text(
                    _role == 'admin' ? 'Admin Login' : 'User Login',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Role Selection
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Tooltip(
                        message: 'Login as a user to access regular features.',
                        child: ChoiceChip(
                          label: const Text('User'),
                          selected: _role == 'user',
                          onSelected: (selected) {
                            setState(() {
                              _role = 'user';
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Tooltip(
                        message: 'Login as an admin for privileged access.',
                        child: ChoiceChip(
                          label: const Text('Admin'),
                          selected: _role == 'admin',
                          onSelected: (selected) {
                            setState(() {
                              _role = 'admin';
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

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
                  const SizedBox(height: 20),

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
                  const SizedBox(height: 30),

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
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Signup Navigation
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/signup'),
                    child: const Text(
                      'Don\'t have an account? Sign Up',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

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
