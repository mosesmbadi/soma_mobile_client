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
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soma/core/services/user_repository.dart';
import 'package:soma/core/services/story_repository.dart';
import 'package:soma/core/services/analytics_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('jwt_token');
  final bool? rememberMe = prefs.getBool('remember_me');

  Widget defaultHome = const LandingPage();

  if (token != null && rememberMe == true) {
    defaultHome = const BottomNavShell();
  }

  runApp(
    MultiProvider(
      providers: [
        Provider<http.Client>(create: (_) => http.Client()),
        Provider<SharedPreferences>(create: (_) => prefs),
        Provider<UserRepository>(
          create: (context) => UserRepository(
            prefs: Provider.of<SharedPreferences>(context, listen: false),
            client: Provider.of<http.Client>(context, listen: false),
          ),
        ),
        Provider<StoryRepository>(
          create: (context) => StoryRepository(
            client: Provider.of<http.Client>(context, listen: false),
          ),
        ),
        Provider<AnalyticsRepository>(
          create: (context) => AnalyticsRepository(
            client: Provider.of<http.Client>(context, listen: false),
          ),
        ),
      ],
      child: MyApp(defaultHome: defaultHome),
    ),
  );
}

class MyApp extends StatelessWidget {
  final Widget defaultHome;

  const MyApp({super.key, required this.defaultHome});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SOMA',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.robotoTextTheme(
          Theme.of(context).textTheme.copyWith(
            displayLarge: const TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.bold,
            ),
          ),
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
