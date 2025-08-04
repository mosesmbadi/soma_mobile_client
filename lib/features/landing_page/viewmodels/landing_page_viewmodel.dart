import 'package:flutter/material.dart';

class LandingPageViewModel extends ChangeNotifier {
  void navigateToLogin(BuildContext context) {
    Navigator.pushNamed(context, '/login');
  }

  void navigateToGuestStories(BuildContext context) {
    Navigator.pushNamed(context, '/guest_stories');
  }
}