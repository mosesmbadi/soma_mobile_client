import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:soma/features/landing_page/views/landing_page.dart';
import 'package:soma/features/login_page/views/login_page.dart';
import 'package:soma/features/guest_stories_page/views/guest_stories_page.dart';
import 'package:soma/features/profile_page/views/profile_page.dart';
import 'package:soma/features/my_stories_page/views/my_stories_page.dart';
import 'package:soma/features/add_story_page/views/add_story_page.dart';
import 'package:soma/core/widgets/bottom_nav.dart';
import 'package:soma/features/registration_page/views/registration_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SOMA',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        primarySwatch: Colors.blue,
        textTheme: TextTheme(
          displayLarge: const TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.bold,
          ),
          titleLarge: GoogleFonts.roboto(
            fontSize: 20,
          ),
          bodyMedium: GoogleFonts.roboto(),
          displaySmall: GoogleFonts.pacifico(),
        ),
      ),

      home: const LandingPage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/guest_stories': (context) => const GuestStoriesPage(),
        '/home': (context) => const BottomNavShell(),
        '/add_story': (context) => const AddStoryPage(),
        '/my_stories': (context) => const MyStoriesPage(),
        '/profile': (context) => const ProfilePage(),
        '/register': (context) => const RegistrationPage(),
      },
    );
  }
}