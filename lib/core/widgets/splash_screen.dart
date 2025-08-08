import 'package:flutter/material.dart';
import 'package:soma/features/landing_page/views/landing_page.dart'; // Import your landing page

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  _navigateToNextScreen() async {
    // Simulate any app initialization or data loading here
    await Future.delayed(const Duration(seconds: 3)); // Simulate a 3-second loading time

    // After loading, navigate to the main screen of your app
    // For now, we'll navigate to LandingPage. You can add logic here
    // to check if a user is logged in and navigate to BottomNavShell if so.
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LandingPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset('assets/images/loading_animation.gif'),
      ),
    );
  }
}
