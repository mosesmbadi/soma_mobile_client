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
import 'package:soma/features/profile_page/views/profile_update_page.dart';
import 'package:soma/core/widgets/splash_screen.dart';
import 'package:soma/features/story_detail_page/views/story_detail_page.dart'; // New import

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

      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/guest_stories': (context) => const GuestStoriesPage(),
        '/home': (context) => const BottomNavShell(),
        '/add_story': (context) => const AddStoryPage(),
        '/my_stories': (context) => const MyStoriesPage(),
        '/profile': (context) => const ProfilePage(),
        '/register': (context) => const RegistrationPage(),
        '/profile_update': (context) => const ProfileUpdatePage(),
        '/story_detail': (context) { // New route for story detail
          final String? storyId = ModalRoute.of(context)?.settings.arguments as String?;
          if (storyId == null) {
            // Handle the case where storyId is not provided, e.g., navigate to home or show an error
            return const Text('Error: Story ID not provided'); // Or a more robust error page
          }
          return StoryDetailPage(storyId: storyId);
        },
      },
    );
  }
}