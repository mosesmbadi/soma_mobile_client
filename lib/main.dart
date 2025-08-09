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
import 'package:provider/provider.dart'; // Import provider
import 'package:http/http.dart' as http; // Import http
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences

Future<void> main() async { // Make main async
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter binding is initialized
  final SharedPreferences prefs = await SharedPreferences.getInstance(); // Get SharedPreferences instance
  final String? token = prefs.getString('jwt_token'); // Get token
  final bool? rememberMe = prefs.getBool('remember_me'); // Get remember_me flag

  Widget defaultHome = const LandingPage(); // Default to LandingPage

  if (token != null && rememberMe == true) {
    defaultHome = const BottomNavShell(); // Navigate to home if remembered
  }

  runApp(
    MultiProvider(
      providers: [
        Provider<http.Client>(create: (_) => http.Client()),
        Provider<SharedPreferences>(create: (_) => prefs), // Provide the obtained instance
      ],
      child: MyApp(defaultHome: defaultHome), // Pass defaultHome to MyApp
    ),
  );
}

class MyApp extends StatelessWidget {
  final Widget defaultHome; // New field

  const MyApp({super.key, required this.defaultHome}); // New constructor

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

      home: defaultHome,
      routes: {
        '/login': (context) => const LoginPage(),
        '/guest_stories': (context) => const GuestStoriesPage(),
        '/home': (context) => const BottomNavShell(),
        '/add_story': (context) => const AddStoryPage(),
        '/my_stories': (context) => const MyStoriesPage(),
        '/profile': (context) => const ProfilePage(),
        '/register': (context) => const RegistrationPage(),
        '/profile_update': (context) => const ProfileUpdatePage(),
      },
    );
  }
}