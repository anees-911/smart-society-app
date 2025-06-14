import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/admin_dashboard.dart';
import 'screens/user_dashboard.dart';
import 'screens/rentals_screen.dart';
import 'screens/property_details_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const SmartSocietyApp());
}

class SmartSocietyApp extends StatelessWidget {
  const SmartSocietyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Society App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const SplashScreen(), // Start with the SplashScreen
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/adminDashboard': (context) => const AdminDashboard(),
        '/userDashboard': (context) => const UserDashboard(),
        '/rentalScreen': (context) => const RentalsScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/propertyDetails') {
          final property = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => PropertyDetailsScreen(property: property),
          );
        }
        return null;
      },
    );
  }
}
