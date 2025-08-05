import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soma/core/config/environment.dart';

class ProfileUpdateViewModel extends ChangeNotifier {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  TextEditingController countryController = TextEditingController();

  bool _isLoading = false;
  String _errorMessage = '';
  String _successMessage = '';

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get successMessage => _successMessage;

  ProfileUpdateViewModel() {
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    _isLoading = true;
    _errorMessage = '';
    _successMessage = '';
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      if (token == null) {
        _errorMessage = 'Authentication token not found.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response = await http.get(
        Uri.parse('${Environment.backendUrl}/api/auth/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        nameController.text = userData['name'] ?? '';
        emailController.text = userData['email'] ?? '';
        bioController.text = userData['bio'] ?? '';
        countryController.text = userData['country'] ?? '';
      } else {
        _errorMessage = 'Failed to load profile: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'An error occurred: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile() async {
    _isLoading = true;
    _errorMessage = '';
    _successMessage = '';
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      if (token == null) {
        _errorMessage = 'Authentication token not found.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response = await http.put(
        Uri.parse('${Environment.backendUrl}/api/auth/profile'), // Assuming this endpoint exists or will be created
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': nameController.text,
          'email': emailController.text,
          'bio': bioController.text,
          'country': countryController.text,
        }),
      );

      if (response.statusCode == 200) {
        _successMessage = 'Profile updated successfully!';
      } else {
        final errorData = jsonDecode(response.body);
        _errorMessage = errorData['message'] ?? 'Failed to update profile.';
      }
    } catch (e) {
      _errorMessage = 'An error occurred: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    bioController.dispose();
    countryController.dispose();
    super.dispose();
  }
}
