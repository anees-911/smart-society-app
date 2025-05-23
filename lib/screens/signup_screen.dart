import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isNameValid = true;
  bool _isEmailValid = true;
  bool _isPasswordValid = true;
  bool _isConfirmPasswordValid = true;
  bool _isPhoneValid = true;
  bool _isAddressValid = true;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  // Validate functions for the fields
  void _validateName(String value) {
    setState(() {
      _isNameValid = value.trim().isNotEmpty && RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim());
    });
  }

  void _validateEmail(String value) {
    setState(() {
      _isEmailValid = value.trim().isNotEmpty && RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value.trim());
    });
  }

  void _validatePassword(String value) {
    setState(() {
      _isPasswordValid = value.trim().length >= 8;
    });
  }

  void _validateConfirmPassword(String value) {
    setState(() {
      _isConfirmPasswordValid = value.trim() == _passwordController.text.trim();
    });
  }

  void _validatePhone(String value) {
    // Pakistani phone number validation (must be 11 digits and only numbers)
    setState(() {
      _isPhoneValid = value.trim().length == 11 && RegExp(r'^[0-9]+$').hasMatch(value.trim());
    });
  }

  void _validateAddress(String value) {
    // Relaxed validation for the address: It should be non-empty and at least 5 characters long
    setState(() {
      _isAddressValid = value.trim().isNotEmpty && value.trim().length >= 5;
    });
  }

  bool _validateFields() {
    _validateName(_nameController.text);
    _validateEmail(_emailController.text);
    _validatePassword(_passwordController.text);
    _validateConfirmPassword(_confirmPasswordController.text);
    _validatePhone(_phoneController.text);
    _validateAddress(_addressController.text);

    return _isNameValid && _isEmailValid && _isPasswordValid && _isConfirmPasswordValid && _isPhoneValid && _isAddressValid;
  }

  // SignUp process
  Future<void> _signUp(BuildContext context) async {
    if (!_validateFields()) {
      _showMessage('Please fix the errors in the fields.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create user in Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = userCredential.user;

      if (user != null) {
        // Save additional user details in Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'address': _addressController.text.trim(),
          'role': 'user', // Default role is user
          'uid': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });

        _showMessage('Signup successful! Please log in.', success: true);
        Navigator.pop(context); // Navigate back to the login screen
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        _showMessage('This email is already registered.');
      } else if (e.code == 'weak-password') {
        _showMessage('Password is too weak. Choose a stronger password.');
      } else {
        _showMessage('Error: ${e.message}');
      }
    } catch (e) {
      _showMessage('Error: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Show messages to the user
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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.blue.shade400],
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
                  CircleAvatar(
                    radius: screenWidth * 0.15,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person_add,
                      size: screenWidth * 0.1,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'User Signup',
                    style: TextStyle(
                      fontSize: screenWidth * 0.07,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildTextField(
                    controller: _nameController,
                    label: 'Name',
                    prefixIcon: Icons.person,
                    isValid: _isNameValid,
                    errorMessage: 'Enter a valid name.',
                    onChanged: _validateName,
                    screenWidth: screenWidth,
                  ),
                  const SizedBox(height: 20),

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

                  _buildTextField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    prefixIcon: Icons.phone,
                    isValid: _isPhoneValid,
                    errorMessage: 'Enter a valid phone number (11 digits).',
                    onChanged: _validatePhone,
                    screenWidth: screenWidth,
                  ),
                  const SizedBox(height: 20),

                  _buildTextField(
                    controller: _addressController,
                    label: 'Address',
                    prefixIcon: Icons.location_on,
                    isValid: _isAddressValid,
                    errorMessage: 'Address must be at least 5 characters long.',
                    onChanged: _validateAddress,
                    screenWidth: screenWidth,
                  ),
                  const SizedBox(height: 20),

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
                  const SizedBox(height: 20),

                  _buildTextField(
                    controller: _confirmPasswordController,
                    label: 'Confirm Password',
                    prefixIcon: Icons.lock,
                    isValid: _isConfirmPasswordValid,
                    errorMessage: 'Passwords do not match.',
                    obscureText: !_isConfirmPasswordVisible,
                    onChanged: _validateConfirmPassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: Colors.blue,
                      ),
                      onPressed: () {
                        setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible);
                      },
                    ),
                    screenWidth: screenWidth,
                  ),
                  const SizedBox(height: 30),

                  _isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                    onPressed: () => _signUp(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),

                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Already have an account? Login',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
