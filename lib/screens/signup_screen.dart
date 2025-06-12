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

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() => _validateName(_nameController.text));
    _emailController.addListener(() => _validateEmail(_emailController.text));
    _passwordController.addListener(() => _validatePassword(_passwordController.text));
    _confirmPasswordController.addListener(() => _validateConfirmPassword(_confirmPasswordController.text));
    _phoneController.addListener(() => _validatePhone(_phoneController.text));
    _addressController.addListener(() => _validateAddress(_addressController.text));
  }

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
    setState(() {
      _isPhoneValid = value.trim().length == 11 && RegExp(r'^[0-9]+$').hasMatch(value.trim());
    });
  }

  void _validateAddress(String value) {
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

    return _isNameValid &&
        _isEmailValid &&
        _isPasswordValid &&
        _isConfirmPasswordValid &&
        _isPhoneValid &&
        _isAddressValid;
  }

  Future<void> _signUp(BuildContext context) async {
    if (!_validateFields()) {
      _showMessage('Please fix the errors in the fields.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = userCredential.user;

      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'address': _addressController.text.trim(),
          'role': 'user',
          'uid': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });

        _showMessage('Signup successful! Please log in.', success: true);
        Navigator.pop(context);
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
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.blue.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
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

                        _buildTextField(_nameController, 'Name', Icons.person, _isNameValid,
                            'Enter a valid name.', screenWidth),
                        const SizedBox(height: 20),
                        _buildTextField(_emailController, 'Email', Icons.email, _isEmailValid,
                            'Enter a valid email.', screenWidth),
                        const SizedBox(height: 20),
                        _buildTextField(_phoneController, 'Phone Number', Icons.phone,
                            _isPhoneValid, 'Enter a valid phone number (11 digits).', screenWidth),
                        const SizedBox(height: 20),
                        _buildTextField(_addressController, 'Address', Icons.location_on,
                            _isAddressValid, 'Address must be at least 5 characters long.', screenWidth),
                        const SizedBox(height: 20),

                        _buildTextField(
                          _passwordController,
                          'Password',
                          Icons.lock,
                          _isPasswordValid,
                          'Password must be at least 8 characters.',
                          screenWidth,
                          obscureText: !_isPasswordVisible,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                              color: Colors.blue,
                            ),
                            onPressed: () {
                              setState(() => _isPasswordVisible = !_isPasswordVisible);
                            },
                          ),
                        ),
                        const SizedBox(height: 20),

                        _buildTextField(
                          _confirmPasswordController,
                          'Confirm Password',
                          Icons.lock,
                          _isConfirmPasswordValid,
                          'Passwords do not match.',
                          screenWidth,
                          obscureText: !_isConfirmPasswordVisible,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                              color: Colors.blue,
                            ),
                            onPressed: () {
                              setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible);
                            },
                          ),
                        ),
                        const SizedBox(height: 30),

                        _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : ElevatedButton(
                          onPressed: () => _signUp(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 60),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Already have an account? Login',
                            style: TextStyle(
                                color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      IconData prefixIcon,
      bool isValid,
      String errorMessage,
      double screenWidth, {
        bool obscureText = false,
        Widget? suffixIcon,
      }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
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
            borderSide:
            BorderSide(color: isValid ? Colors.green : Colors.red, width: 1.5),
          ),
          errorText: !isValid ? errorMessage : null,
          prefixIcon: Icon(prefixIcon),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}
