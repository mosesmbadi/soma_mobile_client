import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soma/features/landing_page/views/landing_page.dart';
import '../../../core/config/environment.dart'; // Corrected import path

const String apiUrl = '${Environment.backendUrl}/api/auth/me'; // Moved to top-level

class ProfilePageViewModel extends ChangeNotifier {
  Map<String, dynamic>? _userData;
  String _errorMessage = '';

  Map<String, dynamic>? get userData => _userData;
  String get errorMessage => _errorMessage;

  ProfilePageViewModel() {
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    _errorMessage = '';
    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('jwt_token');

    if (token == null) {
      _errorMessage = 'No authentication token found. Please log in.';
      notifyListeners();
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        _userData = jsonDecode(response.body);
      } else {
        _errorMessage = 'Failed to load user data: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'An error occurred: $e';
    } finally {
      notifyListeners();
    }
  }

  Future<void> logout(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');

    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LandingPage()),
        (Route<dynamic> route) => false,
      );
    }
  }

  void showTopUpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Top Up Account'),
          content: const Text('Top Up functionality will be implemented here.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void showWithdrawDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Withdraw Funds'),
          content: const Text(
            'Withdraw functionality will be implemented here.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
