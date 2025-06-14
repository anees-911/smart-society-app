import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'forgot_password.dart';

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
  String _role = 'user';

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() => _validateEmail(_emailController.text));
    _passwordController.addListener(() => _validatePassword(_passwordController.text));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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

      final userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      final data = userDoc.data();
      if (data == null || data is! Map || !data.containsKey('role')) {
        throw Exception("User document missing or 'role' field not found.");
      }

      final role = data['role'];
      if (role is! String || (role != 'admin' && role != 'user')) {
        throw Exception("Invalid or unauthorized user role: $role");
      }

      final prefs = await SharedPreferences.getInstance();
      prefs.setBool('isLoggedIn', true);
      prefs.setString('userEmail', userCredential.user!.email!);
      prefs.setString('userRole', role);

      if (role == 'admin') {
        Navigator.pushReplacementNamed(context, '/adminDashboard');
      } else {
        Navigator.pushReplacementNamed(context, '/userDashboard');
      }
    } catch (e) {
      _showMessage('Login Failed: ${e.toString().replaceAll("Exception: ", "")}');
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

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _role == 'admin'
                  ? [Colors.teal.shade800, Colors.teal.shade400]
                  : [Colors.blue.shade900, Colors.blue.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 600),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: screenWidth * 0.15,
                                backgroundColor: Colors.white,
                                child: Icon(
                                  _role == 'admin'
                                      ? Icons.admin_panel_settings
                                      : Icons.person,
                                  size: screenWidth * 0.1,
                                  color: _role == 'admin'
                                      ? Colors.teal.shade800
                                      : Colors.blue.shade900,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                _role == 'admin' ? 'Admin Login' : 'User Login',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 30),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ChoiceChip(
                                    label: const Text('User'),
                                    selected: _role == 'user',
                                    onSelected: (selected) {
                                      setState(() => _role = 'user');
                                    },
                                  ),
                                  const SizedBox(width: 10),
                                  ChoiceChip(
                                    label: const Text('Admin'),
                                    selected: _role == 'admin',
                                    onSelected: (selected) {
                                      setState(() => _role = 'admin');
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 30),
                              _buildTextField(
                                controller: _emailController,
                                label: 'Email',
                                prefixIcon: Icons.email,
                                isValid: _isEmailValid,
                                errorMessage: 'Enter a valid email.',
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
                                screenWidth: screenWidth,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () {
                                    setState(() => _isPasswordVisible = !_isPasswordVisible);
                                  },
                                ),
                              ),
                              const SizedBox(height: 30),
                              _isLoading
                                  ? const Column(
                                children: [
                                  CircularProgressIndicator(color: Colors.white),
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
                                    : null,
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
                                  'Login',
                                  style: TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextButton(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ForgotPasswordScreen(),
                                  ),
                                ),
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (_role == 'user')
                                TextButton(
                                  onPressed: () => Navigator.pushNamed(context, '/signup'),
                                  child: const Text(
                                    'Don\'t have an account? Sign Up',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
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
    Widget? suffixIcon,
    required double screenWidth,
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
