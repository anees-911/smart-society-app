import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';  // Add this import

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();  // Check session when splash screen loads
  }

  // Perform session check
  Future<void> _checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    // Delay to show splash screen for a moment, then navigate
    Future.delayed(const Duration(seconds: 10), () {
      if (isLoggedIn) {
        final userRole = prefs.getString('userRole') ?? 'user';
        if (userRole == 'admin') {
          Navigator.pushReplacementNamed(context, '/adminDashboard');  // Navigate to admin dashboard
        } else {
          Navigator.pushReplacementNamed(context, '/userDashboard');  // Navigate to user dashboard
        }
      } else {
        Navigator.pushReplacementNamed(context, '/login');  // Navigate to login screen if not logged in
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade900,
              Colors.blue.shade600,
              Colors.blue.shade300,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipOval(
              child: Image.asset(
                'assets/images/logo.png',  // Your logo file path
                width: 400,  // Adjusted size to better fit the logo and text
                height: 300,  // Adjusted size to better fit the logo and text
                fit: BoxFit.contain,  // Ensures the logo fits without cutting off the text
              ),
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 10),
            // Typewriter animation effect
            AnimatedTextKit(
              animatedTexts: [
                TypewriterAnimatedText(
                  'Simplifying Society Management',
                  textStyle: TextStyle(
                    fontSize: 24,
                    color: Colors.white70,
                    fontStyle: FontStyle.italic,
                  ),
                  speed: const Duration(milliseconds: 100),  // Speed of typing animation
                ),
              ],
              totalRepeatCount: 3, // Number of times the animation repeats
              pause: const Duration(milliseconds: 500), // Pause before ending
              displayFullTextOnTap: true, // Tap to finish the text instantly
            ),
          ],
        ),
      ),
    );
  }
}
